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
    case when type = 'IZIN_KLINIK' then data->>'jenisObat' end as klinik_jenis_obat
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
