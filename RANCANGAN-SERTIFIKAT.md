# Rancangan: Sertifikat UPH College di surat-siswa (Supabase + Vercel)

Status: **sudah dibuat (23 Nov 2026), menunggu SQL dijalankan di Supabase.** Semua usulan di bagian 8 disetujui Danny.

## Cara memasang (sekali saja)

1. **Jalankan SQL.** Buka Supabase → SQL Editor → New query, tempel seluruh isi
   [`supabase/migrations/005_sertifikat.sql`](supabase/migrations/005_sertifikat.sql), lalu klik **Run**. Aman dijalankan ulang.
   Lalu, di query kosong yang baru, jalankan juga [`006_sertifikat_batas_teks.sql`](supabase/migrations/006_sertifikat_batas_teks.sql)
   (narasi sampai 300 karakter, kalimat pembuka boleh kosong, teks kepanjangan ditolak — bukan dipotong).
2. **Beri akses** ke akun yang boleh menerbitkan (ganti emailnya), lalu **Run**:
   ```sql
   update auth.users
   set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"sertifikat_admin": true}'::jsonb
   where email = 'EMAIL_ADMIN_DI_SINI';
   ```
3. **Logout lalu login lagi** di dashboard surat. Tombol **Sertifikat ↗** akan muncul di baris tab admin (atau buka `https://surat-siswa.vercel.app/sertifikat/`).
4. Di **Admin**, isi kedua penanda tangan dan unggah TTD-nya (file ada di `Project surat\sertifikat-uph\tanda-tangan\`).
5. Terbitkan satu sertifikat uji, pindai QR-nya (harus membuka `surat-siswa.vercel.app/cek/#…` dan bertuliskan **Sertifikat Sah**), lalu Void dan pindai lagi (**Sertifikat Dibatalkan**).

## Uji di komputer sendiri

PGlite (Postgres dalam Node) dipasang di luar repo supaya tidak ikut ke Vercel:

```
npm install --prefix <folder> @electric-sql/pglite@0.2.17
PGLITE_DIR=<folder> node tests/sertifikat/uji-sql.mjs          # 55 pemeriksaan SQL
node tests/sertifikat/mock-supabase.mjs 5800 <folder>             # Supabase tiruan + halaman di http://localhost:5800/
```

`mock-supabase.mjs` membuat dua akun uji di `tests/sertifikat/.akun-uji.json` (tidak di-commit): satu dengan akses sertifikat, satu tanpa.
Folder `tests/` tidak ikut tayang di Vercel (`.vercelignore`).

## 1. Tujuan

Memindahkan sistem sertifikat dari **Netlify + Google Apps Script + Google Sheet** ke infrastruktur yang sudah dipakai surat-siswa:

- **Supabase** (proyek `jxyfiinqxeswyljmzhge`): data, login admin, penomoran, dan cek QR.
- **Vercel** (`surat-siswa.vercel.app`): hosting halaman. Terhubung otomatis ke GitHub, jadi setiap *push* langsung tayang.

Dengan begitu tidak ada lagi Netlify, Apps Script, maupun kunci admin di Google Sheet. Admin cukup memakai satu akun Supabase yang sama dengan dashboard surat.

Kebutuhan inti: **TTD, QR yang bisa dicek keasliannya, dan tanggal terbit.**

## 2. Gambaran besar

```
 Admin (sudah login di surat-siswa)            Siapa pun yang memindai QR
          │                                              │
          ▼                                              ▼
 surat-siswa.vercel.app/sertifikat/          surat-siswa.vercel.app/cek/#<token>
 (buat, cetak, kelola, void)                 (halaman kecil, cepat, tanpa login)
          │  supabase-js, sesi login yang sama            │  rpc cek_sertifikat(token)
          ▼                                              ▼
 ┌──────────────────────────── Supabase ─────────────────────────────┐
 │ sertifikat · sertifikat_ttd · sertifikat_setelan · sertifikat_log │
 │ RLS: hanya akun bertanda app_metadata.sertifikat_admin            │
 │ RPC: terbitkan_sertifikat, batalkan_sertifikat (admin)            │
 │      cek_sertifikat (publik, data terbatas)                       │
 └───────────────────────────────────────────────────────────────────┘
```

Dua halaman baru, terpisah dari `index.html` utama (yang sudah sekitar 350 KB):

| Halaman | Isi | Asal kode |
|---|---|---|
| `sertifikat/index.html` | Dashboard admin: Create, Manage, History, Admin | Dipindahkan dari dashboard Netlify yang sudah diuji. Hanya lapisan `api()` dan login yang diganti ke Supabase. |
| `cek/index.html` | Halaman QR publik | Baru dan kecil (±15 KB), sehingga cepat dibuka di HP. |

Ketiga halaman (`/`, `/sertifikat/`, `/cek/`) berada di domain yang sama, sehingga sesi login Supabase ikut terbawa. Admin yang sudah login di dashboard surat tidak perlu login lagi.

## 3. Database (migrasi `supabase/migrations/005_sertifikat.sql`)

### Tabel

**`sertifikat`**: satu baris untuk setiap sertifikat yang diterbitkan.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `token` | text, PK | 24 karakter acak, dibuat di server (`gen_random_bytes`). Inilah isi QR. |
| `nomor` | text, unique | Contoh: `0001/CERT/UPHC/XI/2026` |
| `tahun`, `urut` | int | Unique (`tahun`, `urut`). Penomoran per tahun. |
| `jenis` | text | `appreciation` / `achievement` |
| `nama` | text | Nama penerima |
| `isi` | jsonb | Kalimat sertifikat: lead, conn, ach, role, event, subtitle, organizer, mode tanggal, d1, d2, ay |
| `tanggal_terbit` | date | Tanggal terbit (tipe `date`, bukan teks, jadi tidak bisa bergeser karena zona waktu) |
| `ttd_kiri`, `ttd_kanan` | bigint → `sertifikat_ttd.id` | Versi TTD yang berlaku saat sertifikat diterbitkan |
| `status` | text | `valid` / `batal` |
| `alasan_batal`, `dibatalkan_oleh`, `dibatalkan_pada` | | Diisi saat void |
| `dibuat_oleh`, `dibuat_pada` | | Email admin dan waktu terbit |
| `id_permintaan` | text | Penanda unik untuk satu kali klik "Issue". Mencegah sertifikat ganda kalau admin mencoba ulang setelah koneksi putus. |

**`sertifikat_ttd`**: setiap kali TTD disimpan, dibuat satu versi baru. Sertifikat lama tetap memakai TTD versi lamanya.
Kolom: `id`, `sisi` (kiri/kanan), `nama`, `jabatan`, `gambar` (data URL PNG, maksimal 1 MB), `dibuat_pada`, `dibuat_oleh`.

**`sertifikat_setelan`**: tabel satu baris berisi `unit` ('CERT'), `nomor_mulai`, `tahun_mulai`, `frasa` (jsonb: kalimat pembuka dan penghubung), `ttd_kiri_aktif`, `ttd_kanan_aktif`.

**`sertifikat_log`**: riwayat. Kolom: `at`, `oleh`, `aksi`, `nomor`, `detail`.

### Keamanan (RLS)

- Semua tabel di atas: **anon tidak bisa membaca maupun menulis.** Akun `authenticated` hanya boleh mengakses kalau memiliki `app_metadata.sertifikat_admin = true`.
  - Tanda ini diset lewat SQL, sama seperti `surat_admin`, sehingga tidak bisa diubah sendiri oleh pemilik akun.
  - Tanda yang terpisah dari `surat_admin` memungkinkan staf lain (misalnya panitia acara) menerbitkan sertifikat **tanpa** bisa melihat data surat siswa, dan sebaliknya.
- Menerbitkan dan membatalkan **hanya lewat RPC** `security definer`, bukan *insert/update* langsung. Dengan begitu:
  - penomoran berlangsung di dalam database dan dikunci (`pg_advisory_xact_lock(tahun)`), sehingga dua admin yang menekan Issue bersamaan tidak mendapat nomor yang sama;
  - data divalidasi di server (panjang teks, format tanggal, maksimal 100 orang per batch);
  - log selalu tercatat.
- Gambar TTD divalidasi di server: hanya `data:image/png|jpeg;base64,…`. Halaman juga menyaring ulang sebelum menampilkan gambar (sudah ada `safeImg()`).

### Fungsi (RPC)

| Fungsi | Siapa | Kerja |
|---|---|---|
| `terbitkan_sertifikat(p_items jsonb, p_id_permintaan text)` | sertifikat_admin | Validasi, beri nomor (terkunci), simpan, catat log, lalu kembalikan baris yang dibuat. Kalau `id_permintaan` sudah pernah dipakai, kembalikan baris lama (tidak membuat ganda). |
| `batalkan_sertifikat(p_token, p_alasan)` | sertifikat_admin | Alasan minimal 5 karakter. Menolak kalau sertifikat sudah batal. Catat log. |
| `simpan_ttd(p_sisi, p_nama, p_jabatan, p_gambar)` | sertifikat_admin | Membuat versi baru dan menjadikannya TTD aktif. |
| `simpan_setelan_sertifikat(...)` | sertifikat_admin | Nomor mulai tidak boleh di bawah nomor yang sudah terpakai, dan hanya berlaku untuk tahun berjalan. |
| `cek_sertifikat(p_token)` | **anon** | Mengembalikan **hanya**: nomor, nama, jenis, keterangan acara/prestasi, tanggal terbit, status, serta nama dan jabatan penanda tangan. **Tanpa** gambar TTD, pembuat, maupun alasan batal. |

Membaca daftar, riwayat, dan TTD untuk dashboard memakai `select` biasa yang dijaga RLS.

## 4. Halaman admin `sertifikat/`

Hasilnya sama dengan dashboard Netlify yang sudah diuji (pratinjau sertifikat, batch dari Excel, cetak/PDF, void, riwayat), dengan perubahan berikut:

- **Login:** memakai Supabase Auth yang sama dengan dashboard surat. Kalau belum login, muncul form email dan kata sandi. Kalau sudah login tapi tidak memiliki tanda `sertifikat_admin`, muncul pesan "Akun ini belum diberi akses sertifikat".
- **Lapisan data:** `api('issue')` diganti `sb.rpc('terbitkan_sertifikat')`, dan seterusnya untuk aksi lain. Sisa logika halaman tetap.
- **QR:** mengarah ke `https://surat-siswa.vercel.app/cek/#<token>`, alamat tetap yang ditulis di konfigurasi.
- **Bahasa:** tampilan sertifikat tetap berbahasa Inggris (*Certificate of Appreciation*). Menu dashboard bisa diubah ke Bahasa Indonesia kalau diinginkan.
- **Tautan:** dashboard surat mendapat tombol "Sertifikat" yang hanya muncul untuk akun yang memiliki tanda `sertifikat_admin`.

## 5. Halaman publik `cek/`

- Membaca token dari `#…`, lalu memanggil `cek_sertifikat`.
- Menampilkan salah satu dari tiga status: **Sertifikat Sah** (hijau), **Sertifikat Dibatalkan** (merah), atau **Tidak Ditemukan**. Bilingual (ID/EN), karena pemindai bisa saja pihak luar negeri.
- Detail yang ditampilkan:
  - nama;
  - jenis sertifikat;
  - acara/prestasi;
  - tanggal terbit;
  - nomor;
  - "Ditandatangani oleh: Hans Deny (Academic Principal), Wiginy Kusliawan (Executive Director)".
- **Tidak** menampilkan gambar TTD dan tidak ada tombol unduh. TTD hanya ada di sertifikat cetak. Ini mengurangi risiko TTD diambil lalu dipakai untuk memalsukan.
  *(Pilihan lain: tampilkan sertifikat lengkap seperti di Netlify. Silakan putuskan.)*

## 6. Yang terjadi pada sistem sekarang

Belum ada sertifikat yang dicetak dengan QR Netlify, jadi pindah sekarang tidak merugikan apa pun. Setelah versi Supabase tayang dan diuji:

1. Hapus proyek Netlify `sertifikat-uphc`. Alamatnya tidak dipakai di QR mana pun.
2. Arsipkan *deployment* Apps Script (Deploy → Manage deployments → Archive), lalu hapus Google Sheet-nya.
3. Folder `sertifikat-uph/` di komputer ini disimpan sebagai arsip.

## 7. Urutan kerja

1. **SQL** `005_sertifikat.sql`: tabel, RLS, RPC. Danny yang menjalankannya di SQL Editor (seperti 004), lalu memberi tanda `sertifikat_admin` ke akun yang berhak.
2. **`cek/index.html`**, lalu diuji dengan sertifikat contoh.
3. **`sertifikat/index.html`**: dipindahkan dari versi Netlify, dengan lapisan data dan login diganti.
4. **Uji di Supabase asli** dengan 2–3 sertifikat bertanda `UJI`. Setelah lolos, sertifikat uji dibatalkan atau dihapus (butuh persetujuan Danny karena menulis ke database produksi).
5. **Push ke `main`**: Vercel otomatis deploy.
6. Bersihkan Netlify, Apps Script, dan Sheet (bagian 6).

## 8. Keputusan yang perlu Danny ambil

| # | Pertanyaan | Usulan |
|---|---|---|
| 1 | Desain sertifikat dibuat **di web** (seperti sekarang), atau di **Canva/Word** sehingga web hanya mengeluarkan nomor + QR + TTD + tanggal? | **Di web.** Sudah jadi dan teruji. Mode Canva bisa ditambahkan nanti memakai database yang sama. |
| 2 | Siapa yang boleh menerbitkan? | Tanda baru `sertifikat_admin`, terpisah dari `surat_admin`. |
| 3 | Halaman QR menampilkan gambar TTD? | **Tidak.** Cukup data dan status. |
| 4 | Alamat QR: `surat-siswa.vercel.app/cek/` atau domain sekolah (misalnya `sertifikat.uphcollege.com`)? | Domain sekolah lebih awet. Kalau butuh waktu dengan IT, mulai dengan alamat Vercel. QR lama tetap jalan selama proyek Vercel tidak dihapus. |
| 5 | Paket proyek Supabase surat-siswa: gratis atau Pro? | **Perlu dicek.** Proyek gratis dijeda setelah sekitar seminggu tidak dipakai. Saat libur panjang, QR bisa tidak bisa dicek. Kalau gratis, pertimbangkan memindahkannya ke organisasi UPH College yang Pro. |

## 9. Risiko dan catatan

- **Tabel `requests` saat ini memberi akses penuh ke semua akun yang login**, termasuk akun guru dan finance. Ini di luar lingkup sertifikat dan tidak mempengaruhi rancangan ini, karena tabel sertifikat memakai tanda tersendiri. Tetapi sebaiknya diperketat suatu saat.
- Kunci *anon* Supabase memang ditaruh di halaman. Keamanan dijaga oleh RLS dan RPC, bukan dengan merahasiakan kunci.
- Ukuran gambar TTD dibatasi 1 MB per versi. Halaman sudah mengecilkan gambar menjadi PNG lebar 600 px (sekitar 20 KB).
