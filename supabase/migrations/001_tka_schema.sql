-- =====================================================================
-- TKA Chatbot — Schema Supabase (Postgres)
-- Modul latihan TKA + leaderboard + pop-up, terintegrasi web surat.
-- Semua tabel diberi prefix tka_ agar tidak bentrok dengan tabel web surat.
--
-- Identitas siswa: TANPA LOGIN. Siswa hanya mengisi Nama + NIS (sekali,
-- disimpan di localStorage browser), dikirim di header tiap request API.
-- Server percaya begitu saja (sama seperti field "Student ID/NIS" yang
-- sudah dipakai di form-form lain web surat ini) — tka_pengguna.user_id
-- menyimpan NIS tsb sebagai teks, BUKAN uuid auth.users lagi.
--
-- Admin TKA = admin web surat yang sudah ada (Supabase Auth, dibuat lewat
-- Authentication > Users di README utama). Tidak ada peran admin terpisah
-- di tabel ini — endpoint /api/tka-admin/* memverifikasi lewat sesi
-- Supabase Auth yang sama dengan login Dashboard Admin di index.html.
--
-- Prinsip keamanan:
--   * Kunci jawaban (tka_soal.kunci) TIDAK PERNAH bisa dibaca langsung oleh
--     browser. Semua akses tabel TKA lewat API server (service role key),
--     RLS diaktifkan tanpa policy apapun untuk anon/authenticated (default
--     deny) — konsisten dengan tidak adanya sesi login siswa.
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- ENUM
-- ---------------------------------------------------------------------
do $$ begin
  create type tka_kelompok    as enum ('wajib', 'pilihan');
  create type tka_kesulitan   as enum ('mudah', 'sedang', 'sulit');
  create type tka_bentuk      as enum ('pg', 'pg_kompleks', 'kategori');
  create type tka_sumber      as enum ('admin', 'ai', 'resmi');
  create type tka_status_soal as enum ('draf', 'valid', 'arsip');
  create type tka_mode        as enum ('popup', 'latihan', 'tryout');
  create type tka_aksi_popup  as enum ('tampil', 'dijawab', 'mulai_latihan', 'ditutup');
  create type tka_status_lap  as enum ('baru', 'ditinjau', 'diperbaiki', 'ditolak');
exception when duplicate_object then null; end $$;

-- ---------------------------------------------------------------------
-- PENGGUNA (siswa) — user_id = NIS (teks), diisi sendiri lewat browser
-- ---------------------------------------------------------------------
create table if not exists tka_pengguna (
  user_id        text primary key,     -- NIS
  nama           text not null,
  kelas          text,                 -- contoh: 'XII-A'
  angkatan       int,                  -- contoh: 2027 (tahun lulus)
  nama_tampilan  text,                 -- nama di leaderboard (opsional)
  anonim         boolean not null default false,
  created_at     timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- MAPEL
-- ---------------------------------------------------------------------
create table if not exists tka_mapel (
  id              serial primary key,
  kode            text unique not null,     -- 'MTK', 'BIN', 'BIG', ...
  nama            text not null,
  kelompok        tka_kelompok not null,
  jumlah_soal_tka int,                      -- jumlah soal di TKA asli
  durasi_menit    int,                      -- durasi di TKA asli
  aktif           boolean not null default true,
  urutan          int not null default 0
);

-- Mapel pilihan per siswa (maks. 2)
create table if not exists tka_pilihan_mapel (
  user_id  text references tka_pengguna(user_id) on delete cascade,
  mapel_id int  references tka_mapel(id) on delete cascade,
  primary key (user_id, mapel_id)
);

create or replace function tka_cek_maks_pilihan() returns trigger
language plpgsql as $$
begin
  if (select kelompok from tka_mapel where id = new.mapel_id) <> 'pilihan' then
    raise exception 'Mapel ini bukan mapel pilihan';
  end if;
  if (select count(*) from tka_pilihan_mapel where user_id = new.user_id) >= 2 then
    raise exception 'Maksimal 2 mapel pilihan';
  end if;
  return new;
end $$;

drop trigger if exists trg_tka_maks_pilihan on tka_pilihan_mapel;
create trigger trg_tka_maks_pilihan before insert on tka_pilihan_mapel
  for each row execute function tka_cek_maks_pilihan();

-- ---------------------------------------------------------------------
-- BANK SOAL
-- Format opsi/kunci per bentuk:
--   pg          opsi  = [{"id":"A","teks":"..."}, ...]      kunci = ["B"]
--   pg_kompleks opsi  = [{"id":"A","teks":"..."}, ...]      kunci = ["A","C"]
--   kategori    opsi  = [{"id":"1","teks":"pernyataan"},..] kunci = {"1":true,"2":false}
-- dibuat_oleh → admin (Supabase Auth uuid), BUKAN tka_pengguna.
-- ---------------------------------------------------------------------
create table if not exists tka_soal (
  id           uuid primary key default gen_random_uuid(),
  mapel_id     int not null references tka_mapel(id),
  topik        text not null,
  subtopik     text,
  kesulitan    tka_kesulitan not null default 'sedang',
  bentuk       tka_bentuk not null default 'pg',
  stimulus     text,                 -- teks bacaan / data / gambar (URL) pendukung
  pertanyaan   text not null,
  opsi         jsonb not null,
  kunci        jsonb not null,
  pembahasan   text,                 -- pembahasan resmi (divalidasi admin)
  sumber       tka_sumber not null default 'admin',
  status       tka_status_soal not null default 'draf',
  soal_harian  boolean not null default false,  -- boleh tampil di pop-up
  dibuat_oleh  uuid references auth.users(id) on delete set null,
  divalidasi_at timestamptz,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index if not exists idx_tka_soal_mapel on tka_soal (mapel_id, status, kesulitan);
create index if not exists idx_tka_soal_harian on tka_soal (soal_harian) where status = 'valid';

-- ---------------------------------------------------------------------
-- TRYOUT
-- ---------------------------------------------------------------------
create table if not exists tka_tryout (
  id           uuid primary key default gen_random_uuid(),
  mapel_id     int not null references tka_mapel(id),
  judul        text not null,
  durasi_menit int not null,
  dibuka_at    timestamptz not null,
  ditutup_at   timestamptz not null,
  aktif        boolean not null default true,
  created_at   timestamptz not null default now()
);

create table if not exists tka_tryout_soal (
  tryout_id uuid references tka_tryout(id) on delete cascade,
  soal_id   uuid references tka_soal(id),
  urutan    int not null,
  primary key (tryout_id, soal_id)
);

-- ---------------------------------------------------------------------
-- PERIODE LEADERBOARD (musim; poin 1 soal hanya dihitung sekali per periode)
-- ---------------------------------------------------------------------
create table if not exists tka_periode (
  id       serial primary key,
  nama     text not null,          -- contoh: 'Semester Ganjil 2026/2027'
  mulai    date not null,
  selesai  date not null,
  aktif    boolean not null default false
);
create unique index if not exists uq_tka_periode_aktif on tka_periode (aktif) where aktif;

-- ---------------------------------------------------------------------
-- SESI & JAWABAN
-- ---------------------------------------------------------------------
create table if not exists tka_sesi (
  id          uuid primary key default gen_random_uuid(),
  user_id     text not null references tka_pengguna(user_id) on delete cascade,
  mapel_id    int  not null references tka_mapel(id),
  mode        tka_mode not null,
  tryout_id   uuid references tka_tryout(id),
  soal_ids    uuid[] not null default '{}',   -- urutan soal yang diberikan
  mulai_at    timestamptz not null default now(),
  selesai_at  timestamptz,
  skor        numeric(6,2),                   -- 0–100 untuk tryout
  total_poin  numeric(8,2) not null default 0
);
create index if not exists idx_tka_sesi_user on tka_sesi (user_id, mulai_at desc);
-- Tryout hanya sekali untuk peringkat
create unique index if not exists uq_tka_tryout_sekali on tka_sesi (user_id, tryout_id) where mode = 'tryout';

create table if not exists tka_jawaban (
  id            uuid primary key default gen_random_uuid(),
  sesi_id       uuid not null references tka_sesi(id) on delete cascade,
  user_id       text not null references tka_pengguna(user_id) on delete cascade,
  soal_id       uuid not null references tka_soal(id),
  mapel_id      int  not null references tka_mapel(id),
  periode_id    int  references tka_periode(id),
  jawaban       jsonb not null,
  benar         boolean not null,
  durasi_detik  int,
  poin          numeric(6,2) not null default 0,
  catatan_poin  text,              -- alasan 0 poin: 'sudah_pernah', 'terlalu_cepat', 'batas_harian'
  dijawab_at    timestamptz not null default now(),
  unique (sesi_id, soal_id)
);
create index if not exists idx_tka_jawaban_lb on tka_jawaban (mapel_id, dijawab_at) where poin > 0;
create index if not exists idx_tka_jawaban_user on tka_jawaban (user_id, soal_id);
-- Satu soal hanya memberi poin sekali per periode
create unique index if not exists uq_tka_poin_sekali on tka_jawaban (user_id, soal_id, periode_id) where poin > 0;

-- Streak harian (dihitung ulang tiap siswa menjawab)
create table if not exists tka_streak (
  user_id           text primary key references tka_pengguna(user_id) on delete cascade,
  streak_hari       int not null default 0,
  terbaik           int not null default 0,
  terakhir_latihan  date
);

-- ---------------------------------------------------------------------
-- POP-UP
-- ---------------------------------------------------------------------
create table if not exists tka_popup_pengaturan (
  id               int primary key default 1 check (id = 1),   -- satu baris saja
  aktif            boolean not null default true,
  judul            text not null default 'Yuk latihan TKA hari ini!',
  pesan            text[] not null default array[
    'Halo {nama}! TKA tinggal {hari} hari lagi — coba 1 soal dulu.',
    'Streak kamu {streak} hari, jangan sampai putus!',
    'Kamu peringkat {peringkat} di {mapel}. Tambah poinmu hari ini!'
  ],
  target_angkatan  int[],            -- null = semua angkatan
  tanggal_mulai    date,
  tanggal_selesai  date,
  tanggal_tka      date,             -- untuk hitung mundur
  mapel_harian_id  int references tka_mapel(id),   -- null = acak dari mapel siswa
  updated_at       timestamptz not null default now()
);
insert into tka_popup_pengaturan (id) values (1) on conflict do nothing;

create table if not exists tka_popup_log (
  id          bigserial primary key,
  user_id     text not null references tka_pengguna(user_id) on delete cascade,
  tanggal     date not null default (now() at time zone 'Asia/Jakarta')::date,
  aksi        tka_aksi_popup not null,
  soal_id     uuid references tka_soal(id),
  created_at  timestamptz not null default now(),
  unique (user_id, tanggal, aksi)
);

-- ---------------------------------------------------------------------
-- LAPORAN SOAL, AI LOG, CACHE, LENCANA
-- tka_ai_log.user_id: NIS siswa ATAU uuid admin (teks bebas) — tabel log,
-- sengaja tanpa FK supaya bisa menampung kedua jenis pemanggil.
-- ---------------------------------------------------------------------
create table if not exists tka_laporan_soal (
  id            uuid primary key default gen_random_uuid(),
  soal_id       uuid not null references tka_soal(id) on delete cascade,
  user_id       text not null references tka_pengguna(user_id) on delete cascade,
  alasan        text not null,
  status        tka_status_lap not null default 'baru',
  catatan_admin text,
  created_at    timestamptz not null default now()
);

create table if not exists tka_ai_log (
  id          bigserial primary key,
  user_id     text,                  -- NIS siswa atau uuid admin, tanpa FK (lihat catatan di atas)
  jenis       text not null,         -- 'pembahasan', 'chat', 'generate_soal'
  soal_id     uuid,
  token_in    int,
  token_out   int,
  created_at  timestamptz not null default now()
);
create index if not exists idx_tka_ai_log_user on tka_ai_log (user_id, created_at);

create table if not exists tka_pembahasan_cache (
  soal_id       uuid references tka_soal(id) on delete cascade,
  jawaban_hash  text,                -- md5 dari jawaban siswa (jawaban salah yang sama → penjelasan sama)
  teks          text not null,
  created_at    timestamptz not null default now(),
  primary key (soal_id, jawaban_hash)
);

create table if not exists tka_lencana (
  kode       text primary key,
  nama       text not null,
  deskripsi  text
);

create table if not exists tka_lencana_siswa (
  user_id      text references tka_pengguna(user_id) on delete cascade,
  kode         text references tka_lencana(kode),
  periode_id   int references tka_periode(id),
  diberikan_at timestamptz not null default now(),
  primary key (user_id, kode, periode_id)
);

-- =====================================================================
-- FUNGSI
-- =====================================================================

-- Leaderboard per mapel (mapel_id null = total semua mapel). p_user (NIS)
-- selalu diisi oleh API — tidak ada auth.uid() karena tidak ada sesi siswa.
create or replace function tka_leaderboard(
  p_mapel_id int default null,
  p_rentang  text default 'minggu',
  p_kelas    text default null,
  p_angkatan int default null,
  p_limit    int default 10,
  p_user     text default null
) returns table (
  peringkat   bigint,
  user_id     text,
  nama        text,
  kelas       text,
  total_poin  numeric,
  soal_benar  bigint,
  saya        boolean
)
language sql stable security definer set search_path = public as $$
  with batas as (
    select case p_rentang
      when 'minggu' then date_trunc('week',  now() at time zone 'Asia/Jakarta')
      when 'bulan'  then date_trunc('month', now() at time zone 'Asia/Jakarta')
      else (select mulai::timestamp from tka_periode where aktif limit 1)
    end as dari
  ),
  skor as (
    select j.user_id, sum(j.poin) as total_poin, count(*) filter (where j.benar) as soal_benar
    from tka_jawaban j, batas b
    where j.poin > 0
      and (p_mapel_id is null or j.mapel_id = p_mapel_id)
      and (b.dari is null or (j.dijawab_at at time zone 'Asia/Jakarta') >= b.dari)
      and (p_rentang <> 'periode' or j.periode_id = (select id from tka_periode where aktif limit 1))
    group by j.user_id
  ),
  urut as (
    select rank() over (order by s.total_poin desc, s.soal_benar desc) as peringkat,
           s.user_id,
           case when p.anonim then 'Siswa #' || left(md5(p.user_id), 4)
                else coalesce(p.nama_tampilan, p.nama) end as nama,
           p.kelas, s.total_poin, s.soal_benar,
           s.user_id = p_user as saya
    from skor s join tka_pengguna p on p.user_id = s.user_id
    where (p_kelas is null or p.kelas = p_kelas)
      and (p_angkatan is null or p.angkatan = p_angkatan)
  )
  select * from urut
  where peringkat <= p_limit or saya
  order by peringkat;
$$;

-- Perbarui streak setelah siswa menjawab (dipanggil dari API)
create or replace function tka_update_streak(p_user text) returns int
language plpgsql security definer set search_path = public as $$
declare
  hari_ini date := (now() at time zone 'Asia/Jakarta')::date;
  r tka_streak%rowtype;
  baru int;
begin
  select * into r from tka_streak where user_id = p_user for update;
  if not found then
    insert into tka_streak (user_id, streak_hari, terbaik, terakhir_latihan) values (p_user, 1, 1, hari_ini);
    return 1;
  end if;
  if r.terakhir_latihan = hari_ini then
    return r.streak_hari;
  elsif r.terakhir_latihan = hari_ini - 1 then
    baru := r.streak_hari + 1;
  else
    baru := 1;
  end if;
  update tka_streak set streak_hari = baru, terbaik = greatest(terbaik, baru), terakhir_latihan = hari_ini
  where user_id = p_user;
  return baru;
end $$;

-- Poin hari ini per mapel (untuk batas harian anti-farming)
create or replace function tka_poin_hari_ini(p_user text, p_mapel int) returns numeric
language sql stable security definer set search_path = public as $$
  select coalesce(sum(poin), 0) from tka_jawaban
  where user_id = p_user and mapel_id = p_mapel
    and (dijawab_at at time zone 'Asia/Jakarta')::date = (now() at time zone 'Asia/Jakarta')::date;
$$;

-- Dashboard admin: kesiapan per mapel & topik
create or replace view tka_v_rekap_topik as
select m.nama as mapel, s.topik,
       count(*) as dijawab,
       round(100.0 * avg(case when j.benar then 1 else 0 end), 1) as persen_benar,
       count(distinct j.user_id) as jumlah_siswa
from tka_jawaban j
join tka_soal s  on s.id = j.soal_id
join tka_mapel m on m.id = j.mapel_id
group by m.nama, s.topik;

create or replace view tka_v_popup_harian as
select tanggal,
       count(*) filter (where aksi = 'tampil')        as tampil,
       count(*) filter (where aksi = 'dijawab')       as dijawab,
       count(*) filter (where aksi = 'mulai_latihan') as mulai_latihan,
       count(*) filter (where aksi = 'ditutup')       as ditutup
from tka_popup_log group by tanggal;

-- View hanya boleh diakses service role (admin lewat API)
revoke all on tka_v_rekap_topik, tka_v_popup_harian from anon, authenticated;

-- =====================================================================
-- ROW LEVEL SECURITY
-- Tidak ada sesi login siswa (anon key saja) dan tidak ada policy publik
-- di tabel manapun — SEMUA akses (baca & tulis) lewat API server (service
-- role, yang otomatis melewati RLS). Ini sekadar lapis pertahanan kedua.
-- =====================================================================
alter table tka_pengguna          enable row level security;
alter table tka_mapel             enable row level security;
alter table tka_pilihan_mapel     enable row level security;
alter table tka_soal              enable row level security;
alter table tka_tryout            enable row level security;
alter table tka_tryout_soal       enable row level security;
alter table tka_periode           enable row level security;
alter table tka_sesi              enable row level security;
alter table tka_jawaban           enable row level security;
alter table tka_streak            enable row level security;
alter table tka_popup_pengaturan  enable row level security;
alter table tka_popup_log         enable row level security;
alter table tka_laporan_soal      enable row level security;
alter table tka_ai_log            enable row level security;
alter table tka_pembahasan_cache  enable row level security;
alter table tka_lencana           enable row level security;
alter table tka_lencana_siswa     enable row level security;

revoke execute on function tka_leaderboard(int, text, text, int, int, text) from anon, authenticated, public;
revoke execute on function tka_update_streak(text) from anon, authenticated, public;
revoke execute on function tka_poin_hari_ini(text, int) from anon, authenticated, public;
