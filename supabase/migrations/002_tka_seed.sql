-- Seed data referensi TKA SMA 2026
-- Jumlah soal & durasi mengikuti pedoman TKA 2026 (cek ulang ke laman resmi Pusmendik).

insert into tka_mapel (kode, nama, kelompok, jumlah_soal_tka, durasi_menit, urutan) values
  ('BIN',  'Bahasa Indonesia',          'wajib',   30, 75,  1),
  ('MTK',  'Matematika',                'wajib',   25, 75,  2),
  ('BIG',  'Bahasa Inggris',            'wajib',   30, 75,  3),
  ('MTKL', 'Matematika Tingkat Lanjut', 'pilihan', 25, 60, 10),
  ('FIS',  'Fisika',                    'pilihan', 25, 60, 11),
  ('KIM',  'Kimia',                     'pilihan', 25, 60, 12),
  ('BIO',  'Biologi',                   'pilihan', 25, 60, 13),
  ('EKO',  'Ekonomi',                   'pilihan', 25, 60, 14),
  ('SOS',  'Sosiologi',                 'pilihan', 25, 60, 15),
  ('GEO',  'Geografi',                  'pilihan', 25, 60, 16),
  ('SEJ',  'Sejarah',                   'pilihan', 25, 60, 17),
  ('JPN',  'Bahasa Jepang',             'pilihan', 25, 60, 18),
  ('MAN',  'Bahasa Mandarin',           'pilihan', 25, 60, 19),
  ('KOR',  'Bahasa Korea',              'pilihan', 25, 60, 20),
  ('ARB',  'Bahasa Arab',               'pilihan', 25, 60, 21),
  ('PRA',  'Bahasa Prancis',            'pilihan', 25, 60, 22),
  ('JER',  'Bahasa Jerman',             'pilihan', 25, 60, 23)
on conflict (kode) do nothing;

insert into tka_periode (nama, mulai, selesai, aktif) values
  ('Persiapan TKA 2026', '2026-09-28', '2026-11-08', true)
on conflict do nothing;

update tka_popup_pengaturan set tanggal_tka = '2026-10-26', tanggal_mulai = '2026-09-28', tanggal_selesai = '2026-11-08' where id = 1;

insert into tka_lencana (kode, nama, deskripsi) values
  ('STREAK_7',    'Streak 7 Hari',   'Latihan 7 hari berturut-turut'),
  ('TRYOUT_90',   'Tryout 90+',      'Skor tryout minimal 90'),
  ('TOP1_MAPEL',  'Master Mapel',    'Peringkat 1 leaderboard mapel dalam satu periode'),
  ('SOAL_100',    '100 Soal Benar',  'Menjawab benar 100 soal')
on conflict do nothing;

-- Contoh soal (status valid agar bisa langsung dites)
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian)
select id, 'Aljabar', 'mudah', 'pg',
  'Jika 3x − 7 = 11, maka nilai x adalah ...',
  '[{"id":"A","teks":"4"},{"id":"B","teks":"5"},{"id":"C","teks":"6"},{"id":"D","teks":"7"},{"id":"E","teks":"8"}]',
  '["C"]',
  '3x − 7 = 11 → 3x = 18 → x = 6.',
  'admin', 'valid', true
from tka_mapel where kode = 'MTK';

insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian)
select id, 'Teks eksposisi', 'sedang', 'kategori',
  'Sampah plastik di laut meningkat setiap tahun. Sebagian besar berasal dari daratan yang terbawa sungai.',
  'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
  '[{"id":"1","teks":"Sampah plastik di laut berkurang setiap tahun."},{"id":"2","teks":"Sungai menjadi jalur masuk sampah ke laut."}]',
  '{"1":false,"2":true}',
  'Teks menyebut sampah meningkat (pernyataan 1 salah) dan berasal dari daratan yang terbawa sungai (pernyataan 2 benar).',
  'admin', 'valid', true
from tka_mapel where kode = 'BIN';

-- Tidak perlu langkah "jadikan admin" terpisah: siapa pun yang sudah bisa
-- login ke Dashboard Admin web surat (Supabase Auth, dibuat lewat
-- Authentication > Users) otomatis punya akses Admin TKA juga.
