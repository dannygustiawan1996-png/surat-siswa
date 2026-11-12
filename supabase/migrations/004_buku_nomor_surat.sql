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
