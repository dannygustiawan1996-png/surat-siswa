-- Bukti pembayaran disimpan 7 hari saja (sebelumnya 21 hari di migrasi 007),
-- karena proyek Supabase web surat masih paket gratis. Jadwal pg_cron harian tetap sama.
create or replace function public.bersihkan_bukti_bayar()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare n int;
begin
  delete from bukti_bayar where created_at < now() - interval '7 days';
  get diagnostics n = row_count;
  return n;
end;
$$;
revoke all on function public.bersihkan_bukti_bayar() from public, anon;
grant execute on function public.bersihkan_bukti_bayar() to authenticated;
