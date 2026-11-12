-- Jalankan seluruh isi file ini di Supabase Dashboard > SQL Editor > Run
-- Aman dijalankan ulang (pakai "if not exists" / "on conflict")

create table if not exists requests (
  id text primary key,
  type text not null,
  submitted_at timestamptz not null default now(),
  status text not null default 'baru',
  payment_checked boolean not null default false,
  payment_note text default '',
  payment_date date,
  payment_code integer,
  amount integer,
  admin_note text default '',
  nomor_surat text default '',
  tanggal_surat date,
  generated_text text default '',
  data jsonb not null default '{}'::jsonb
);

-- Untuk project yang tabelnya sudah ada sebelum kolom ini ditambahkan.
alter table requests add column if not exists payment_date date;

create table if not exists settings (
  id integer primary key default 1,
  payment_info text not null default 'Transfer ke CIMB Niaga 800.10.907.7600 a.n. Yayasan Pendidikan Pelita Harapan, lalu centang konfirmasi di bawah.',
  next_surat_number integer not null default 1,
  constraint settings_single_row check (id = 1)
);

insert into settings (id) values (1) on conflict (id) do nothing;

-- View terbatas untuk publik: dipakai halaman "Cek Status" siswa.
-- Tidak mengekspos payment_note, generated_text, atau isi data pribadi lain.
-- admin_note (Catatan Admin) diekspos untuk jenis surat SELAIN Rekomendasi
-- (mis. "Pembayaran belum diterima"). Untuk Rekomendasi, tiap guru yang
-- diminta (sampai 3) punya status & catatan SENDIRI-SENDIRI -- diekspos
-- lewat kolom guruN_* di bawah, supaya siswa bisa lihat progres per guru
-- secara terpisah (guru A sudah selesai, guru B belum, dst).
-- nama_siswa/nama_pengaju/kelas_asrama khusus Izin Klinik -- sengaja TIDAK
-- memakai nama_lengkap (yang dipakai pencarian nama di Cek Status), supaya
-- baris Izin Klinik hanya bisa ditemukan lewat kode persis, bukan lewat
-- pencarian nama siswa.
drop view if exists requests_public;
create view requests_public as
  select
    id,
    type,
    submitted_at,
    status,
    data->>'namaLengkap' as nama_lengkap,
    case when type = 'REKOMENDASI' then null else admin_note end as admin_note,
    data->>'namaGuru' as guru1_nama,
    coalesce(data->>'guruStatus1', status) as guru1_status,
    data->>'guruCatatan1' as guru1_catatan,
    data->>'guruCompletedAt1' as guru1_completed_at,
    data->>'namaGuru2' as guru2_nama,
    coalesce(data->>'guruStatus2', status) as guru2_status,
    data->>'guruCatatan2' as guru2_catatan,
    data->>'guruCompletedAt2' as guru2_completed_at,
    data->>'namaGuru3' as guru3_nama,
    coalesce(data->>'guruStatus3', status) as guru3_status,
    data->>'guruCatatan3' as guru3_catatan,
    data->>'guruCompletedAt3' as guru3_completed_at,
    case when type = 'IZIN_KLINIK' then data->>'namaSiswa' end as klinik_nama_siswa,
    case when type = 'IZIN_KLINIK' then data->>'namaPengaju' end as klinik_nama_pengaju,
    case when type = 'IZIN_KLINIK' then
      coalesce(nullif(concat_ws(' · ', data->>'kelas', data->>'asrama'), ''), data->>'kelasAsrama')
    end as klinik_kelas_asrama,
    case when type = 'IZIN_KLINIK' then data->>'keluhan' end as klinik_keluhan,
    case when type = 'IZIN_KLINIK' then data->>'peranPengaju' end as klinik_peran_pengaju,
    case when type = 'IZIN_KLINIK' then data->>'diagnosa' end as klinik_diagnosa,
    case when type = 'IZIN_KLINIK' then data->>'lamaIstirahat' end as klinik_lama_istirahat,
    case when type = 'IZIN_KLINIK' then data->>'jenisObat' end as klinik_jenis_obat,
    data->>'feedbackAt' as feedback_at,
    case when type <> 'IZIN_KLINIK' then data->>'completedAt' end as completed_at
  from requests;
-- Catatan: catatanKlinik SENGAJA TIDAK diekspos di sini -- itu bisa berisi
-- catatan sensitif klinik (mis. "perlu dirujuk", "diduga pura-pura sakit")
-- yang cuma boleh dilihat staff (Dorm Parent/SPV/RA/Klinik) yang login,
-- bukan lewat pencarian publik Cek Status yang bisa diakses siapa saja
-- (termasuk siswa sendiri) asal tahu kode permintaannya.

