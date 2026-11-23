-- ============================================================
-- SERTIFIKAT UPH COLLEGE
-- Halaman admin: /sertifikat/   ·   Halaman QR publik: /cek/#<token>
--
-- Semua akses lewat fungsi (RPC) di bawah. Tabel-tabelnya TIDAK bisa dibaca
-- atau ditulis langsung oleh anon maupun akun login (RLS aktif tanpa policy).
--   - Fungsi admin hanya jalan untuk akun dengan app_metadata.sertifikat_admin = true
--     (diset lewat SQL, tidak bisa diubah sendiri oleh pemilik akun).
--   - cek_sertifikat() boleh dipanggil siapa saja, tapi hanya mengembalikan data
--     yang memang tercetak di sertifikat (tanpa gambar TTD, pembuat, alasan batal).
--
-- Jalankan seluruh file ini di Supabase Dashboard > SQL Editor > Run.
-- Aman dijalankan ulang.
--
-- Lalu beri akses ke akun yang boleh menerbitkan (ganti emailnya), dan login ulang:
--   update auth.users
--   set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"sertifikat_admin": true}'::jsonb
--   where email = 'EMAIL_ADMIN_DI_SINI';
-- Mencabut akses: ganti true menjadi false (berlaku setelah sesi orang itu habis, maks. 1 jam).
-- ============================================================

-- ---------- tabel ----------

-- Setiap simpan TTD = versi baru, supaya sertifikat lama tetap memakai TTD yang berlaku saat terbit.
create table if not exists sertifikat_ttd (
  id bigint generated always as identity primary key,
  sisi text not null check (sisi in ('kiri', 'kanan')),
  nama text not null check (char_length(nama) between 1 and 80),
  jabatan text not null check (char_length(jabatan) between 1 and 80),
  gambar text not null default ''
    check (gambar = '' or (octet_length(gambar) <= 1500000 and gambar ~ '^data:image/(png|jpeg);base64,[A-Za-z0-9+/=]+$')),
  dibuat_oleh text,
  dibuat_pada timestamptz not null default now()
);

create table if not exists sertifikat_setelan (
  id integer primary key default 1 check (id = 1),
  unit text not null default 'CERT' check (unit ~ '^[A-Z0-9]{2,8}$'),
  nomor_mulai integer not null default 1 check (nomor_mulai between 1 and 99999),
  tahun_mulai integer,                    -- nomor_mulai hanya berlaku di tahun ini
  frasa jsonb not null default '{"v":3,"lead":[{"t":"for receiving the","brk":0},{"t":"for achieving","brk":0},{"t":"for participating as","brk":0},{"t":"for participating in","brk":0},{"t":"for serving as","brk":0},{"t":"in recognition of","brk":0}],"conn":["at","in"]}'::jsonb,
  ttd_kiri bigint references sertifikat_ttd(id),
  ttd_kanan bigint references sertifikat_ttd(id)
);
insert into sertifikat_setelan (id) values (1) on conflict (id) do nothing;

create table if not exists sertifikat (
  token text primary key check (token ~ '^[a-z0-9]{24}$'),   -- isi QR, acak, tidak bisa ditebak
  nomor text not null unique,                                 -- 0001/CERT/UPHC/XI/2026
  tahun integer not null,
  urut integer not null check (urut > 0),
  jenis text not null check (jenis in ('appreciation', 'achievement')),
  nama text not null,
  isi jsonb not null default '{}'::jsonb,                     -- lead, conn, ach, role, event, subtitle, organizer, mode, d1, d2, ay
  tanggal_terbit date not null,
  ttd_kiri bigint references sertifikat_ttd(id),
  ttd_kanan bigint references sertifikat_ttd(id),
  status text not null default 'valid' check (status in ('valid', 'batal')),
  alasan_batal text,
  dibatalkan_oleh text,
  dibatalkan_pada timestamptz,
  dibuat_oleh text not null,
  dibuat_pada timestamptz not null default now(),
  id_permintaan text not null,                                -- satu klik "Issue"; mencegah sertifikat ganda
  unique (tahun, urut)
);
create index if not exists sertifikat_id_permintaan on sertifikat (id_permintaan);

