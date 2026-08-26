# Layanan Surat Siswa — UPH College

Website satu-file (`index.html`) untuk pengajuan surat siswa, dengan database Supabase dan hosting Vercel via GitHub.

## Ringkasan Peran Tiap Layanan

- **GitHub** — tempat nyimpen kode ini (repo), sumber yang dibaca Vercel tiap kali kamu update.
- **Supabase** — database beneran (pengganti `window.storage`), nyimpen semua data permintaan surat + pengaturan, dan login admin.
- **Vercel** — hosting: mengambil kode dari GitHub dan mempublikasikannya jadi URL publik (mis. `surat-siswa.vercel.app`). Setiap kamu push ke GitHub, Vercel deploy ulang otomatis.

## Langkah 1 — Setup Supabase

1. Buka [supabase.com](https://supabase.com), daftar/masuk, klik **New Project**.
2. Beri nama project (mis. `surat-siswa`), set password database (simpan baik-baik), pilih region terdekat (Singapore), klik **Create**. Tunggu ~2 menit sampai project siap.
3. Di sidebar kiri, buka **SQL Editor** → **New query**. Salin seluruh isi file [`schema.sql`](schema.sql) di folder ini, tempel, klik **Run**.
   - Ini bikin tabel `requests` & `settings`, view `requests_public` (data terbatas buat publik), dan aturan keamanan (RLS) supaya siswa cuma bisa kirim & lihat status, sementara data lengkap (catatan admin, teks surat, dll) cuma bisa diakses admin yang sudah login.
4. Buat akun admin: buka **Authentication** → **Users** → **Add user** → **Create new user**. Isi email (mis. `admin@uphcollege.com`) dan password. Ini yang dipakai buat login ke Dashboard Admin di website nanti — **bukan** PIN lagi.
5. Catat **Project URL** dan API key-nya. Dua cara:
   - **Tercepat:** klik tombol **Connect** (kanan atas halaman project) — Project URL & key langsung muncul di situ.
   - **Atau:** ikon gerigi (⚙️) → **Settings** → **API Keys**. Ada 2 tab: **New Keys** (ambil **Publishable key**) atau **Legacy API Keys** (ambil **anon public**) — pakai salah satu saja, keduanya berfungsi sama untuk kode di `index.html` ini.

## Langkah 2 — Isi Konfigurasi di `index.html`

Buka [`index.html`](index.html), cari bagian ini di paling atas `<script>`:

```js
var SUPABASE_URL = 'ISI_DENGAN_SUPABASE_PROJECT_URL';
var SUPABASE_ANON_KEY = 'ISI_DENGAN_SUPABASE_ANON_PUBLIC_KEY';
```

Ganti dengan **Project URL** dan **anon public key** dari Langkah 1.5. Simpan file.

> Catatan: `anon public key` memang didesain untuk ditaruh di kode sisi client (bukan rahasia) — keamanan sebenarnya dijaga oleh aturan RLS yang sudah di-setup di `schema.sql`, bukan dengan menyembunyikan key ini.

## Langkah 3 — Push ke GitHub

Dari folder ini:

```bash
git init
git add index.html schema.sql README.md
git commit -m "Setup layanan surat siswa dengan Supabase"
```

Lalu buat repo baru di [github.com/new](https://github.com/new) (bisa **Private**), dan ikuti instruksi "push an existing repository":

```bash
git remote add origin https://github.com/USERNAME/NAMA-REPO.git
git branch -M main
git push -u origin main
```

## Langkah 4 — Deploy ke Vercel

1. Buka [vercel.com](https://vercel.com), **Sign Up** pakai akun GitHub kamu (biar otomatis terhubung).
2. Klik **Add New** → **Project**, pilih repo yang baru kamu push.
3. Karena ini cuma HTML statis (tidak ada build step), biarkan pengaturan default — Framework Preset: **Other**. Klik **Deploy**.
4. Setelah selesai (~30 detik), kamu dapat URL publik seperti `nama-repo.vercel.app`. Itu link yang dibagikan ke siswa.

Setiap kali kamu `git push` perubahan baru ke GitHub, Vercel otomatis deploy ulang versi terbaru.

## Setelah Live

- Login admin lewat tombol **Admin** di halaman utama, pakai email & password yang dibuat di Langkah 1.4.
- Kalau mau nambah admin lain, ulangi Langkah 1.4 (Authentication → Users → Add user) — tidak perlu ubah kode.
- Kalau mau ganti info rekening / nomor surat berikutnya, itu diatur dari dalam Dashboard Admin (tombol "Pengaturan"), bukan di kode.