-- Fungsi khusus: siswa (anon, tanpa login) bisa perbaiki link form Rekomendasi
-- kalau statusnya (atau status salah satu guru yang diminta) "link_bermasalah",
-- cukup modal tahu kode permintaannya. Me-reset SEMUA slot guru yang sedang
-- link_bermasalah balik ke 'baru' (karena linkForm-nya memang satu & dipakai
-- bersama oleh semua guru yang diminta di permintaan itu).
-- Aman karena: (1) hanya menyentuh baris tipe REKOMENDASI yang memang sedang
-- ada slot berstatus link_bermasalah, (2) hanya mengubah field linkForm +
-- status guru yang bermasalah + catat ke statusHistory, tidak ada field lain
-- yang bisa disentuh siswa lewat jalur ini.
create or replace function public.fix_rekomendasi_link(request_id text, new_link text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  d jsonb;
  cur_status text;
  new_data jsonb;
  history_entry jsonb;
  slot_key text;
  i int;
  st text;
  any_fixed boolean := false;
begin
  select data, status into d, cur_status from requests where id = request_id and type = 'REKOMENDASI';
  if d is null then
    return;
  end if;

  new_data := coalesce(d, '{}'::jsonb) || jsonb_build_object('linkForm', new_link);

  for i in 1..3 loop
    slot_key := 'guruStatus' || i;
    st := coalesce(d->>slot_key, cur_status);
    if st = 'link_bermasalah' then
      new_data := new_data || jsonb_build_object(slot_key, 'baru');
      any_fixed := true;
    end if;
  end loop;

  if not any_fixed then
    return;
  end if;

  history_entry := jsonb_build_object('status', 'baru', 'note', 'Siswa memperbaiki link form', 'at', now());
  new_data := new_data || jsonb_build_object('statusHistory', coalesce(d->'statusHistory', '[]'::jsonb) || jsonb_build_array(history_entry));

  update requests
  set
    data = new_data,
    status = case when cur_status = 'link_bermasalah' then 'baru' else cur_status end
  where id = request_id and type = 'REKOMENDASI';
end;
$$;

grant execute on function public.fix_rekomendasi_link(text, text) to anon;

-- Feedback / ucapan terima kasih dari siswa (anon) setelah surat selesai.
-- Aman karena: hanya bisa 1x per permintaan, hanya kalau surat sudah selesai
-- (untuk Rekomendasi: minimal satu guru sudah selesai), bukan Izin Klinik,
-- dan hanya menulis field feedbackRating/feedbackMessage/feedbackAt.
create or replace function public.submit_feedback(request_id text, rating int, message text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  d jsonb;
  t text;
  st text;
  eligible boolean;
  msg text := nullif(btrim(coalesce(message, '')), '');
begin
  select data, type, status into d, t, st from requests where id = request_id;
  if d is null or t = 'IZIN_KLINIK' then
    raise exception 'Permintaan tidak ditemukan';
  end if;
  if d ? 'feedbackAt' then
    raise exception 'Feedback sudah pernah dikirim';
  end if;
  eligible := st = 'selesai'
    or (t = 'REKOMENDASI' and (d->>'guruStatus1' = 'selesai' or d->>'guruStatus2' = 'selesai' or d->>'guruStatus3' = 'selesai'));
  if not eligible then
    raise exception 'Feedback baru bisa dikirim setelah surat selesai';
  end if;
  if rating is not null and (rating < 1 or rating > 5) then
    raise exception 'Rating harus 1-5';
  end if;
  if rating is null and msg is null then
    raise exception 'Isi rating atau pesan dulu';
  end if;
  if msg is not null and length(msg) > 1000 then
    raise exception 'Pesan terlalu panjang (maks 1000 karakter)';
  end if;
  update requests
  set data = data || jsonb_build_object(
    'feedbackRating', rating,
    'feedbackMessage', msg,
    'feedbackAt', now()
  )
  where id = request_id;
end;
$$;

grant execute on function public.submit_feedback(text, int, text) to anon;

-- Kuesioner pra-penelitian (thesis). Siswa/pengunjung (anon) hanya boleh MENGIRIM
-- jawaban; hanya admin yang login yang boleh MEMBACA. 1 perangkat = 1 jawaban
-- per versi kuesioner (unique device_id + versi).
create table if not exists survey_pra (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  device_id text not null,
  versi text not null,
  nama text,
  kelas text,
  jawaban jsonb not null default '{}'::jsonb,
  unique (device_id, versi)
);
alter table survey_pra enable row level security;
drop policy if exists "anon insert survey_pra" on survey_pra;
create policy "anon insert survey_pra" on survey_pra
  for insert to anon
  with check (octet_length(jawaban::text) < 5000);
drop policy if exists "admin read survey_pra" on survey_pra;
create policy "admin read survey_pra" on survey_pra
  for select to authenticated
  using (true);
grant insert on survey_pra to anon;
grant select, insert, delete on survey_pra to authenticated;
drop policy if exists "admin delete survey_pra" on survey_pra;
create policy "admin delete survey_pra" on survey_pra
  for delete to authenticated
  using (true);

alter table requests enable row level security;
alter table settings enable row level security;

drop policy if exists "anon insert requests" on requests;
create policy "anon insert requests" on requests
  for insert to anon
  with check (status = 'baru');

drop policy if exists "admin full access requests" on requests;
create policy "admin full access requests" on requests
  for all to authenticated
  using (true) with check (true);

drop policy if exists "anon select settings" on settings;
create policy "anon select settings" on settings
  for select to anon
  using (true);

drop policy if exists "admin update settings" on settings;
create policy "admin update settings" on settings
  for all to authenticated
  using (true) with check (true);

grant select on requests_public to anon;
grant select, insert on requests to anon;
grant select on settings to anon;
grant all on requests to authenticated;
grant all on settings to authenticated;

-- ============================================================
-- UNDUH SURAT PDF OLEH SISWA (Cek Status)
-- PDF dibuat di browser admin (kop + TTD + cap), disimpan di tabel ini,
-- lalu siswa/ortu mengunduh lewat fungsi unduh_surat() dengan 2 dari 3:
-- kode pengajuan, email di formulir, NIS/Student ID di formulir.
-- Tabel TIDAK bisa dibaca anon; hanya akun dengan app_metadata.surat_admin = true
-- (diset manual lewat SQL, tidak bisa diubah sendiri oleh pemilik akun) yang
-- boleh menulis/membaca. Hapus otomatis: 14 hari setelah pertama diunduh,
-- atau 30 hari kalau tidak pernah diunduh.
--
-- Sekali saja, beri tanda admin ke akun pemilik (ganti emailnya), lalu login ulang:
--   update auth.users
--   set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"surat_admin": true}'::jsonb
--   where email = 'EMAIL_ADMIN_DI_SINI';
-- ============================================================
create table if not exists surat_pdf (
  request_id text primary key references requests(id) on delete cascade,
  nama_file text not null,
  pdf_base64 text not null,
  created_at timestamptz not null default now(),
  first_download_at timestamptz,
  last_download_at timestamptz,
  download_count int not null default 0
);
alter table surat_pdf enable row level security;
drop policy if exists "surat admin kelola surat_pdf" on surat_pdf;
create policy "surat admin kelola surat_pdf" on surat_pdf
  for all to authenticated
  using (coalesce((auth.jwt() -> 'app_metadata' ->> 'surat_admin')::boolean, false))
  with check (coalesce((auth.jwt() -> 'app_metadata' ->> 'surat_admin')::boolean, false));
revoke all on surat_pdf from anon;
grant select, insert, update, delete on surat_pdf to authenticated;

create table if not exists unduh_log (
  id bigserial primary key,
  at timestamptz not null default now(),
  ip text,
  request_id text,
  ok boolean not null
);
create index if not exists unduh_log_ip_at on unduh_log (ip, at);
alter table unduh_log enable row level security;
drop policy if exists "surat admin baca unduh_log" on unduh_log;
create policy "surat admin baca unduh_log" on unduh_log
  for select to authenticated
  using (coalesce((auth.jwt() -> 'app_metadata' ->> 'surat_admin')::boolean, false));
revoke all on unduh_log from anon;
grant select on unduh_log to authenticated;

create or replace function public.bersihkan_surat_pdf()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare n int;
begin
  delete from surat_pdf
   where (first_download_at is not null and first_download_at < now() - interval '14 days')
      or (first_download_at is null and created_at < now() - interval '30 days');
  get diagnostics n = row_count;
  delete from unduh_log where at < now() - interval '30 days';
  return n;
end;
$$;
revoke all on function public.bersihkan_surat_pdf() from public;
grant execute on function public.bersihkan_surat_pdf() to authenticated;

create or replace function public.unduh_surat(p_kode text, p_email text, p_nis text)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_ip text := '';
  v_gagal int;
  v_kode text := upper(trim(coalesce(p_kode, '')));
  v_email text := lower(trim(coalesce(p_email, '')));
  v_nis text := lower(regexp_replace(coalesce(p_nis, ''), '[^0-9A-Za-z]', '', 'g'));
  v_ids text[];
begin
  perform public.bersihkan_surat_pdf();
  begin
    v_ip := coalesce(
      current_setting('request.headers', true)::json ->> 'cf-connecting-ip',
      current_setting('request.headers', true)::json ->> 'x-real-ip',
      split_part(current_setting('request.headers', true)::json ->> 'x-forwarded-for', ',', 1),
      '');
  exception when others then v_ip := '';
  end;
  v_ip := trim(v_ip);

  -- Maks. 10 percobaan gagal per 15 menit per alamat IP (wifi sekolah bisa berbagi satu IP).
  if v_ip <> '' then
    select count(*) into v_gagal from unduh_log
     where ip = v_ip and not ok and at > now() - interval '15 minutes';
    if v_gagal >= 10 then
      return json_build_object('status', 'terlalu_banyak');
    end if;
  end if;

  if ((v_kode <> '')::int + (v_email <> '')::int + (v_nis <> '')::int) < 2 then
    return json_build_object('status', 'kurang_data');
  end if;

  select array_agg(r.id) into v_ids
    from requests r
    join surat_pdf s on s.request_id = r.id
   where ( (case when v_kode <> '' and r.id = v_kode then 1 else 0 end)
         + (case when v_email <> '' and lower(trim(coalesce(r.data->>'kontak', ''))) = v_email then 1 else 0 end)
         + (case when v_nis <> '' and lower(regexp_replace(coalesce(nullif(r.data->>'studentId', ''), nullif(r.data->>'studentNumber', ''), ''), '[^0-9A-Za-z]', '', 'g')) = v_nis then 1 else 0 end)
         ) >= 2;

  if v_ids is null then
    insert into unduh_log (ip, ok) values (v_ip, false);
    return json_build_object('status', 'tidak_cocok');
  end if;

  update surat_pdf
     set download_count = download_count + 1,
         first_download_at = coalesce(first_download_at, now()),
         last_download_at = now()
   where request_id = any (v_ids);
  insert into unduh_log (ip, request_id, ok) select v_ip, unnest(v_ids), true;

  return json_build_object('status', 'ok', 'files', (
    select json_agg(json_build_object('request_id', s.request_id, 'jenis', r.type, 'nama_file', s.nama_file, 'pdf_base64', s.pdf_base64))
      from surat_pdf s join requests r on r.id = s.request_id
     where s.request_id = any (v_ids)));
end;
$$;
revoke all on function public.unduh_surat(text, text, text) from public;
grant execute on function public.unduh_surat(text, text, text) to anon, authenticated;

-- ============================================================
-- BUKU NOMOR SURAT
-- Nomor surat yang dipakai DI LUAR web (surat manual), dicatat admin di tab
-- "Buku Nomor Surat" supaya web tidak memakai nomor yang sama dan setiap nomor
-- bisa ditelusuri. Nomor yang terbit lewat web tetap tercatat di requests.nomor_surat.
-- Hanya akun dengan app_metadata.surat_admin = true yang boleh membaca/menulis
-- (tanda yang sama dengan surat_pdf).
-- ============================================================
-- Nomor dicatat per tahun surat (nomor bisa mulai lagi dari 1 di tahun baru).
create table if not exists nomor_luar (
  tahun integer not null,
  nomor integer not null check (nomor > 0),
  nomor_lengkap text,
  tanggal date not null,
  perihal text not null,
  untuk text,
  catatan text,
  dicatat_oleh text,
  dicatat_pada timestamptz not null default now(),
  primary key (tahun, nomor)
);
alter table nomor_luar enable row level security;
drop policy if exists "surat admin kelola nomor_luar" on nomor_luar;
create policy "surat admin kelola nomor_luar" on nomor_luar
  for all to authenticated
  using (coalesce((auth.jwt() -> 'app_metadata' ->> 'surat_admin')::boolean, false))
  with check (coalesce((auth.jwt() -> 'app_metadata' ->> 'surat_admin')::boolean, false));
revoke all on nomor_luar from anon;
grant select, insert, update, delete on nomor_luar to authenticated;