create table if not exists sertifikat_log (
  id bigint generated always as identity primary key,
  at timestamptz not null default now(),
  oleh text not null,
  aksi text not null,
  nomor text not null default '',
  detail text not null default ''
);

alter table sertifikat_ttd enable row level security;
alter table sertifikat_setelan enable row level security;
alter table sertifikat enable row level security;
alter table sertifikat_log enable row level security;
revoke all on sertifikat_ttd, sertifikat_setelan, sertifikat, sertifikat_log from anon, authenticated;

-- ---------- pembantu (tidak dipanggil dari luar) ----------

-- Email admin yang sedang login; menolak kalau akun tidak punya tanda sertifikat_admin.
create or replace function public.sertifikat_perlu_admin()
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
declare c jsonb := coalesce(auth.jwt(), '{}'::jsonb);
begin
  if coalesce(c -> 'app_metadata' ->> 'sertifikat_admin', 'false') <> 'true' then
    raise exception 'Akun ini belum diberi akses sertifikat.' using errcode = '42501';
  end if;
  return coalesce(nullif(c ->> 'email', ''), c ->> 'sub', 'admin');
end;
$$;

create or replace function public.sertifikat_teks(t text, maks int)
returns text
language sql
immutable
as $$
  select left(btrim(regexp_replace(regexp_replace(coalesce(t, ''), '[[:cntrl:]]', ' ', 'g'), '\s+', ' ', 'g')), maks)
$$;

-- 'YYYY-MM-DD' yang benar-benar ada di kalender, atau null.
create or replace function public.sertifikat_tanggal(t text)
returns date
language plpgsql
immutable
as $$
declare d date;
begin
  if coalesce(t, '') !~ '^\d{4}-\d{2}-\d{2}$' then return null; end if;
  begin d := t::date; exception when others then return null; end;
  if to_char(d, 'YYYY-MM-DD') <> t then return null; end if;
  return d;
end;
$$;

create or replace function public.sertifikat_token_baru()
returns text
language plpgsql
volatile
as $$
declare
  abjad text := 'abcdefghjkmnpqrstuvwxyz23456789';
  h text := replace(gen_random_uuid()::text, '-', '') || replace(gen_random_uuid()::text, '-', '');
  s text := '';
  i int;
begin
  for i in 0..23 loop
    s := s || substr(abjad, (('x' || substr(h, i * 2 + 1, 2))::bit(8)::int % 31) + 1, 1);
  end loop;
  return s;
end;
$$;

create or replace function public.sertifikat_nomor4(n int)
returns text
language sql
immutable
as $$ select case when length(n::text) >= 4 then n::text else lpad(n::text, 4, '0') end $$;

-- Bentuk data yang dipakai halaman admin (nama field sama dengan versi sebelumnya).
create or replace function public.sertifikat_json(s sertifikat)
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'token', s.token, 'num', s.nomor, 'seq', s.urut, 'title', s.jenis, 'name', s.nama,
    'lead', coalesce(s.isi -> 'lead', '{"t":"","brk":0}'::jsonb),
    'conn', coalesce(s.isi ->> 'conn', ''), 'ach', coalesce(s.isi ->> 'ach', ''), 'role', coalesce(s.isi ->> 'role', ''),
    'event', coalesce(s.isi ->> 'event', ''), 'subtitle', coalesce(s.isi ->> 'subtitle', ''),
    'organizer', coalesce(s.isi ->> 'organizer', ''), 'mode', coalesce(s.isi ->> 'mode', 'none'),
    'd1', coalesce(s.isi ->> 'd1', ''), 'd2', coalesce(s.isi ->> 'd2', ''), 'ay', coalesce(s.isi ->> 'ay', ''),
    'issuedOn', to_char(s.tanggal_terbit, 'YYYY-MM-DD'), 'issuedBy', s.dibuat_oleh, 'issuedAt', s.dibuat_pada,
    'status', case when s.status = 'batal' then 'voided' else 'valid' end,
    'voidReason', coalesce(s.alasan_batal, ''),
    'sigL', s.ttd_kiri::text, 'sigR', s.ttd_kanan::text
  )
