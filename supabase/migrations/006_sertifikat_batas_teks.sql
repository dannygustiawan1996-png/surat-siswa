-- ============================================================
-- SERTIFIKAT: batas panjang teks (lanjutan 005)
-- - Narasi boleh panjang: nama 120, kalimat pembuka 120, prestasi/peran/acara/subjudul/penyelenggara 300 karakter.
-- - Teks yang melebihi batas DITOLAK dengan pesan jelas (dulu dipotong diam-diam, sehingga
--   sertifikat tersimpan bisa berbeda dari pratinjau).
-- - Kalimat pembuka (lead-in) boleh kosong.
-- Jalankan seluruh isi file ini di SQL Editor (setelah 005). Aman dijalankan ulang.
-- ============================================================

-- Teks yang dirapikan (spasi/kontrol), lalu ditolak kalau lebih dari p_maks karakter.
create or replace function public.sertifikat_teks_batas(p_teks text, p_maks int, p_label text, p_baris text)
returns text
language plpgsql
immutable
as $$
declare v text := sertifikat_teks(p_teks, 100000);
begin
  if char_length(v) > p_maks then
    raise exception '% terlalu panjang (% karakter, maksimal %)%.', p_label, char_length(v), p_maks, p_baris;
  end if;
  return v;
end;
$$;

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
  v_role text; v_sub text; v_org text; v_conn text;
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
    v_nama := sertifikat_teks_batas(it ->> 'name', 120, 'Nama', baris);
    v_ach := sertifikat_teks_batas(it ->> 'ach', 300, 'Prestasi/peran', baris);
    v_role := sertifikat_teks_batas(it ->> 'role', 300, 'Peran', baris);
    v_event := sertifikat_teks_batas(it ->> 'event', 300, 'Acara', baris);
    v_sub := sertifikat_teks_batas(it ->> 'subtitle', 300, 'Subjudul', baris);
    v_org := sertifikat_teks_batas(it ->> 'organizer', 300, 'Penyelenggara', baris);
    v_conn := sertifikat_teks_batas(it ->> 'conn', 30, 'Kata penghubung', baris);
    v_mode := coalesce(it ->> 'mode', '');
    v_lead := jsonb_build_object('t', sertifikat_teks_batas(it -> 'lead' ->> 't', 120, 'Kalimat pembuka', baris),
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
            jsonb_build_object('lead', v_lead, 'conn', v_conn, 'ach', v_ach, 'role', v_role, 'event', v_event,
                               'subtitle', v_sub, 'organizer', v_org, 'mode', v_mode, 'd1', v_d1, 'd2', v_d2, 'ay', v_ay),
            v_terbit, st.ttd_kiri, st.ttd_kanan, v_admin, p_id_permintaan)
    returning * into s;

    keluar := keluar || jsonb_build_array(sertifikat_json(s));
    logs := logs || jsonb_build_array(sertifikat_catat(v_admin, 'Issued', v_nomor,
      case when v_jenis = 'achievement' then 'Certificate of Achievement' else 'Certificate of Appreciation' end
      || ' · ' || left(coalesce(nullif(v_event, ''), v_ach), 200)));
  end loop;

  return jsonb_build_object(
    'records', keluar,
    'logs', logs,
    'sigs', coalesce((select jsonb_object_agg(t.id::text, sertifikat_ttd_json(t)) from sertifikat_ttd t where t.id in (st.ttd_kiri, st.ttd_kanan)), '{}'::jsonb));
end;
$$;

revoke all on function public.terbitkan_sertifikat(jsonb, text) from public, anon;
grant execute on function public.terbitkan_sertifikat(jsonb, text) to authenticated;

notify pgrst, 'reload schema';
select 'Batas teks sertifikat sudah diperbarui' as hasil;
