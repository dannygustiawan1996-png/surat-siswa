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
-- Tidak mengekspos payment_note, admin_note, generated_text, atau isi data pribadi lain.
create or replace view requests_public as
  select
    id,
    type,
    submitted_at,
    status,
    data->>'namaLengkap' as nama_lengkap
  from requests;

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