$$;

create or replace function public.sertifikat_ttd_json(t sertifikat_ttd)
returns jsonb
language sql
stable
as $$
  select case when t.id is null then '{"name":"","title":"","img":""}'::jsonb
    else jsonb_build_object('name', t.nama, 'title', t.jabatan, 'img', t.gambar) end
$$;

create or replace function public.sertifikat_catat(p_oleh text, p_aksi text, p_nomor text, p_detail text)
returns jsonb
language plpgsql
as $$
declare l sertifikat_log;
begin
  insert into sertifikat_log (oleh, aksi, nomor, detail)
  values (p_oleh, p_aksi, coalesce(p_nomor, ''), left(coalesce(p_detail, ''), 300))
  returning * into l;
  return jsonb_build_object('at', l.at, 'who', l.oleh, 'action', l.aksi, 'code', l.nomor, 'detail', l.detail);
end;
$$;

-- ---------- fungsi untuk halaman admin ----------

-- Semua data dashboard sekaligus.
create or replace function public.sertifikat_awal()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_admin text := sertifikat_perlu_admin();
  st sertifikat_setelan;
begin
  select * into st from sertifikat_setelan where id = 1;
  return jsonb_build_object(
    'me', v_admin,
    'records', coalesce((select jsonb_agg(sertifikat_json(s) order by s.dibuat_pada, s.tahun, s.urut) from sertifikat s), '[]'::jsonb),
    'sigs', coalesce((select jsonb_object_agg(t.id::text, sertifikat_ttd_json(t)) from sertifikat_ttd t
                      where t.id in (select ttd_kiri from sertifikat union select ttd_kanan from sertifikat)), '{}'::jsonb),
    'sig', jsonb_build_object(
      'l', coalesce((select sertifikat_ttd_json(t) from sertifikat_ttd t where t.id = st.ttd_kiri), '{"name":"","title":"","img":""}'::jsonb),
      'r', coalesce((select sertifikat_ttd_json(t) from sertifikat_ttd t where t.id = st.ttd_kanan), '{"name":"","title":"","img":""}'::jsonb)),
    'logs', coalesce((select jsonb_agg(x.j order by x.id) from (
              select l.id, jsonb_build_object('at', l.at, 'who', l.oleh, 'action', l.aksi, 'code', l.nomor, 'detail', l.detail) as j
              from sertifikat_log l order by l.id desc limit 3000) x), '[]'::jsonb),
    'phrases', st.frasa,
    'settings', jsonb_build_object('unit', st.unit, 'start', st.nomor_mulai,
                  'startYear', coalesce(st.tahun_mulai, extract(year from now() at time zone 'Asia/Jakarta')::int))
  );
end;
$$;

