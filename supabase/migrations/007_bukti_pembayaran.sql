-- ============================================================
-- BUKTI PEMBAYARAN
-- Siswa mengunggah bukti transfer (foto/PDF) di halaman pembayaran atau di Cek Status.
-- File disimpan di tabel bukti_bayar (satu bukti per pengajuan, unggah ulang = ganti).
-- - Siswa (anon) TIDAK bisa membaca tabel; unggah hanya lewat fungsi unggah_bukti_bayar().
-- - Yang bisa melihat: akun dengan app_metadata.surat_admin = true (admin) atau
--   app_metadata.surat_finance = true (Finance). Tanda ini diset lewat SQL, tidak bisa
--   diubah sendiri oleh pemilik akun.
-- - Dihapus otomatis 21 hari (3 minggu) setelah diunggah: jadwal harian pg_cron, ditambah
--   pembersihan setiap kali ada unggahan / admin membuka dashboard.
--
-- Sekali saja, beri tanda Finance ke akun Finance (ganti emailnya), lalu login ulang:
--   update auth.users
--   set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"surat_finance": true}'::jsonb
--   where email = 'EMAIL_FINANCE_DI_SINI';
-- ============================================================
create table if not exists bukti_bayar (
  request_id text primary key references requests(id) on delete cascade,
  nama_file text not null,
  mime text not null,
  ukuran int not null,
  data_base64 text not null,
  created_at timestamptz not null default now()
);
alter table bukti_bayar enable row level security;
drop policy if exists "admin finance baca bukti_bayar" on bukti_bayar;
create policy "admin finance baca bukti_bayar" on bukti_bayar
  for select to authenticated
  using (coalesce((auth.jwt() -> 'app_metadata' ->> 'surat_admin')::boolean, false)
      or coalesce((auth.jwt() -> 'app_metadata' ->> 'surat_finance')::boolean, false));
drop policy if exists "admin hapus bukti_bayar" on bukti_bayar;
create policy "admin hapus bukti_bayar" on bukti_bayar
  for delete to authenticated
  using (coalesce((auth.jwt() -> 'app_metadata' ->> 'surat_admin')::boolean, false));
revoke all on bukti_bayar from anon;
grant select, delete on bukti_bayar to authenticated;

create or replace function public.bersihkan_bukti_bayar()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare n int;
begin
  delete from bukti_bayar where created_at < now() - interval '21 days';
  get diagnostics n = row_count;
  return n;
end;
$$;
revoke all on function public.bersihkan_bukti_bayar() from public, anon;
grant execute on function public.bersihkan_bukti_bayar() to authenticated;

-- Unggah / ganti bukti. Hanya untuk surat berbayar yang masih menunggu verifikasi atau
-- berstatus "Pembayaran Belum Diterima" (status itu dikembalikan ke "baru" supaya Finance
-- melihatnya lagi di daftar Perlu Dicek).
create or replace function public.unggah_bukti_bayar(p_request_id text, p_nama_file text, p_mime text, p_data text)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id text := upper(trim(coalesce(p_request_id, '')));
  v_status text;
  v_type text;
begin
  perform public.bersihkan_bukti_bayar();
  if coalesce(p_mime, '') not in ('image/jpeg', 'image/png', 'application/pdf') then
    return json_build_object('status', 'tipe_ditolak');
  end if;
  if length(coalesce(p_data, '')) < 100 or length(p_data) > 4200000 then
    return json_build_object('status', 'ukuran_ditolak');
  end if;
  select status, type into v_status, v_type from requests where id = v_id;
  if v_status is null then
    return json_build_object('status', 'tidak_ditemukan');
  end if;
  if v_type in ('REKOMENDASI', 'IZIN_KLINIK') or v_status not in ('baru', 'pembayaran_belum_diterima') then
    return json_build_object('status', 'tidak_bisa');
  end if;

  insert into bukti_bayar (request_id, nama_file, mime, ukuran, data_base64, created_at)
  values (v_id, left(coalesce(nullif(trim(p_nama_file), ''), 'bukti'), 120), p_mime, (length(p_data) * 3) / 4, p_data, now())
  on conflict (request_id) do update
    set nama_file = excluded.nama_file, mime = excluded.mime, ukuran = excluded.ukuran,
        data_base64 = excluded.data_base64, created_at = now();

  if v_status = 'pembayaran_belum_diterima' then
    update requests set status = 'baru' where id = v_id;
  end if;
  return json_build_object('status', 'ok', 'status_baru', case when v_status = 'pembayaran_belum_diterima' then 'baru' else v_status end);
end;
$$;
revoke all on function public.unggah_bukti_bayar(text, text, text, text) from public;
grant execute on function public.unggah_bukti_bayar(text, text, text, text) to anon, authenticated;

-- Jadwal harian (03.15 WIB = 20.15 UTC) menghapus bukti yang sudah lebih dari 21 hari.
create extension if not exists pg_cron;
select cron.schedule('hapus-bukti-bayar', '15 20 * * *', 'select public.bersihkan_bukti_bayar()');

notify pgrst, 'reload schema';