-- Menerbitkan 1–100 sertifikat. p_items: array objek
--   {title, name, lead:{t,brk}, conn, ach, role, event, subtitle, organizer, mode, d1, d2, ay, issuedOn}
-- p_id_permintaan: dibuat halaman sekali per klik; kalau dikirim ulang, sertifikat yang sudah dibuat dikembalikan.
create or replace function public.terbitkan_sertifikat(p_items jsonb, p_id_permintaan text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_admin text := sertifikat_perlu_admin();
  st sertifikat_setelan;
  it jsonb;
  i int := 0;
  n int;
  baris text;
  v_jenis text; v_nama text; v_ach text; v_event text; v_mode text; v_d1 text := ''; v_d2 text := ''; v_ay text := '';
  v_lead jsonb; v_terbit date; v_tahun int; v_urut int; v_nomor text; v_token text; v_bulan text;
  v_list text[];
  s sertifikat;
  keluar jsonb := '[]'::jsonb;
  logs jsonb := '[]'::jsonb;
  romawi text[] := array['I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII'];
begin
  if coalesce(p_id_permintaan, '') !~ '^[a-z0-9]{10,40}$' then
    raise exception 'ID permintaan tidak sah. Muat ulang halaman lalu coba lagi.';
  end if;

  -- Kunci baris setelan: penerbitan berjalan satu per satu, jadi nomor tidak pernah kembar.
  select * into st from sertifikat_setelan where id = 1 for update;

  if exists (select 1 from sertifikat where id_permintaan = p_id_permintaan) then
    return jsonb_build_object(
      'replay', true, 'logs', '[]'::jsonb,
      'records', (select jsonb_agg(sertifikat_json(x) order by x.tahun, x.urut) from sertifikat x where x.id_permintaan = p_id_permintaan),
      'sigs', coalesce((select jsonb_object_agg(t.id::text, sertifikat_ttd_json(t)) from sertifikat_ttd t
                        where t.id in (select ttd_kiri from sertifikat where id_permintaan = p_id_permintaan
                                       union select ttd_kanan from sertifikat where id_permintaan = p_id_permintaan)), '{}'::jsonb));
  end if;

  if jsonb_typeof(p_items) is distinct from 'array' then raise exception 'Data sertifikat tidak sah.'; end if;
  n := jsonb_array_length(p_items);
  if n < 1 then raise exception 'Belum ada penerima.'; end if;
  if n > 100 then raise exception 'Maksimal 100 orang sekali terbit.'; end if;

  for it in select value from jsonb_array_elements(p_items) loop
    i := i + 1;
    baris := case when n > 1 then ' (baris ' || i || ')' else '' end;
    v_jenis := case when it ->> 'title' = 'achievement' then 'achievement' else 'appreciation' end;
    v_nama := sertifikat_teks(it ->> 'name', 80);
    v_ach := sertifikat_teks(it ->> 'ach', 90);
    v_event := sertifikat_teks(it ->> 'event', 100);
    v_mode := coalesce(it ->> 'mode', '');
    v_lead := jsonb_build_object('t', sertifikat_teks(it -> 'lead' ->> 't', 80),
                                 'brk', case when coalesce(it -> 'lead' ->> 'brk', '0') in ('1', 'true') then 1 else 0 end);
    v_terbit := sertifikat_tanggal(it ->> 'issuedOn');
    v_d1 := ''; v_d2 := ''; v_ay := '';

    if v_nama = '' then raise exception 'Nama belum diisi%.', baris; end if;
    if v_ach = '' and v_event = '' then raise exception 'Isi prestasi atau acara%.', baris; end if;
    if v_terbit is null then raise exception 'Tanggal terbit tidak sah%.', baris; end if;
    if v_mode not in ('single', 'range', 'multi', 'academic', 'none') then raise exception 'Format tanggal tidak dikenal%.', baris; end if;

    if v_mode = 'single' then
      if sertifikat_tanggal(it ->> 'd1') is null then raise exception 'Tanggal acara tidak sah%.', baris; end if;
      v_d1 := it ->> 'd1';
    elsif v_mode = 'range' then
      if sertifikat_tanggal(it ->> 'd1') is null then raise exception 'Tanggal mulai tidak sah%.', baris; end if;
      v_d1 := it ->> 'd1';
      if coalesce(it ->> 'd2', '') <> '' then
        if sertifikat_tanggal(it ->> 'd2') is null then raise exception 'Tanggal selesai tidak sah%.', baris; end if;
        if sertifikat_tanggal(it ->> 'd2') < sertifikat_tanggal(v_d1) then raise exception 'Tanggal selesai sebelum tanggal mulai%.', baris; end if;
        v_d2 := it ->> 'd2';
      end if;
    elsif v_mode = 'multi' then
      select array_agg(distinct x order by x) into v_list
        from unnest(string_to_array(coalesce(it ->> 'd1', ''), ',')) x where sertifikat_tanggal(x) is not null;
      if v_list is null or array_length(v_list, 1) > 31 then raise exception 'Isi 1 sampai 31 tanggal%.', baris; end if;
      v_d1 := array_to_string(v_list, ',');
    elsif v_mode = 'academic' then
      if coalesce(it ->> 'ay', '') !~ '^\d{4}$' or (it ->> 'ay')::int not between 2000 and 2199 then
        raise exception 'Tahun ajaran tidak sah%.', baris;
      end if;
      v_ay := it ->> 'ay';
    end if;

    v_tahun := extract(year from v_terbit)::int;
    v_bulan := romawi[extract(month from v_terbit)::int];
    select greatest(coalesce(max(urut), 0) + 1, case when st.tahun_mulai = v_tahun then st.nomor_mulai else 1 end)
      into v_urut from sertifikat where tahun = v_tahun;
    v_nomor := sertifikat_nomor4(v_urut) || '/' || st.unit || '/UPHC/' || v_bulan || '/' || v_tahun;
    loop
      v_token := sertifikat_token_baru();
      exit when not exists (select 1 from sertifikat where token = v_token);
    end loop;

    insert into sertifikat (token, nomor, tahun, urut, jenis, nama, isi, tanggal_terbit, ttd_kiri, ttd_kanan, dibuat_oleh, id_permintaan)
    values (v_token, v_nomor, v_tahun, v_urut, v_jenis, v_nama,
            jsonb_build_object('lead', v_lead, 'conn', sertifikat_teks(it ->> 'conn', 30), 'ach', v_ach,
                               'role', sertifikat_teks(it ->> 'role', 90), 'event', v_event,
                               'subtitle', sertifikat_teks(it ->> 'subtitle', 90), 'organizer', sertifikat_teks(it ->> 'organizer', 100),
                               'mode', v_mode, 'd1', v_d1, 'd2', v_d2, 'ay', v_ay),
            v_terbit, st.ttd_kiri, st.ttd_kanan, v_admin, p_id_permintaan)
    returning * into s;

    keluar := keluar || jsonb_build_array(sertifikat_json(s));
    logs := logs || jsonb_build_array(sertifikat_catat(v_admin, 'Issued', v_nomor,
      case when v_jenis = 'achievement' then 'Certificate of Achievement' else 'Certificate of Appreciation' end
      || ' · ' || coalesce(nullif(v_event, ''), v_ach)));
  end loop;

  return jsonb_build_object(
    'records', keluar,
    'logs', logs,
    'sigs', coalesce((select jsonb_object_agg(t.id::text, sertifikat_ttd_json(t)) from sertifikat_ttd t where t.id in (st.ttd_kiri, st.ttd_kanan)), '{}'::jsonb));
end;
$$;

create or replace function public.batalkan_sertifikat(p_token text, p_alasan text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_admin text := sertifikat_perlu_admin();
  v_alasan text := sertifikat_teks(p_alasan, 300);
  s sertifikat;
begin
  if char_length(v_alasan) < 5 then raise exception 'Tulis alasan pembatalan (minimal 5 huruf).'; end if;
  select * into s from sertifikat where token = p_token for update;
  if s.token is null then raise exception 'Sertifikat tidak ditemukan.'; end if;
  if s.status = 'batal' then raise exception 'Sertifikat ini sudah dibatalkan.'; end if;
  update sertifikat set status = 'batal', alasan_batal = v_alasan, dibatalkan_oleh = v_admin, dibatalkan_pada = now()
   where token = p_token;
  return jsonb_build_object('logs', jsonb_build_array(sertifikat_catat(v_admin, 'Voided', s.nomor, v_alasan)));
end;
$$;

-- p_sisi: 'l' (kiri) atau 'r' (kanan). p_gambar: '' atau data URL PNG/JPEG.
create or replace function public.simpan_ttd_sertifikat(p_sisi text, p_nama text, p_jabatan text, p_gambar text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_admin text := sertifikat_perlu_admin();
  v_sisi text := case p_sisi when 'l' then 'kiri' when 'r' then 'kanan' end;
  v_nama text := sertifikat_teks(p_nama, 80);
  v_jabatan text := sertifikat_teks(p_jabatan, 80);
  v_gambar text := coalesce(p_gambar, '');
  t sertifikat_ttd;
begin
  if v_sisi is null then raise exception 'Sisi TTD tidak dikenal.'; end if;
  if v_nama = '' or v_jabatan = '' then raise exception 'Nama dan jabatan wajib diisi.'; end if;
  if v_gambar <> '' and (octet_length(v_gambar) > 1500000 or v_gambar !~ '^data:image/(png|jpeg);base64,[A-Za-z0-9+/=]+$') then
    raise exception 'Gambar TTD harus PNG atau JPEG (maks. 1 MB).';
  end if;
  insert into sertifikat_ttd (sisi, nama, jabatan, gambar, dibuat_oleh)
  values (v_sisi, v_nama, v_jabatan, v_gambar, v_admin) returning * into t;
  if v_sisi = 'kiri' then update sertifikat_setelan set ttd_kiri = t.id where id = 1;
  else update sertifikat_setelan set ttd_kanan = t.id where id = 1; end if;
  return jsonb_build_object('sig', sertifikat_ttd_json(t), 'logs', jsonb_build_array(sertifikat_catat(v_admin, 'Signatories Updated', '',
    case when v_sisi = 'kiri' then 'Left Signatory: ' else 'Right Signatory: ' end || v_nama || ', ' || v_jabatan
    || case when v_gambar <> '' then ' (signature image set)' else '' end)));
end;
$$;

create or replace function public.simpan_frasa_sertifikat(p_frasa jsonb, p_detail text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_admin text := sertifikat_perlu_admin();
  v_lead jsonb; v_conn jsonb;
begin
  if jsonb_typeof(p_frasa -> 'lead') is distinct from 'array' or jsonb_typeof(p_frasa -> 'conn') is distinct from 'array' then
    raise exception 'Daftar kalimat tidak sah.';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object('t', lower(sertifikat_teks(e ->> 't', 80)),
                                               'brk', case when coalesce(e ->> 'brk', '0') in ('1', 'true') then 1 else 0 end)), '[]'::jsonb)
    into v_lead from jsonb_array_elements(p_frasa -> 'lead') e;
  select coalesce(jsonb_agg(to_jsonb(lower(sertifikat_teks(e #>> '{}', 30)))), '[]'::jsonb)
    into v_conn from jsonb_array_elements(p_frasa -> 'conn') e;
  if jsonb_array_length(v_lead) not between 1 and 40 or jsonb_array_length(v_conn) not between 1 and 20 then
    raise exception 'Simpan 1–40 kalimat pembuka dan 1–20 kata penghubung.';
  end if;
  if exists (select 1 from jsonb_array_elements(v_lead) e where e ->> 't' = '')
     or exists (select 1 from jsonb_array_elements_text(v_conn) c where c = '') then
    raise exception 'Ada kalimat yang kosong.';
  end if;
  update sertifikat_setelan set frasa = jsonb_build_object('v', 3, 'lead', v_lead, 'conn', v_conn) where id = 1;
  return jsonb_build_object('logs', jsonb_build_array(sertifikat_catat(v_admin, 'Wording Updated', '',
    coalesce(nullif(sertifikat_teks(p_detail, 200), ''), 'Wording list changed'))));
end;
$$;

-- Kode unit + nomor berikutnya (hanya untuk tahun berjalan, WIB).
create or replace function public.simpan_setelan_sertifikat(p_unit text, p_mulai int)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_admin text := sertifikat_perlu_admin();
  v_unit text := upper(btrim(coalesce(p_unit, '')));
  v_tahun int := extract(year from now() at time zone 'Asia/Jakarta')::int;
  v_pakai int;
begin
  if v_unit !~ '^[A-Z0-9]{2,8}$' then raise exception 'Kode unit harus 2–8 huruf atau angka.'; end if;
  perform 1 from sertifikat_setelan where id = 1 for update;
  select coalesce(max(urut), 0) into v_pakai from sertifikat where tahun = v_tahun;
  if p_mulai is null or p_mulai < v_pakai + 1 or p_mulai > 99999 then
    raise exception 'Nomor berikutnya tidak boleh di bawah %.', sertifikat_nomor4(v_pakai + 1);
  end if;
  update sertifikat_setelan set unit = v_unit, nomor_mulai = p_mulai, tahun_mulai = v_tahun where id = 1;
  return jsonb_build_object(
    'settings', jsonb_build_object('unit', v_unit, 'start', p_mulai, 'startYear', v_tahun),
    'logs', jsonb_build_array(sertifikat_catat(v_admin, 'Settings Updated', '',
      'Numbering: unit code ' || v_unit || ', next number ' || sertifikat_nomor4(p_mulai))));
end;
$$;

create or replace function public.catat_unduh_sertifikat(p_nomor text, p_detail text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare v_admin text := sertifikat_perlu_admin();
begin
  return jsonb_build_object('entry', sertifikat_catat(v_admin, 'Downloaded', sertifikat_teks(p_nomor, 40), sertifikat_teks(p_detail, 200)));
end;
$$;

-- ---------- fungsi publik: halaman QR ----------

create or replace function public.cek_sertifikat(p_token text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare s sertifikat;
begin
  if coalesce(p_token, '') !~ '^[a-z0-9]{24}$' then return jsonb_build_object('found', false); end if;
  select * into s from sertifikat where token = p_token;
  if s.token is null then return jsonb_build_object('found', false); end if;
  return jsonb_build_object('found', true, 'rec', jsonb_build_object(
    'num', s.nomor,
    'title', s.jenis,
    'name', s.nama,
    'lead', coalesce(s.isi -> 'lead', '{"t":"","brk":0}'::jsonb),
    'conn', coalesce(s.isi ->> 'conn', ''), 'ach', coalesce(s.isi ->> 'ach', ''), 'role', coalesce(s.isi ->> 'role', ''),
    'event', coalesce(s.isi ->> 'event', ''), 'subtitle', coalesce(s.isi ->> 'subtitle', ''), 'organizer', coalesce(s.isi ->> 'organizer', ''),
    'mode', coalesce(s.isi ->> 'mode', 'none'), 'd1', coalesce(s.isi ->> 'd1', ''), 'd2', coalesce(s.isi ->> 'd2', ''), 'ay', coalesce(s.isi ->> 'ay', ''),
    'issuedOn', to_char(s.tanggal_terbit, 'YYYY-MM-DD'),
    'status', case when s.status = 'batal' then 'voided' else 'valid' end,
    'signers', jsonb_build_array(
      (select jsonb_build_object('name', t.nama, 'title', t.jabatan) from sertifikat_ttd t where t.id = s.ttd_kiri),
      (select jsonb_build_object('name', t.nama, 'title', t.jabatan) from sertifikat_ttd t where t.id = s.ttd_kanan))
  ));
end;
$$;

-- ---------- hak panggil ----------

revoke all on function public.sertifikat_perlu_admin() from public, anon, authenticated;
revoke all on function public.sertifikat_catat(text, text, text, text) from public, anon, authenticated;
revoke all on function public.sertifikat_token_baru() from public, anon, authenticated;

revoke all on function public.sertifikat_awal() from public, anon;
revoke all on function public.terbitkan_sertifikat(jsonb, text) from public, anon;
revoke all on function public.batalkan_sertifikat(text, text) from public, anon;
revoke all on function public.simpan_ttd_sertifikat(text, text, text, text) from public, anon;
revoke all on function public.simpan_frasa_sertifikat(jsonb, text) from public, anon;
revoke all on function public.simpan_setelan_sertifikat(text, int) from public, anon;
revoke all on function public.catat_unduh_sertifikat(text, text) from public, anon;
grant execute on function public.sertifikat_awal() to authenticated;
grant execute on function public.terbitkan_sertifikat(jsonb, text) to authenticated;
grant execute on function public.batalkan_sertifikat(text, text) to authenticated;
grant execute on function public.simpan_ttd_sertifikat(text, text, text, text) to authenticated;
grant execute on function public.simpan_frasa_sertifikat(jsonb, text) to authenticated;
grant execute on function public.simpan_setelan_sertifikat(text, int) to authenticated;
grant execute on function public.catat_unduh_sertifikat(text, text) to authenticated;

revoke all on function public.cek_sertifikat(text) from public;
grant execute on function public.cek_sertifikat(text) to anon, authenticated;
