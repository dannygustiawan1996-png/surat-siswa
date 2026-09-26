-- Soal tambahan TKA (materi latihan orisinal, dibuat AI untuk keperluan demo/tugas kuliah)
-- Bukan naskah resmi Pusmendik/pemerintah. sumber = 'ai', status = 'valid' untuk semua baris.
-- 10 soal per mapel x 17 mapel = 170 baris.

-- =========================================================
-- BIN - Bahasa Indonesia
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='BIN'), 'Kaidah kebahasaan', 'mudah', 'pg', null,
 'Sinonim kata "opini" adalah ...',
 '[{"id":"A","teks":"Fakta"},{"id":"B","teks":"Pendapat"},{"id":"C","teks":"Data"},{"id":"D","teks":"Bukti"},{"id":"E","teks":"Kesimpulan"}]',
 '["B"]',
 'Opini bermakna pendapat atau pandangan pribadi, berbeda dengan fakta yang bersifat objektif.',
 'ai','valid', true),

((select id from tka_mapel where kode='BIN'), 'Kaidah kebahasaan', 'mudah', 'pg', null,
 'Kata berikut yang merupakan bentuk baku sesuai KBBI adalah ...',
 '[{"id":"A","teks":"Apotik"},{"id":"B","teks":"Apotek"},{"id":"C","teks":"Aptik"},{"id":"D","teks":"Apotiik"},{"id":"E","teks":"Apoteik"}]',
 '["B"]',
 'Menurut KBBI, bentuk baku yang benar adalah "apotek", bukan "apotik".',
 'ai','valid', false),

((select id from tka_mapel where kode='BIN'), 'Teks eksposisi', 'mudah', 'kategori',
 'Minat baca masyarakat Indonesia masih tergolong rendah dibandingkan negara-negara lain. Salah satu penyebabnya adalah kurangnya akses terhadap buku berkualitas di daerah terpencil.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
 '[{"id":"1","teks":"Minat baca masyarakat Indonesia tergolong tinggi."},{"id":"2","teks":"Akses buku di daerah terpencil menjadi salah satu penyebab rendahnya minat baca."}]',
 '{"1":false,"2":true}',
 'Teks menyatakan minat baca rendah (pernyataan 1 salah) dan kurangnya akses buku di daerah terpencil sebagai penyebab (pernyataan 2 benar).',
 'ai','valid', false),

((select id from tka_mapel where kode='BIN'), 'Kalimat efektif', 'sedang', 'pg', null,
 'Kalimat yang paling efektif di antara pilihan berikut adalah ...',
 '[{"id":"A","teks":"Bagi semua siswa-siswa harus mengumpulkan tugas."},{"id":"B","teks":"Menurut Kepala Sekolah mengatakan bahwa ujian akan diundur."},{"id":"C","teks":"Siswa yang tidak masuk sekolah harus membawa surat izin."},{"id":"D","teks":"Di dalam buku itu menceritakan tentang sejarah Indonesia."},{"id":"E","teks":"Bagi yang belum mengumpulkan tugas agar segera dikumpulkan."}]',
 '["C"]',
 'Kalimat C memiliki subjek dan predikat yang jelas tanpa pengulangan makna, sedangkan pilihan lain mengandung kata berlebihan atau subjek tidak jelas.',
 'ai','valid', true),

((select id from tka_mapel where kode='BIN'), 'Menyimpulkan isi teks', 'sedang', 'pg',
 'Penggunaan plastik sekali pakai terus meningkat di kota-kota besar. Padahal, sampah plastik membutuhkan waktu ratusan tahun untuk terurai secara alami. Beberapa pemerintah daerah mulai menerapkan larangan penggunaan kantong plastik di pusat perbelanjaan.',
 'Simpulan yang tepat berdasarkan teks tersebut adalah ...',
 '[{"id":"A","teks":"Plastik sudah tidak digunakan lagi di kota besar."},{"id":"B","teks":"Pemerintah daerah berupaya mengurangi penggunaan plastik sekali pakai."},{"id":"C","teks":"Sampah plastik dapat terurai dengan cepat."},{"id":"D","teks":"Larangan kantong plastik hanya berlaku di desa."},{"id":"E","teks":"Penggunaan plastik sekali pakai tidak berdampak pada lingkungan."}]',
 '["B"]',
 'Teks menjelaskan bahwa pemerintah daerah mulai melarang kantong plastik sebagai upaya mengurangi penggunaan plastik sekali pakai.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIN'), 'Teks argumentasi', 'sedang', 'pg_kompleks', null,
 'Berikut ini yang merupakan ciri-ciri teks argumentasi adalah ...',
 '[{"id":"A","teks":"Berisi pendapat yang disertai alasan dan bukti"},{"id":"B","teks":"Bertujuan meyakinkan pembaca"},{"id":"C","teks":"Hanya berisi urutan peristiwa secara kronologis"},{"id":"D","teks":"Menggunakan data atau fakta pendukung"},{"id":"E","teks":"Bertujuan menghibur pembaca semata"}]',
 '["A","B","D"]',
 'Teks argumentasi berisi pendapat yang didukung alasan/bukti (A, D) dan bertujuan meyakinkan pembaca (B); urutan kronologis adalah ciri narasi, dan menghibur adalah ciri teks lain.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIN'), 'Teks narasi', 'sedang', 'kategori',
 'Setiap pagi, Rian berjalan kaki sejauh dua kilometer menuju sekolah karena angkutan umum belum beroperasi sepagi itu. Meski lelah, ia selalu tiba sebelum bel berbunyi.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
 '[{"id":"1","teks":"Rian naik angkutan umum ke sekolah."},{"id":"2","teks":"Rian selalu datang sebelum bel berbunyi."}]',
 '{"1":false,"2":true}',
 'Teks menyatakan Rian berjalan kaki karena angkutan umum belum beroperasi (pernyataan 1 salah), dan ia selalu tiba sebelum bel berbunyi (pernyataan 2 benar).',
 'ai','valid', false),

((select id from tka_mapel where kode='BIN'), 'Menyimpulkan isi teks', 'sulit', 'pg',
 'Meski harga bahan pangan naik menjelang hari raya, pemerintah menyatakan stok mencukupi hingga dua bulan ke depan. Namun, distribusi ke daerah terpencil masih menjadi kendala akibat infrastruktur jalan yang belum memadai.',
 'Berdasarkan teks, kenaikan harga pangan menjelang hari raya kemungkinan besar disebabkan oleh ...',
 '[{"id":"A","teks":"Stok bahan pangan yang benar-benar habis"},{"id":"B","teks":"Kendala distribusi ke sebagian wilayah meskipun stok nasional mencukupi"},{"id":"C","teks":"Larangan pemerintah menjual bahan pangan"},{"id":"D","teks":"Tidak adanya permintaan menjelang hari raya"},{"id":"E","teks":"Infrastruktur jalan yang sudah sangat memadai"}]',
 '["B"]',
 'Teks menyatakan stok mencukupi secara nasional, namun distribusi ke daerah terpencil terkendala infrastruktur, sehingga kenaikan harga lebih berkaitan dengan distribusi.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIN'), 'Kaidah kebahasaan', 'sulit', 'pg', null,
 'Kalimat berikut yang menggunakan konjungsi antarkalimat dengan tepat adalah ...',
 '[{"id":"A","teks":"Ia rajin belajar, oleh karena itu ia mendapat nilai tinggi."},{"id":"B","teks":"Ia rajin belajar. Oleh karena itu, ia mendapat nilai tinggi."},{"id":"C","teks":"Ia rajin belajar oleh karena itu, ia mendapat nilai tinggi."},{"id":"D","teks":"Ia rajin belajar; Oleh Karena Itu ia mendapat nilai tinggi."},{"id":"E","teks":"Ia rajin belajar oleh karena itu ia, mendapat nilai tinggi."}]',
 '["B"]',
 'Konjungsi antarkalimat seperti "oleh karena itu" ditulis pada awal kalimat baru setelah tanda titik dan diikuti tanda koma.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIN'), 'Teks deskripsi', 'sulit', 'pg',
 'Danau itu tenang, airnya jernih kehijauan, dan dikelilingi pohon pinus yang menjulang tinggi. Kabut tipis menyelimuti permukaannya pada pagi hari.',
 'Bagian teks yang paling menunjukkan citraan penglihatan (visual) adalah ...',
 '[{"id":"A","teks":"Danau itu tenang"},{"id":"B","teks":"airnya jernih kehijauan"},{"id":"C","teks":"udara terasa dingin"},{"id":"D","teks":"suara burung berkicau"},{"id":"E","teks":"angin berembus pelan"}]',
 '["B"]',
 'Frasa "airnya jernih kehijauan" secara eksplisit menggambarkan warna yang ditangkap indra penglihatan, ciri utama citraan visual.',
 'ai','valid', false);

-- =========================================================
-- MTK - Matematika
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='MTK'), 'Aljabar', 'mudah', 'pg', null,
 'Jika 2x + 5 = 17, maka nilai x adalah ...',
 '[{"id":"A","teks":"4"},{"id":"B","teks":"5"},{"id":"C","teks":"6"},{"id":"D","teks":"7"},{"id":"E","teks":"8"}]',
 '["C"]',
 '2x + 5 = 17 -> 2x = 12 -> x = 6.',
 'ai','valid', true),

((select id from tka_mapel where kode='MTK'), 'Statistika', 'mudah', 'pg', null,
 'Rata-rata (mean) dari data 4, 6, 8, 10, 12 adalah ...',
 '[{"id":"A","teks":"6"},{"id":"B","teks":"7"},{"id":"C","teks":"8"},{"id":"D","teks":"9"},{"id":"E","teks":"10"}]',
 '["C"]',
 'Jumlah data = 4+6+8+10+12 = 40, dibagi 5 data = 8.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTK'), 'Geometri', 'mudah', 'pg', null,
 'Luas persegi panjang dengan panjang 8 cm dan lebar 5 cm adalah ...',
 '[{"id":"A","teks":"30 cm2"},{"id":"B","teks":"35 cm2"},{"id":"C","teks":"40 cm2"},{"id":"D","teks":"45 cm2"},{"id":"E","teks":"50 cm2"}]',
 '["C"]',
 'Luas persegi panjang = panjang x lebar = 8 x 5 = 40 cm2.',
 'ai','valid', true),

((select id from tka_mapel where kode='MTK'), 'Peluang', 'sedang', 'pg', null,
 'Sebuah dadu bermata enam dilempar sekali. Peluang muncul mata dadu bilangan genap adalah ...',
 '[{"id":"A","teks":"1/6"},{"id":"B","teks":"1/3"},{"id":"C","teks":"1/2"},{"id":"D","teks":"2/3"},{"id":"E","teks":"5/6"}]',
 '["C"]',
 'Mata dadu genap ada 3 (2,4,6) dari 6 kemungkinan, sehingga peluangnya 3/6 = 1/2.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTK'), 'Barisan dan deret', 'sedang', 'pg', null,
 'Diketahui barisan aritmetika dengan suku pertama 3 dan beda 4. Suku ke-10 barisan tersebut adalah ...',
 '[{"id":"A","teks":"35"},{"id":"B","teks":"37"},{"id":"C","teks":"39"},{"id":"D","teks":"41"},{"id":"E","teks":"43"}]',
 '["C"]',
 'Un = a + (n-1)d = 3 + 9(4) = 3 + 36 = 39.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTK'), 'Fungsi', 'sedang', 'pg_kompleks', null,
 'Diketahui fungsi kuadrat f(x) = x^2 - 4x + 3. Pernyataan yang benar mengenai fungsi tersebut adalah ...',
 '[{"id":"A","teks":"Grafiknya terbuka ke atas"},{"id":"B","teks":"Akar-akar persamaan f(x) = 0 adalah 1 dan 3"},{"id":"C","teks":"Nilai minimum fungsi adalah -1"},{"id":"D","teks":"Grafik memotong sumbu Y di titik (0, -3)"},{"id":"E","teks":"Fungsi tidak memiliki titik puncak"}]',
 '["A","B","C"]',
 'Koefisien x^2 positif sehingga terbuka ke atas (A benar); f(x)=0 -> (x-1)(x-3)=0 -> x=1 atau 3 (B benar); titik puncak di x=2, f(2)=4-8+3=-1 (C benar); f(0)=3 bukan -3 (D salah); parabola selalu punya titik puncak (E salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='MTK'), 'Statistika', 'sedang', 'kategori',
 'Data nilai ujian 5 siswa: 70, 80, 80, 90, 100.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan data.',
 '[{"id":"1","teks":"Median data tersebut adalah 80."},{"id":"2","teks":"Modus data tersebut adalah 90."}]',
 '{"1":true,"2":false}',
 'Data terurut 70,80,80,90,100, median (nilai tengah) adalah 80 (pernyataan 1 benar). Modus (nilai paling sering muncul) adalah 80, bukan 90 (pernyataan 2 salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='MTK'), 'Sistem persamaan linear', 'sulit', 'pg', null,
 'Diketahui sistem persamaan 2x + y = 10 dan x - y = 2. Nilai x + y adalah ...',
 '[{"id":"A","teks":"4"},{"id":"B","teks":"5"},{"id":"C","teks":"6"},{"id":"D","teks":"7"},{"id":"E","teks":"8"}]',
 '["C"]',
 'Menjumlahkan kedua persamaan: 3x = 12 -> x = 4, sehingga y = 10 - 2(4) = 2. Maka x + y = 4 + 2 = 6.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTK'), 'Trigonometri', 'sulit', 'pg', null,
 'Nilai dari sin 30 derajat + cos 60 derajat adalah ...',
 '[{"id":"A","teks":"0"},{"id":"B","teks":"1/2"},{"id":"C","teks":"1"},{"id":"D","teks":"3/2"},{"id":"E","teks":"2"}]',
 '["C"]',
 'sin 30 derajat = 1/2 dan cos 60 derajat = 1/2, sehingga jumlahnya = 1/2 + 1/2 = 1.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTK'), 'Geometri', 'sulit', 'pg', null,
 'Sebuah tabung memiliki jari-jari alas 7 cm dan tinggi 10 cm. Dengan pi = 22/7, volume tabung tersebut adalah ...',
 '[{"id":"A","teks":"1.000 cm3"},{"id":"B","teks":"1.200 cm3"},{"id":"C","teks":"1.400 cm3"},{"id":"D","teks":"1.540 cm3"},{"id":"E","teks":"1.600 cm3"}]',
 '["D"]',
 'Volume tabung = pi x r^2 x t = 22/7 x 49 x 10 = 22 x 7 x 10 = 1.540 cm3.',
 'ai','valid', false);

-- =========================================================
-- BIG - Bahasa Inggris
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='BIG'), 'Vocabulary', 'mudah', 'pg', null,
 'Choose the antonym of the word "happy".',
 '[{"id":"A","teks":"sad"},{"id":"B","teks":"angry"},{"id":"C","teks":"tired"},{"id":"D","teks":"excited"},{"id":"E","teks":"cheerful"}]',
 '["A"]',
 '"Sad" is the opposite meaning of "happy", making it the correct antonym.',
 'ai','valid', true),

((select id from tka_mapel where kode='BIG'), 'Grammar (tenses)', 'mudah', 'pg', null,
 'Choose the correct word to complete the sentence: "She ___ to school yesterday."',
 '[{"id":"A","teks":"go"},{"id":"B","teks":"goes"},{"id":"C","teks":"went"},{"id":"D","teks":"gone"},{"id":"E","teks":"going"}]',
 '["C"]',
 'The sentence refers to "yesterday", a past time marker, so the simple past form "went" is correct.',
 'ai','valid', true),

((select id from tka_mapel where kode='BIG'), 'Reading comprehension', 'mudah', 'kategori',
 'Maria wakes up at five every morning. She jogs for thirty minutes before going to school. She never skips breakfast because she believes it gives her energy for the day.',
 'Decide whether each statement is true or false based on the text.',
 '[{"id":"1","teks":"Maria jogs for one hour every morning."},{"id":"2","teks":"Maria always eats breakfast."}]',
 '{"1":false,"2":true}',
 'The text says Maria jogs for thirty minutes, not one hour (statement 1 false), and that she never skips breakfast, meaning she always eats it (statement 2 true).',
 'ai','valid', false),

((select id from tka_mapel where kode='BIG'), 'Grammar (tenses)', 'sedang', 'pg', null,
 'Choose the correct word: "They ___ lived here since 2010."',
 '[{"id":"A","teks":"has"},{"id":"B","teks":"have"},{"id":"C","teks":"had"},{"id":"D","teks":"having"},{"id":"E","teks":"is"}]',
 '["B"]',
 'The subject "they" is plural and the sentence uses "since 2010", indicating present perfect tense: "have lived".',
 'ai','valid', false),

((select id from tka_mapel where kode='BIG'), 'Vocabulary', 'sedang', 'pg', null,
 'Choose the synonym of the word "huge".',
 '[{"id":"A","teks":"tiny"},{"id":"B","teks":"enormous"},{"id":"C","teks":"quiet"},{"id":"D","teks":"cheap"},{"id":"E","teks":"narrow"}]',
 '["B"]',
 '"Enormous" means very large, which is the closest synonym to "huge".',
 'ai','valid', false),

((select id from tka_mapel where kode='BIG'), 'Grammar (tenses)', 'sedang', 'pg_kompleks', null,
 'Which of the following sentences are grammatically correct?',
 '[{"id":"A","teks":"She don''t like coffee."},{"id":"B","teks":"He doesn''t like coffee."},{"id":"C","teks":"They doesn''t like coffee."},{"id":"D","teks":"I have finished my homework."},{"id":"E","teks":"I has finished my homework."}]',
 '["B","D"]',
 '"He doesn''t like coffee" correctly uses "doesn''t" for the third-person singular (B), and "I have finished" correctly pairs "I" with "have" (D). The others misuse subject-verb agreement.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIG'), 'Reading comprehension', 'sedang', 'kategori',
 'The company announced a new policy allowing employees to work from home twice a week. Many workers welcomed the change, saying it improved their work-life balance.',
 'Decide whether each statement is true or false based on the text.',
 '[{"id":"1","teks":"Employees can work from home every day."},{"id":"2","teks":"The new policy was welcomed by many workers."}]',
 '{"1":false,"2":true}',
 'The policy allows working from home only twice a week, not every day (statement 1 false). The text states many workers welcomed the change (statement 2 true).',
 'ai','valid', false),

((select id from tka_mapel where kode='BIG'), 'Reading comprehension', 'sulit', 'pg',
 'Although the museum was originally scheduled to close at 5 p.m., staff extended the hours until 8 p.m. due to the unexpectedly large number of visitors on the final day of the exhibition.',
 'Why did the museum extend its hours?',
 '[{"id":"A","teks":"Because of bad weather"},{"id":"B","teks":"Because of a large number of visitors"},{"id":"C","teks":"Because the staff wanted overtime pay"},{"id":"D","teks":"Because the exhibition was cancelled"},{"id":"E","teks":"Because it was a public holiday"}]',
 '["B"]',
 'The text explicitly states the hours were extended "due to the unexpectedly large number of visitors".',
 'ai','valid', false),

((select id from tka_mapel where kode='BIG'), 'Grammar (tenses)', 'sulit', 'pg', null,
 'Choose the correct passive form: "The letter ___ by John yesterday."',
 '[{"id":"A","teks":"wrote"},{"id":"B","teks":"written"},{"id":"C","teks":"was written"},{"id":"D","teks":"is written"},{"id":"E","teks":"writes"}]',
 '["C"]',
 'A past passive sentence needs "was/were + past participle"; since the subject "the letter" is singular and the action is in the past, "was written" is correct.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIG'), 'Vocabulary', 'sulit', 'pg', null,
 'In the sentence "The negotiations reached an impasse," the word "impasse" is closest in meaning to ...',
 '[{"id":"A","teks":"agreement"},{"id":"B","teks":"deadlock"},{"id":"C","teks":"celebration"},{"id":"D","teks":"beginning"},{"id":"E","teks":"compromise"}]',
 '["B"]',
 '"Impasse" refers to a situation where no progress can be made, which matches "deadlock".',
 'ai','valid', false);

-- =========================================================
-- MTKL - Matematika Tingkat Lanjut
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='MTKL'), 'Turunan', 'mudah', 'pg', null,
 'Diketahui f(x) = x^2. Nilai f''(3) adalah ...',
 '[{"id":"A","teks":"3"},{"id":"B","teks":"4"},{"id":"C","teks":"5"},{"id":"D","teks":"6"},{"id":"E","teks":"7"}]',
 '["D"]',
 'f''(x) = 2x, sehingga f''(3) = 2(3) = 6.',
 'ai','valid', true),

((select id from tka_mapel where kode='MTKL'), 'Matriks', 'mudah', 'pg', null,
 'Determinan dari matriks [[2,3],[1,4]] adalah ...',
 '[{"id":"A","teks":"3"},{"id":"B","teks":"4"},{"id":"C","teks":"5"},{"id":"D","teks":"6"},{"id":"E","teks":"7"}]',
 '["C"]',
 'Determinan matriks 2x2 [[a,b],[c,d]] = ad - bc = (2)(4) - (3)(1) = 8 - 3 = 5.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTKL'), 'Limit fungsi', 'mudah', 'pg', null,
 'Nilai dari lim x->2 (x^2 - 4)/(x - 2) adalah ...',
 '[{"id":"A","teks":"2"},{"id":"B","teks":"3"},{"id":"C","teks":"4"},{"id":"D","teks":"5"},{"id":"E","teks":"6"}]',
 '["C"]',
 '(x^2-4)/(x-2) = (x-2)(x+2)/(x-2) = x+2, sehingga limitnya = 2+2 = 4.',
 'ai','valid', true),

((select id from tka_mapel where kode='MTKL'), 'Turunan', 'sedang', 'pg', null,
 'Diketahui f(x) = 3x^2 - 5x + 2. Nilai f''(2) adalah ...',
 '[{"id":"A","teks":"5"},{"id":"B","teks":"6"},{"id":"C","teks":"7"},{"id":"D","teks":"8"},{"id":"E","teks":"9"}]',
 '["C"]',
 'f''(x) = 6x - 5, sehingga f''(2) = 12 - 5 = 7.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTKL'), 'Integral', 'sedang', 'pg', null,
 'Nilai dari integral 2x dx dari x=0 sampai x=3 adalah ...',
 '[{"id":"A","teks":"6"},{"id":"B","teks":"7"},{"id":"C","teks":"8"},{"id":"D","teks":"9"},{"id":"E","teks":"10"}]',
 '["D"]',
 'Integral 2x dx = x^2, dievaluasi dari 0 sampai 3 menghasilkan 3^2 - 0^2 = 9.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTKL'), 'Matriks', 'sedang', 'pg_kompleks', null,
 'Diketahui matriks identitas A = [[1,0],[0,1]]. Pernyataan yang benar mengenai A adalah ...',
 '[{"id":"A","teks":"A adalah matriks identitas"},{"id":"B","teks":"Determinan A = 1"},{"id":"C","teks":"A adalah matriks nol"},{"id":"D","teks":"A x A = A"},{"id":"E","teks":"A tidak memiliki invers"}]',
 '["A","B","D"]',
 'A adalah matriks identitas (A benar) dengan determinan 1 (B benar); A x A = A karena sifat identitas (D benar). A bukan matriks nol (C salah) dan matriks identitas memiliki invers, yaitu dirinya sendiri (E salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='MTKL'), 'Vektor', 'sedang', 'kategori',
 'Diketahui vektor u = (3, 4).',
 'Tentukan benar atau salah setiap pernyataan berikut.',
 '[{"id":"1","teks":"Panjang vektor u adalah 5."},{"id":"2","teks":"Vektor u tegak lurus terhadap sumbu X."}]',
 '{"1":true,"2":false}',
 '|u| = akar(3^2+4^2) = akar(25) = 5 (pernyataan 1 benar). Vektor tegak lurus sumbu X jika komponen x-nya nol; di sini komponen x = 3 ≠ 0 (pernyataan 2 salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='MTKL'), 'Turunan', 'sulit', 'pg', null,
 'Nilai maksimum dari fungsi f(x) = -x^2 + 4x + 1 adalah ...',
 '[{"id":"A","teks":"3"},{"id":"B","teks":"4"},{"id":"C","teks":"5"},{"id":"D","teks":"6"},{"id":"E","teks":"7"}]',
 '["C"]',
 'f''(x) = -2x + 4 = 0 -> x = 2. Nilai maksimum f(2) = -4 + 8 + 1 = 5.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTKL'), 'Integral', 'sulit', 'pg', null,
 'Nilai dari integral (3x^2 - 2x) dx dari x=1 sampai x=2 adalah ...',
 '[{"id":"A","teks":"2"},{"id":"B","teks":"3"},{"id":"C","teks":"4"},{"id":"D","teks":"5"},{"id":"E","teks":"6"}]',
 '["C"]',
 'Integral (3x^2-2x) dx = x^3 - x^2. Pada x=2: 8-4=4. Pada x=1: 1-1=0. Hasilnya 4-0 = 4.',
 'ai','valid', false),

((select id from tka_mapel where kode='MTKL'), 'Limit fungsi', 'sulit', 'pg', null,
 'Nilai dari lim x->0 sin(3x)/x adalah ...',
 '[{"id":"A","teks":"1"},{"id":"B","teks":"2"},{"id":"C","teks":"3"},{"id":"D","teks":"4"},{"id":"E","teks":"5"}]',
 '["C"]',
 'Menggunakan sifat lim x->0 sin(kx)/x = k, maka lim x->0 sin(3x)/x = 3.',
 'ai','valid', false);

-- =========================================================
-- FIS - Fisika
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='FIS'), 'Kinematika', 'mudah', 'pg', null,
 'Sebuah mobil menempuh jarak 100 m dalam waktu 20 sekon dengan kecepatan tetap. Kecepatan mobil tersebut adalah ...',
 '[{"id":"A","teks":"3 m/s"},{"id":"B","teks":"4 m/s"},{"id":"C","teks":"5 m/s"},{"id":"D","teks":"6 m/s"},{"id":"E","teks":"7 m/s"}]',
 '["C"]',
 'Kecepatan = jarak/waktu = 100 m / 20 s = 5 m/s.',
 'ai','valid', true),

((select id from tka_mapel where kode='FIS'), 'Dinamika (Hukum Newton)', 'mudah', 'pg', null,
 'Sebuah benda bermassa 2 kg mengalami percepatan 3 m/s^2. Besar gaya yang bekerja pada benda tersebut adalah ...',
 '[{"id":"A","teks":"4 N"},{"id":"B","teks":"5 N"},{"id":"C","teks":"6 N"},{"id":"D","teks":"7 N"},{"id":"E","teks":"8 N"}]',
 '["C"]',
 'Menggunakan Hukum II Newton F = m x a = 2 kg x 3 m/s^2 = 6 N.',
 'ai','valid', false),

((select id from tka_mapel where kode='FIS'), 'Suhu dan kalor', 'mudah', 'pg', null,
 'Suhu 100 derajat Celsius jika dikonversi ke skala Kelvin adalah ...',
 '[{"id":"A","teks":"273 K"},{"id":"B","teks":"323 K"},{"id":"C","teks":"373 K"},{"id":"D","teks":"400 K"},{"id":"E","teks":"473 K"}]',
 '["C"]',
 'Konversi Celsius ke Kelvin: T(K) = T(C) + 273 = 100 + 273 = 373 K.',
 'ai','valid', true),

((select id from tka_mapel where kode='FIS'), 'Usaha dan energi', 'sedang', 'pg', null,
 'Sebuah gaya 10 N digunakan untuk memindahkan benda sejauh 5 m searah gaya. Usaha yang dilakukan adalah ...',
 '[{"id":"A","teks":"30 J"},{"id":"B","teks":"40 J"},{"id":"C","teks":"50 J"},{"id":"D","teks":"60 J"},{"id":"E","teks":"70 J"}]',
 '["C"]',
 'Usaha W = F x d = 10 N x 5 m = 50 J.',
 'ai','valid', false),

((select id from tka_mapel where kode='FIS'), 'Usaha dan energi', 'sedang', 'pg', null,
 'Sebuah benda bermassa 2 kg bergerak dengan kecepatan 3 m/s. Energi kinetik benda tersebut adalah ...',
 '[{"id":"A","teks":"6 J"},{"id":"B","teks":"7 J"},{"id":"C","teks":"8 J"},{"id":"D","teks":"9 J"},{"id":"E","teks":"10 J"}]',
 '["D"]',
 'Ek = 1/2 x m x v^2 = 1/2 x 2 x 3^2 = 1/2 x 2 x 9 = 9 J.',
 'ai','valid', false),

((select id from tka_mapel where kode='FIS'), 'Dinamika (Hukum Newton)', 'sedang', 'pg_kompleks', null,
 'Sebuah buku diam di atas meja datar. Pernyataan yang benar mengenai buku tersebut adalah ...',
 '[{"id":"A","teks":"Gaya normal sama besar dengan gaya berat buku"},{"id":"B","teks":"Resultan gaya pada buku sama dengan nol"},{"id":"C","teks":"Buku mengalami percepatan ke atas"},{"id":"D","teks":"Berlaku Hukum I Newton pada buku"},{"id":"E","teks":"Gaya normal searah dengan gaya berat"}]',
 '["A","B","D"]',
 'Karena buku diam (setimbang), gaya normal sama besar dan berlawanan arah dengan gaya berat (A benar), resultan gaya nol (B benar), sehingga berlaku Hukum I Newton (D benar). Buku tidak berpercepatan (C salah), dan gaya normal berlawanan arah, bukan searah, dengan gaya berat (E salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='FIS'), 'Gelombang dan optik', 'sedang', 'kategori',
 'Sebuah gelombang memiliki frekuensi 50 Hz dan panjang gelombang 4 m.',
 'Tentukan benar atau salah setiap pernyataan berikut.',
 '[{"id":"1","teks":"Cepat rambat gelombang tersebut adalah 200 m/s."},{"id":"2","teks":"Periode gelombang tersebut adalah 0,02 sekon."}]',
 '{"1":true,"2":true}',
 'Cepat rambat v = f x lambda = 50 x 4 = 200 m/s (benar). Periode T = 1/f = 1/50 = 0,02 sekon (benar).',
 'ai','valid', false),

((select id from tka_mapel where kode='FIS'), 'Listrik', 'sulit', 'pg', null,
 'Sebuah rangkaian memiliki tegangan 12 V dan hambatan 4 ohm. Arus yang mengalir pada rangkaian tersebut adalah ...',
 '[{"id":"A","teks":"1 A"},{"id":"B","teks":"2 A"},{"id":"C","teks":"3 A"},{"id":"D","teks":"4 A"},{"id":"E","teks":"5 A"}]',
 '["C"]',
 'Menggunakan Hukum Ohm I = V/R = 12/4 = 3 A.',
 'ai','valid', false),

((select id from tka_mapel where kode='FIS'), 'Kinematika', 'sulit', 'pg', null,
 'Sebuah benda mulai bergerak dari keadaan diam dengan percepatan tetap 2 m/s^2 selama 5 sekon. Kecepatan akhir benda tersebut adalah ...',
 '[{"id":"A","teks":"6 m/s"},{"id":"B","teks":"8 m/s"},{"id":"C","teks":"10 m/s"},{"id":"D","teks":"12 m/s"},{"id":"E","teks":"14 m/s"}]',
 '["C"]',
 'v = v0 + a x t = 0 + 2 x 5 = 10 m/s.',
 'ai','valid', false),

((select id from tka_mapel where kode='FIS'), 'Usaha dan energi', 'sulit', 'pg', null,
 'Sebuah benda jatuh bebas dari ketinggian 20 m (g = 10 m/s^2, gesekan udara diabaikan). Kecepatan benda saat menyentuh tanah adalah ...',
 '[{"id":"A","teks":"10 m/s"},{"id":"B","teks":"15 m/s"},{"id":"C","teks":"20 m/s"},{"id":"D","teks":"25 m/s"},{"id":"E","teks":"30 m/s"}]',
 '["C"]',
 'Menggunakan v = akar(2 x g x h) = akar(2 x 10 x 20) = akar(400) = 20 m/s.',
 'ai','valid', false);

-- =========================================================
-- KIM - Kimia
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='KIM'), 'Struktur atom', 'mudah', 'pg', null,
 'Sebuah atom netral memiliki nomor atom 11. Jumlah elektron pada atom tersebut adalah ...',
 '[{"id":"A","teks":"9"},{"id":"B","teks":"10"},{"id":"C","teks":"11"},{"id":"D","teks":"12"},{"id":"E","teks":"13"}]',
 '["C"]',
 'Pada atom netral, jumlah elektron sama dengan jumlah proton (nomor atom), sehingga jumlah elektronnya 11.',
 'ai','valid', true),

((select id from tka_mapel where kode='KIM'), 'Ikatan kimia', 'mudah', 'pg', null,
 'Senyawa NaCl terbentuk melalui ikatan ...',
 '[{"id":"A","teks":"Kovalen"},{"id":"B","teks":"Ionik"},{"id":"C","teks":"Logam"},{"id":"D","teks":"Hidrogen"},{"id":"E","teks":"Van der Waals"}]',
 '["B"]',
 'NaCl terbentuk dari serah terima elektron antara logam Na dan nonlogam Cl, yaitu ikatan ionik.',
 'ai','valid', false),

((select id from tka_mapel where kode='KIM'), 'Larutan (asam basa)', 'mudah', 'pg', null,
 'Suatu larutan memiliki pH 3. Larutan tersebut bersifat ...',
 '[{"id":"A","teks":"Basa"},{"id":"B","teks":"Netral"},{"id":"C","teks":"Asam"},{"id":"D","teks":"Garam"},{"id":"E","teks":"Amfoter"}]',
 '["C"]',
 'Larutan dengan pH kurang dari 7 bersifat asam.',
 'ai','valid', true),

((select id from tka_mapel where kode='KIM'), 'Stoikiometri', 'sedang', 'pg', null,
 'Sebanyak 20 gram NaOH (Mr = 40) dilarutkan. Jumlah mol NaOH tersebut adalah ...',
 '[{"id":"A","teks":"0,2 mol"},{"id":"B","teks":"0,3 mol"},{"id":"C","teks":"0,4 mol"},{"id":"D","teks":"0,5 mol"},{"id":"E","teks":"0,6 mol"}]',
 '["D"]',
 'mol = massa/Mr = 20/40 = 0,5 mol.',
 'ai','valid', false),

((select id from tka_mapel where kode='KIM'), 'Termokimia', 'sedang', 'pg', null,
 'Reaksi eksoterm ditandai dengan ...',
 '[{"id":"A","teks":"Penyerapan kalor, delta H positif"},{"id":"B","teks":"Pelepasan kalor, delta H negatif"},{"id":"C","teks":"Tidak ada perubahan kalor"},{"id":"D","teks":"Penyerapan kalor, delta H negatif"},{"id":"E","teks":"Pelepasan kalor, delta H positif"}]',
 '["B"]',
 'Reaksi eksoterm melepaskan kalor ke lingkungan sehingga entalpi sistem berkurang, ditandai dengan delta H negatif.',
 'ai','valid', false),

((select id from tka_mapel where kode='KIM'), 'Larutan (asam basa)', 'sedang', 'pg_kompleks', null,
 'Pernyataan yang benar mengenai larutan asam adalah ...',
 '[{"id":"A","teks":"Memerahkan lakmus biru"},{"id":"B","teks":"Memiliki pH lebih besar dari 7"},{"id":"C","teks":"Dapat menghantarkan listrik jika berupa elektrolit"},{"id":"D","teks":"Mengubah lakmus merah menjadi biru"},{"id":"E","teks":"Bereaksi dengan basa menghasilkan garam dan air"}]',
 '["A","C","E"]',
 'Larutan asam memerahkan lakmus biru (A) dan bereaksi dengan basa membentuk garam dan air atau netralisasi (E); jika elektrolit, larutan asam dapat menghantarkan listrik (C). Larutan asam memiliki pH kurang dari 7, bukan lebih besar (B salah), dan tidak mengubah lakmus merah menjadi biru, itu ciri basa (D salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='KIM'), 'Laju reaksi', 'sedang', 'kategori',
 'Kenaikan suhu mempercepat laju reaksi karena partikel bergerak lebih cepat sehingga energi kinetik partikel meningkat, membuat tumbukan efektif lebih sering terjadi.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
 '[{"id":"1","teks":"Kenaikan suhu memperlambat laju reaksi."},{"id":"2","teks":"Peningkatan energi kinetik partikel mempercepat laju reaksi."}]',
 '{"1":false,"2":true}',
 'Teks menyatakan kenaikan suhu mempercepat, bukan memperlambat, laju reaksi (pernyataan 1 salah); dan peningkatan energi kinetik partikel membuat reaksi lebih cepat (pernyataan 2 benar).',
 'ai','valid', false),

((select id from tka_mapel where kode='KIM'), 'Stoikiometri', 'sulit', 'pg', null,
 'Reaksi pembakaran metana: CH4 + 2O2 -> CO2 + 2H2O. Jika 2 mol CH4 dibakar sempurna, jumlah mol O2 yang dibutuhkan adalah ...',
 '[{"id":"A","teks":"2 mol"},{"id":"B","teks":"3 mol"},{"id":"C","teks":"4 mol"},{"id":"D","teks":"5 mol"},{"id":"E","teks":"6 mol"}]',
 '["C"]',
 'Berdasarkan koefisien reaksi, 1 mol CH4 membutuhkan 2 mol O2, sehingga 2 mol CH4 membutuhkan 2 x 2 = 4 mol O2.',
 'ai','valid', false),

((select id from tka_mapel where kode='KIM'), 'Elektrokimia', 'sulit', 'pg', null,
 'Pada sel elektrolisis, reaksi reduksi terjadi pada elektroda yang disebut ...',
 '[{"id":"A","teks":"Anoda"},{"id":"B","teks":"Katoda"},{"id":"C","teks":"Jembatan garam"},{"id":"D","teks":"Elektrolit"},{"id":"E","teks":"Separator"}]',
 '["B"]',
 'Pada sel elektrolisis, katoda adalah elektroda tempat terjadinya reaksi reduksi (penerimaan elektron).',
 'ai','valid', false),

((select id from tka_mapel where kode='KIM'), 'Larutan (asam basa)', 'sulit', 'pg', null,
 'Sebanyak 0,2 mol zat terlarut dilarutkan hingga volume larutan 500 mL. Molaritas larutan tersebut adalah ...',
 '[{"id":"A","teks":"0,2 M"},{"id":"B","teks":"0,3 M"},{"id":"C","teks":"0,4 M"},{"id":"D","teks":"0,5 M"},{"id":"E","teks":"0,6 M"}]',
 '["C"]',
 'Molaritas = mol/volume(L) = 0,2 mol / 0,5 L = 0,4 M.',
 'ai','valid', false);

-- =========================================================
-- BIO - Biologi
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='BIO'), 'Sel', 'mudah', 'pg', null,
 'Organel sel yang berfungsi sebagai penghasil energi melalui respirasi sel adalah ...',
 '[{"id":"A","teks":"Nukleus"},{"id":"B","teks":"Mitokondria"},{"id":"C","teks":"Ribosom"},{"id":"D","teks":"Lisosom"},{"id":"E","teks":"Badan Golgi"}]',
 '["B"]',
 'Mitokondria adalah organel yang menghasilkan energi (ATP) melalui proses respirasi sel.',
 'ai','valid', true),

((select id from tka_mapel where kode='BIO'), 'Klasifikasi makhluk hidup', 'mudah', 'pg', null,
 'Dalam urutan tingkatan takson (kingdom, filum, kelas, ordo, famili, genus, spesies), takson yang paling sempit cakupannya adalah ...',
 '[{"id":"A","teks":"Kingdom"},{"id":"B","teks":"Filum"},{"id":"C","teks":"Kelas"},{"id":"D","teks":"Genus"},{"id":"E","teks":"Spesies"}]',
 '["E"]',
 'Urutan takson dari paling luas ke paling sempit adalah kingdom-filum-kelas-ordo-famili-genus-spesies, sehingga spesies adalah yang paling sempit.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIO'), 'Sistem organ tubuh manusia', 'mudah', 'pg', null,
 'Organ tubuh manusia yang berfungsi memompa darah ke seluruh tubuh adalah ...',
 '[{"id":"A","teks":"Paru-paru"},{"id":"B","teks":"Jantung"},{"id":"C","teks":"Hati"},{"id":"D","teks":"Ginjal"},{"id":"E","teks":"Lambung"}]',
 '["B"]',
 'Jantung berfungsi memompa darah agar dapat beredar ke seluruh tubuh.',
 'ai','valid', true),

((select id from tka_mapel where kode='BIO'), 'Genetika', 'sedang', 'pg', null,
 'Pada persilangan monohibrid Aa x Aa dengan A dominan penuh terhadap a, rasio fenotipe keturunannya adalah ...',
 '[{"id":"A","teks":"1:1"},{"id":"B","teks":"1:2:1"},{"id":"C","teks":"3:1"},{"id":"D","teks":"1:3"},{"id":"E","teks":"9:3:3:1"}]',
 '["C"]',
 'Genotipe keturunan Aa x Aa adalah 1 AA : 2 Aa : 1 aa. Karena A dominan penuh, fenotipe dominan (AA dan Aa) : resesif (aa) = 3:1.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIO'), 'Ekosistem', 'sedang', 'pg', null,
 'Organisme yang berperan sebagai produsen dalam suatu ekosistem adalah ...',
 '[{"id":"A","teks":"Karnivora"},{"id":"B","teks":"Herbivora"},{"id":"C","teks":"Tumbuhan hijau"},{"id":"D","teks":"Dekomposer"},{"id":"E","teks":"Omnivora"}]',
 '["C"]',
 'Tumbuhan hijau mampu berfotosintesis membuat makanan sendiri sehingga berperan sebagai produsen.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIO'), 'Klasifikasi makhluk hidup', 'sedang', 'pg_kompleks', null,
 'Berikut ini yang merupakan ciri-ciri makhluk hidup adalah ...',
 '[{"id":"A","teks":"Bernapas"},{"id":"B","teks":"Tumbuh dan berkembang"},{"id":"C","teks":"Tidak memerlukan nutrisi"},{"id":"D","teks":"Berkembang biak"},{"id":"E","teks":"Tidak peka terhadap rangsang"}]',
 '["A","B","D"]',
 'Ciri makhluk hidup meliputi bernapas (A), tumbuh dan berkembang (B), serta berkembang biak (D). Makhluk hidup memerlukan nutrisi (C salah) dan peka terhadap rangsang/iritabilitas (E salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='BIO'), 'Ekosistem', 'sedang', 'kategori',
 'Dalam ekosistem sawah, padi berperan sebagai produsen. Tikus memakan padi, dan ular memakan tikus. Elang kemudian memangsa ular.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
 '[{"id":"1","teks":"Padi berperan sebagai konsumen tingkat satu."},{"id":"2","teks":"Ular merupakan konsumen tingkat dua."}]',
 '{"1":false,"2":true}',
 'Padi berperan sebagai produsen, bukan konsumen (pernyataan 1 salah). Tikus adalah konsumen tingkat satu (pemakan padi) dan ular yang memakan tikus adalah konsumen tingkat dua (pernyataan 2 benar).',
 'ai','valid', false),

((select id from tka_mapel where kode='BIO'), 'Genetika', 'sulit', 'pg', null,
 'Pada persilangan dihibrid AaBb x AaBb dengan A dan B dominan penuh serta menyilang bebas, rasio fenotipe pada keturunan F2 adalah ...',
 '[{"id":"A","teks":"1:2:1"},{"id":"B","teks":"3:1"},{"id":"C","teks":"9:3:3:1"},{"id":"D","teks":"1:1:1:1"},{"id":"E","teks":"9:7"}]',
 '["C"]',
 'Persilangan dihibrid dengan dua gen yang bersegregasi bebas menghasilkan rasio fenotipe klasik 9:3:3:1 pada F2.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIO'), 'Evolusi', 'sulit', 'pg', null,
 'Struktur organ tubuh pada spesies berbeda yang berasal dari nenek moyang yang sama namun kini memiliki fungsi berbeda disebut ...',
 '[{"id":"A","teks":"Analogi"},{"id":"B","teks":"Homologi"},{"id":"C","teks":"Konvergensi"},{"id":"D","teks":"Mimikri"},{"id":"E","teks":"Adaptasi tingkah laku"}]',
 '["B"]',
 'Organ yang berasal dari asal-usul (nenek moyang) yang sama tetapi berbeda fungsi disebut organ homolog, sebagai salah satu bukti evolusi.',
 'ai','valid', false),

((select id from tka_mapel where kode='BIO'), 'Bioteknologi', 'sulit', 'pg', null,
 'Pembuatan tempe secara tradisional memanfaatkan mikroorganisme dari kelompok ...',
 '[{"id":"A","teks":"Bakteri"},{"id":"B","teks":"Jamur"},{"id":"C","teks":"Virus"},{"id":"D","teks":"Protozoa"},{"id":"E","teks":"Alga"}]',
 '["B"]',
 'Tempe dibuat melalui fermentasi kedelai menggunakan jamur Rhizopus oryzae, sehingga tergolong bioteknologi berbasis jamur.',
 'ai','valid', false);

-- =========================================================
-- EKO - Ekonomi
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='EKO'), 'Permintaan dan penawaran', 'mudah', 'pg', null,
 'Berdasarkan hukum permintaan, jika harga suatu barang naik (ceteris paribus), maka jumlah barang yang diminta akan ...',
 '[{"id":"A","teks":"Naik"},{"id":"B","teks":"Turun"},{"id":"C","teks":"Tetap"},{"id":"D","teks":"Tidak menentu"},{"id":"E","teks":"Naik drastis"}]',
 '["B"]',
 'Hukum permintaan menyatakan hubungan harga dan jumlah diminta berbanding terbalik: harga naik, jumlah yang diminta turun.',
 'ai','valid', true),

((select id from tka_mapel where kode='EKO'), 'Inflasi', 'mudah', 'pg', null,
 'Kenaikan harga barang dan jasa secara umum dan terus-menerus dalam suatu periode disebut ...',
 '[{"id":"A","teks":"Deflasi"},{"id":"B","teks":"Inflasi"},{"id":"C","teks":"Devaluasi"},{"id":"D","teks":"Resesi"},{"id":"E","teks":"Depresiasi"}]',
 '["B"]',
 'Inflasi adalah kondisi kenaikan harga barang/jasa secara umum dan terus-menerus.',
 'ai','valid', false),

((select id from tka_mapel where kode='EKO'), 'Pelaku ekonomi', 'mudah', 'pg', null,
 'Pelaku ekonomi yang berperan menyediakan faktor produksi (tenaga kerja, tanah, modal) kepada perusahaan disebut ...',
 '[{"id":"A","teks":"Rumah tangga konsumen"},{"id":"B","teks":"Rumah tangga produsen"},{"id":"C","teks":"Rumah tangga pemerintah"},{"id":"D","teks":"Rumah tangga luar negeri"},{"id":"E","teks":"Koperasi"}]',
 '["A"]',
 'Rumah tangga konsumen (RTK) menyediakan faktor produksi kepada rumah tangga produsen dan menerima balas jasa berupa sewa, upah, bunga, dan laba.',
 'ai','valid', true),

((select id from tka_mapel where kode='EKO'), 'Permintaan dan penawaran', 'sedang', 'pg', null,
 'Jika persentase perubahan jumlah barang yang diminta lebih besar daripada persentase perubahan harga, maka permintaan tersebut bersifat ...',
 '[{"id":"A","teks":"Elastis"},{"id":"B","teks":"Inelastis"},{"id":"C","teks":"Elastis uniter"},{"id":"D","teks":"Inelastis sempurna"},{"id":"E","teks":"Elastis sempurna"}]',
 '["A"]',
 'Permintaan bersifat elastis apabila perubahan jumlah yang diminta secara persentase lebih besar dibanding perubahan harga.',
 'ai','valid', false),

((select id from tka_mapel where kode='EKO'), 'Pasar', 'sedang', 'pg', null,
 'Bentuk pasar dengan ciri banyak penjual, banyak pembeli, dan barang yang diperjualbelikan homogen disebut ...',
 '[{"id":"A","teks":"Pasar monopoli"},{"id":"B","teks":"Pasar oligopoli"},{"id":"C","teks":"Pasar persaingan sempurna"},{"id":"D","teks":"Pasar monopolistik"},{"id":"E","teks":"Pasar oligopsoni"}]',
 '["C"]',
 'Pasar dengan banyak penjual dan pembeli serta barang homogen adalah ciri utama pasar persaingan sempurna.',
 'ai','valid', false),

((select id from tka_mapel where kode='EKO'), 'Pasar', 'sedang', 'pg_kompleks', null,
 'Berikut ini yang merupakan ciri-ciri pasar persaingan sempurna adalah ...',
 '[{"id":"A","teks":"Banyak penjual dan banyak pembeli"},{"id":"B","teks":"Barang yang diperjualbelikan bersifat homogen"},{"id":"C","teks":"Penjual dapat menentukan harga sendiri"},{"id":"D","teks":"Bebas keluar masuk pasar"},{"id":"E","teks":"Hanya ada satu penjual di pasar"}]',
 '["A","B","D"]',
 'Pasar persaingan sempurna dicirikan banyak penjual dan pembeli (A), barang homogen (B), dan bebas keluar masuk pasar (D). Penjual bertindak sebagai price taker, bukan penentu harga (C salah), dan hanya ada satu penjual adalah ciri monopoli (E salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='EKO'), 'Kebijakan moneter dan fiskal', 'sedang', 'kategori',
 'Bank sentral menaikkan suku bunga acuan untuk menekan laju inflasi yang tinggi. Kebijakan ini termasuk kebijakan moneter kontraktif.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
 '[{"id":"1","teks":"Kenaikan suku bunga acuan bertujuan menekan inflasi."},{"id":"2","teks":"Kebijakan tersebut termasuk kebijakan fiskal."}]',
 '{"1":true,"2":false}',
 'Teks menyatakan tujuan kenaikan suku bunga adalah menekan inflasi (pernyataan 1 benar). Kebijakan suku bunga oleh bank sentral termasuk kebijakan moneter, bukan fiskal (pernyataan 2 salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='EKO'), 'Pendapatan nasional', 'sulit', 'pg', null,
 'Metode penghitungan pendapatan nasional dengan menjumlahkan seluruh nilai barang dan jasa yang dihasilkan oleh berbagai sektor ekonomi dalam suatu periode disebut metode ...',
 '[{"id":"A","teks":"Produksi"},{"id":"B","teks":"Pendapatan"},{"id":"C","teks":"Pengeluaran"},{"id":"D","teks":"Konsumsi"},{"id":"E","teks":"Distribusi"}]',
 '["A"]',
 'Metode produksi menghitung pendapatan nasional dari jumlah nilai tambah barang dan jasa yang dihasilkan seluruh sektor produksi.',
 'ai','valid', false),

((select id from tka_mapel where kode='EKO'), 'Ketenagakerjaan', 'sulit', 'pg', null,
 'Pengangguran yang terjadi karena perubahan struktur ekonomi, misalnya otomatisasi yang menggantikan tenaga kerja manusia, disebut pengangguran ...',
 '[{"id":"A","teks":"Friksional"},{"id":"B","teks":"Struktural"},{"id":"C","teks":"Musiman"},{"id":"D","teks":"Siklikal"},{"id":"E","teks":"Terselubung"}]',
 '["B"]',
 'Pengangguran struktural terjadi akibat perubahan struktur ekonomi, seperti otomatisasi, yang membuat keterampilan tenaga kerja tidak lagi sesuai kebutuhan.',
 'ai','valid', false),

((select id from tka_mapel where kode='EKO'), 'Manajemen dan koperasi', 'sulit', 'pg', null,
 'Dalam koperasi, sisa hasil usaha (SHU) dibagikan kepada anggota terutama berdasarkan ...',
 '[{"id":"A","teks":"Jumlah modal saham yang dimiliki"},{"id":"B","teks":"Jasa dan partisipasi anggota terhadap koperasi"},{"id":"C","teks":"Senioritas anggota"},{"id":"D","teks":"Jabatan pengurus koperasi"},{"id":"E","teks":"Keputusan pemerintah daerah"}]',
 '["B"]',
 'Prinsip koperasi membagikan SHU berdasarkan jasa dan partisipasi anggota dalam kegiatan usaha koperasi, bukan semata besar modal seperti pada perseroan.',
 'ai','valid', false);

-- =========================================================
-- SOS - Sosiologi
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='SOS'), 'Interaksi sosial', 'mudah', 'pg', null,
 'Dua syarat utama yang harus dipenuhi agar terjadi interaksi sosial adalah ...',
 '[{"id":"A","teks":"Kontak sosial dan komunikasi"},{"id":"B","teks":"Kekuasaan dan wewenang"},{"id":"C","teks":"Norma dan nilai"},{"id":"D","teks":"Status dan peran"},{"id":"E","teks":"Konflik dan kompetisi"}]',
 '["A"]',
 'Interaksi sosial terjadi apabila ada kontak sosial (hubungan) dan komunikasi (pertukaran pesan) antarindividu atau kelompok.',
 'ai','valid', true),

((select id from tka_mapel where kode='SOS'), 'Sosialisasi', 'mudah', 'pg', null,
 'Proses belajar individu untuk mengenal dan menghayati nilai serta norma dalam masyarakat disebut ...',
 '[{"id":"A","teks":"Sosialisasi"},{"id":"B","teks":"Asimilasi"},{"id":"C","teks":"Akulturasi"},{"id":"D","teks":"Difusi"},{"id":"E","teks":"Integrasi"}]',
 '["A"]',
 'Sosialisasi adalah proses individu belajar mengenal dan menghayati nilai serta norma masyarakat tempat ia tinggal.',
 'ai','valid', false),

((select id from tka_mapel where kode='SOS'), 'Sosialisasi', 'mudah', 'pg', null,
 'Agen sosialisasi pertama yang dikenal oleh seorang individu sejak lahir adalah ...',
 '[{"id":"A","teks":"Sekolah"},{"id":"B","teks":"Keluarga"},{"id":"C","teks":"Media massa"},{"id":"D","teks":"Teman sebaya"},{"id":"E","teks":"Tempat kerja"}]',
 '["B"]',
 'Keluarga merupakan agen sosialisasi primer karena menjadi lingkungan pertama yang dikenal individu sejak lahir.',
 'ai','valid', true),

((select id from tka_mapel where kode='SOS'), 'Struktur sosial', 'sedang', 'pg', null,
 'Sistem stratifikasi sosial yang bersifat tertutup, di mana perpindahan status sosial sangat sulit dilakukan, disebut sistem ...',
 '[{"id":"A","teks":"Kasta"},{"id":"B","teks":"Kelas"},{"id":"C","teks":"Prestise"},{"id":"D","teks":"Terbuka"},{"id":"E","teks":"Campuran"}]',
 '["A"]',
 'Sistem kasta bersifat tertutup karena status sosial ditentukan sejak lahir dan sulit berubah melalui mobilitas sosial.',
 'ai','valid', false),

((select id from tka_mapel where kode='SOS'), 'Perubahan sosial', 'sedang', 'pg', null,
 'Perubahan sosial yang berlangsung secara lambat dan membutuhkan waktu yang lama disebut ...',
 '[{"id":"A","teks":"Revolusi"},{"id":"B","teks":"Evolusi"},{"id":"C","teks":"Regres"},{"id":"D","teks":"Involusi"},{"id":"E","teks":"Reformasi"}]',
 '["B"]',
 'Perubahan sosial yang berlangsung lambat dan bertahap dalam waktu lama disebut evolusi.',
 'ai','valid', false),

((select id from tka_mapel where kode='SOS'), 'Perubahan sosial', 'sedang', 'pg_kompleks', null,
 'Berikut ini yang merupakan faktor pendorong terjadinya perubahan sosial adalah ...',
 '[{"id":"A","teks":"Kontak dengan budaya lain"},{"id":"B","teks":"Sikap masyarakat yang terbuka terhadap hal baru"},{"id":"C","teks":"Sikap masyarakat yang tertutup"},{"id":"D","teks":"Kemajuan sistem pendidikan"},{"id":"E","teks":"Adat istiadat yang mengikat kuat"}]',
 '["A","B","D"]',
 'Kontak dengan budaya lain (A), sikap terbuka masyarakat (B), dan kemajuan pendidikan (D) mendorong perubahan sosial. Sikap tertutup (C) dan adat istiadat yang mengikat kuat (E) justru menjadi faktor penghambat perubahan sosial.',
 'ai','valid', false),

((select id from tka_mapel where kode='SOS'), 'Perubahan sosial', 'sedang', 'kategori',
 'Setelah pandemi, banyak perusahaan menerapkan sistem kerja hybrid yang menggabungkan kerja dari kantor dan dari rumah. Perubahan ini terjadi cukup cepat dan memengaruhi pola interaksi sosial karyawan.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
 '[{"id":"1","teks":"Perubahan pola kerja tersebut terjadi secara cepat."},{"id":"2","teks":"Perubahan tersebut tidak memengaruhi interaksi sosial karyawan."}]',
 '{"1":true,"2":false}',
 'Teks menyatakan perubahan terjadi cukup cepat (pernyataan 1 benar) dan memengaruhi pola interaksi sosial karyawan, sehingga pernyataan 2 yang menyebut "tidak memengaruhi" salah.',
 'ai','valid', false),

((select id from tka_mapel where kode='SOS'), 'Konflik sosial', 'sulit', 'pg', null,
 'Salah satu dampak positif dari konflik sosial di dalam suatu kelompok adalah ...',
 '[{"id":"A","teks":"Meningkatnya solidaritas antaranggota kelompok"},{"id":"B","teks":"Hancurnya seluruh struktur sosial"},{"id":"C","teks":"Menurunnya semangat kelompok"},{"id":"D","teks":"Hilangnya identitas kelompok"},{"id":"E","teks":"Terputusnya komunikasi antaranggota"}]',
 '["A"]',
 'Konflik dengan kelompok luar dapat meningkatkan solidaritas dan kekompakan (in-group solidarity) di antara anggota kelompok itu sendiri.',
 'ai','valid', false),

((select id from tka_mapel where kode='SOS'), 'Penelitian sosial', 'sulit', 'pg', null,
 'Metode pengumpulan data penelitian sosial yang dilakukan dengan mengamati langsung objek atau perilaku yang diteliti disebut ...',
 '[{"id":"A","teks":"Wawancara"},{"id":"B","teks":"Observasi"},{"id":"C","teks":"Angket"},{"id":"D","teks":"Studi pustaka"},{"id":"E","teks":"Eksperimen laboratorium"}]',
 '["B"]',
 'Observasi adalah metode pengumpulan data dengan mengamati langsung objek penelitian.',
 'ai','valid', false),

((select id from tka_mapel where kode='SOS'), 'Kelompok sosial', 'sulit', 'pg', null,
 'Kelompok sosial yang terbentuk atas dasar hubungan darah atau keturunan disebut kelompok ...',
 '[{"id":"A","teks":"Referensi"},{"id":"B","teks":"Kekerabatan"},{"id":"C","teks":"Formal"},{"id":"D","teks":"Sekunder"},{"id":"E","teks":"Okupasional"}]',
 '["B"]',
 'Kelompok kekerabatan terbentuk berdasarkan hubungan darah atau keturunan, seperti keluarga besar.',
 'ai','valid', false);

-- =========================================================
-- GEO - Geografi
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='GEO'), 'Atmosfer', 'mudah', 'pg', null,
 'Lapisan atmosfer tempat terjadinya fenomena cuaca seperti awan dan hujan adalah ...',
 '[{"id":"A","teks":"Troposfer"},{"id":"B","teks":"Stratosfer"},{"id":"C","teks":"Mesosfer"},{"id":"D","teks":"Termosfer"},{"id":"E","teks":"Eksosfer"}]',
 '["A"]',
 'Troposfer adalah lapisan atmosfer paling bawah tempat terjadinya berbagai fenomena cuaca seperti awan, hujan, dan angin.',
 'ai','valid', true),

((select id from tka_mapel where kode='GEO'), 'Peta dan penginderaan jauh', 'mudah', 'pg', null,
 'Sebuah peta memiliki skala 1:100.000. Jika jarak dua kota pada peta adalah 5 cm, jarak sebenarnya adalah ...',
 '[{"id":"A","teks":"3 km"},{"id":"B","teks":"4 km"},{"id":"C","teks":"5 km"},{"id":"D","teks":"6 km"},{"id":"E","teks":"7 km"}]',
 '["C"]',
 'Jarak sebenarnya = jarak peta x skala = 5 cm x 100.000 = 500.000 cm = 5 km.',
 'ai','valid', false),

((select id from tka_mapel where kode='GEO'), 'Hidrosfer', 'mudah', 'pg', null,
 'Siklus air di mana air menguap dari permukaan laut lalu langsung jatuh sebagai hujan di atas laut tanpa melalui daratan disebut ...',
 '[{"id":"A","teks":"Siklus pendek"},{"id":"B","teks":"Siklus sedang"},{"id":"C","teks":"Siklus panjang"},{"id":"D","teks":"Siklus tertutup"},{"id":"E","teks":"Siklus terbuka"}]',
 '["A"]',
 'Siklus pendek terjadi ketika air laut menguap, membentuk awan, lalu langsung turun sebagai hujan di atas laut itu sendiri.',
 'ai','valid', true),

((select id from tka_mapel where kode='GEO'), 'Litosfer', 'sedang', 'pg', null,
 'Batuan yang terbentuk dari pembekuan magma disebut batuan ...',
 '[{"id":"A","teks":"Beku"},{"id":"B","teks":"Sedimen"},{"id":"C","teks":"Metamorf"},{"id":"D","teks":"Breksi"},{"id":"E","teks":"Konglomerat"}]',
 '["A"]',
 'Batuan beku (contoh: granit, basalt) terbentuk dari proses pembekuan magma.',
 'ai','valid', false),

((select id from tka_mapel where kode='GEO'), 'Kependudukan', 'sedang', 'pg', null,
 'Perbandingan antara jumlah penduduk usia nonproduktif dengan jumlah penduduk usia produktif disebut ...',
 '[{"id":"A","teks":"Sex ratio"},{"id":"B","teks":"Dependency ratio"},{"id":"C","teks":"Growth ratio"},{"id":"D","teks":"Density ratio"},{"id":"E","teks":"Migration ratio"}]',
 '["B"]',
 'Dependency ratio (rasio ketergantungan) menunjukkan perbandingan penduduk usia nonproduktif terhadap usia produktif.',
 'ai','valid', false),

((select id from tka_mapel where kode='GEO'), 'Biosfer', 'sedang', 'pg_kompleks', null,
 'Faktor-faktor berikut yang memengaruhi persebaran flora dan fauna di suatu wilayah adalah ...',
 '[{"id":"A","teks":"Iklim"},{"id":"B","teks":"Relief atau topografi"},{"id":"C","teks":"Jenis tanah"},{"id":"D","teks":"Bahasa daerah setempat"},{"id":"E","teks":"Warna bendera negara"}]',
 '["A","B","C"]',
 'Persebaran flora dan fauna dipengaruhi oleh faktor iklim (A), relief/topografi (B), dan jenis tanah (C). Bahasa daerah (D) dan warna bendera (E) tidak berkaitan dengan faktor biogeografi.',
 'ai','valid', false),

((select id from tka_mapel where kode='GEO'), 'Interaksi desa-kota', 'sedang', 'kategori',
 'Desa dan kota memiliki hubungan saling ketergantungan. Desa menyuplai bahan pangan dan tenaga kerja ke kota, sementara kota menyediakan barang manufaktur dan layanan pendidikan bagi penduduk desa.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
 '[{"id":"1","teks":"Desa hanya menerima dan tidak memberikan apa pun ke kota."},{"id":"2","teks":"Kota menyediakan layanan pendidikan bagi penduduk desa."}]',
 '{"1":false,"2":true}',
 'Teks menyatakan desa menyuplai bahan pangan dan tenaga kerja ke kota, sehingga pernyataan 1 (desa hanya menerima) salah. Teks juga menyatakan kota menyediakan layanan pendidikan bagi penduduk desa (pernyataan 2 benar).',
 'ai','valid', false),

((select id from tka_mapel where kode='GEO'), 'Peta dan penginderaan jauh', 'sulit', 'pg', null,
 'Komponen penginderaan jauh yang berfungsi merekam objek di permukaan bumi dari jarak jauh disebut ...',
 '[{"id":"A","teks":"Sensor"},{"id":"B","teks":"Atmosfer"},{"id":"C","teks":"Sumber tenaga"},{"id":"D","teks":"Citra"},{"id":"E","teks":"Wahana"}]',
 '["A"]',
 'Sensor adalah komponen penginderaan jauh yang merekam energi pantulan/pancaran objek di permukaan bumi.',
 'ai','valid', false),

((select id from tka_mapel where kode='GEO'), 'Litosfer', 'sulit', 'pg', null,
 'Teori yang menyatakan benua-benua di bumi dahulu merupakan satu daratan besar (Pangea) yang kemudian terpecah dan bergerak saling menjauh dikemukakan oleh Alfred Wegener dan disebut teori ...',
 '[{"id":"A","teks":"Lempeng tektonik"},{"id":"B","teks":"Apungan benua"},{"id":"C","teks":"Kontraksi bumi"},{"id":"D","teks":"Dentuman besar"},{"id":"E","teks":"Pergeseran kutub"}]',
 '["B"]',
 'Alfred Wegener mengemukakan teori apungan benua (continental drift) yang menyatakan benua berasal dari satu daratan besar (Pangea) yang terpecah dan bergerak.',
 'ai','valid', false),

((select id from tka_mapel where kode='GEO'), 'Kependudukan', 'sulit', 'pg', null,
 'Piramida penduduk berbentuk limas dengan alas lebar, menunjukkan angka kelahiran yang tinggi dan proporsi penduduk usia muda yang besar, disebut piramida penduduk ...',
 '[{"id":"A","teks":"Ekspansif"},{"id":"B","teks":"Stasioner"},{"id":"C","teks":"Konstruktif"},{"id":"D","teks":"Granat"},{"id":"E","teks":"Tirus terbalik"}]',
 '["A"]',
 'Piramida ekspansif berbentuk limas dengan alas lebar, mencerminkan tingkat kelahiran tinggi dan penduduk usia muda yang dominan.',
 'ai','valid', false);

-- =========================================================
-- SEJ - Sejarah
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='SEJ'), 'Kemerdekaan Indonesia', 'mudah', 'pg', null,
 'Proklamasi kemerdekaan Indonesia dibacakan pada tanggal ...',
 '[{"id":"A","teks":"17 Agustus 1945"},{"id":"B","teks":"20 Mei 1945"},{"id":"C","teks":"28 Oktober 1928"},{"id":"D","teks":"10 November 1945"},{"id":"E","teks":"1 Juni 1945"}]',
 '["A"]',
 'Proklamasi kemerdekaan Indonesia dibacakan oleh Soekarno-Hatta pada tanggal 17 Agustus 1945.',
 'ai','valid', true),

((select id from tka_mapel where kode='SEJ'), 'Kemerdekaan Indonesia', 'mudah', 'pg', null,
 'Tokoh yang membacakan teks proklamasi kemerdekaan Indonesia adalah ...',
 '[{"id":"A","teks":"Soekarno"},{"id":"B","teks":"Mohammad Hatta"},{"id":"C","teks":"Sutan Sjahrir"},{"id":"D","teks":"Soepomo"},{"id":"E","teks":"Tan Malaka"}]',
 '["A"]',
 'Teks proklamasi kemerdekaan Indonesia dibacakan oleh Soekarno, didampingi Mohammad Hatta.',
 'ai','valid', false),

((select id from tka_mapel where kode='SEJ'), 'Pergerakan nasional', 'mudah', 'pg', null,
 'Peristiwa Sumpah Pemuda berlangsung pada tanggal ...',
 '[{"id":"A","teks":"17 Agustus 1945"},{"id":"B","teks":"20 Mei 1908"},{"id":"C","teks":"28 Oktober 1928"},{"id":"D","teks":"10 November 1945"},{"id":"E","teks":"1 Juni 1945"}]',
 '["C"]',
 'Sumpah Pemuda dicetuskan pada Kongres Pemuda II tanggal 28 Oktober 1928.',
 'ai','valid', true),

((select id from tka_mapel where kode='SEJ'), 'Hindu-Buddha di Nusantara', 'sedang', 'pg', null,
 'Berdasarkan bukti prasasti Yupa, kerajaan Hindu tertua di Indonesia adalah ...',
 '[{"id":"A","teks":"Kutai"},{"id":"B","teks":"Tarumanegara"},{"id":"C","teks":"Sriwijaya"},{"id":"D","teks":"Majapahit"},{"id":"E","teks":"Mataram Kuno"}]',
 '["A"]',
 'Prasasti Yupa dari Kalimantan Timur menjadi bukti keberadaan Kerajaan Kutai, yang dikenal sebagai kerajaan Hindu tertua di Indonesia.',
 'ai','valid', false),

((select id from tka_mapel where kode='SEJ'), 'Pergerakan nasional', 'sedang', 'pg', null,
 'Organisasi pergerakan nasional bercorak modern pertama yang berdiri di Indonesia pada tahun 1908 adalah ...',
 '[{"id":"A","teks":"Budi Utomo"},{"id":"B","teks":"Sarekat Islam"},{"id":"C","teks":"Indische Partij"},{"id":"D","teks":"Partai Nasional Indonesia"},{"id":"E","teks":"Muhammadiyah"}]',
 '["A"]',
 'Budi Utomo didirikan pada 20 Mei 1908 dan dianggap sebagai organisasi pergerakan nasional modern pertama di Indonesia.',
 'ai','valid', false),

((select id from tka_mapel where kode='SEJ'), 'Kolonialisme dan imperialisme', 'sedang', 'pg_kompleks', null,
 'Berikut ini yang merupakan dampak kolonialisme Belanda di Indonesia adalah ...',
 '[{"id":"A","teks":"Eksploitasi sumber daya alam untuk kepentingan Belanda"},{"id":"B","teks":"Penerapan sistem tanam paksa (Cultuurstelsel)"},{"id":"C","teks":"Munculnya golongan terpelajar melalui Politik Etis"},{"id":"D","teks":"Kesejahteraan rakyat pribumi meningkat pesat"},{"id":"E","teks":"Tidak adanya perlawanan dari rakyat Indonesia"}]',
 '["A","B","C"]',
 'Kolonialisme Belanda menyebabkan eksploitasi sumber daya alam (A) dan penerapan tanam paksa (B), namun juga memunculkan golongan terpelajar melalui Politik Etis (C). Kesejahteraan rakyat justru menurun (D salah), dan berbagai perlawanan rakyat tetap terjadi di banyak daerah (E salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='SEJ'), 'Kolonialisme dan imperialisme', 'sedang', 'kategori',
 'Politik Etis yang dicanangkan Belanda pada awal abad ke-20 meliputi tiga program utama, yaitu irigasi, edukasi, dan emigrasi. Meski bertujuan membalas budi kepada rakyat jajahan, pelaksanaannya di lapangan lebih banyak menguntungkan pihak Belanda.',
 'Tentukan benar atau salah setiap pernyataan berikut berdasarkan teks.',
 '[{"id":"1","teks":"Politik Etis mencakup tiga program, yaitu irigasi, edukasi, dan emigrasi."},{"id":"2","teks":"Pelaksanaan Politik Etis sepenuhnya menguntungkan rakyat pribumi."}]',
 '{"1":true,"2":false}',
 'Teks menyebutkan tiga program Politik Etis secara eksplisit (pernyataan 1 benar). Teks juga menyatakan pelaksanaannya lebih menguntungkan Belanda, bukan sepenuhnya menguntungkan pribumi (pernyataan 2 salah).',
 'ai','valid', false),

((select id from tka_mapel where kode='SEJ'), 'Kemerdekaan Indonesia', 'sulit', 'pg', null,
 'Perjanjian yang menandai pengakuan kedaulatan Indonesia secara penuh oleh Belanda pada tahun 1949 adalah ...',
 '[{"id":"A","teks":"Perjanjian Linggarjati"},{"id":"B","teks":"Perjanjian Renville"},{"id":"C","teks":"Konferensi Meja Bundar"},{"id":"D","teks":"Perjanjian Roem-Royen"},{"id":"E","teks":"Perjanjian Giyanti"}]',
 '["C"]',
 'Konferensi Meja Bundar (KMB) yang berlangsung di Den Haag pada 1949 menghasilkan pengakuan kedaulatan Indonesia secara penuh oleh Belanda.',
 'ai','valid', false),

((select id from tka_mapel where kode='SEJ'), 'Kemerdekaan Indonesia', 'sulit', 'pg', null,
 'Peristiwa Rengasdengklok terjadi karena ...',
 '[{"id":"A","teks":"Golongan muda mendesak Soekarno-Hatta segera memproklamasikan kemerdekaan"},{"id":"B","teks":"Belanda ingin menunda kemerdekaan Indonesia"},{"id":"C","teks":"Jepang meminta Indonesia menunggu keputusan Sekutu"},{"id":"D","teks":"PPKI menolak melaksanakan proklamasi"},{"id":"E","teks":"Soekarno-Hatta menolak untuk merdeka"}]',
 '["A"]',
 'Golongan muda membawa Soekarno-Hatta ke Rengasdengklok untuk mendesak mereka segera memproklamasikan kemerdekaan tanpa menunggu keputusan PPKI/Jepang.',
 'ai','valid', false),

((select id from tka_mapel where kode='SEJ'), 'Orde lama dan orde baru', 'sulit', 'pg', null,
 'Masa Demokrasi Terpimpin di bawah kepemimpinan Presiden Soekarno berlangsung pada rentang tahun ...',
 '[{"id":"A","teks":"1945-1949"},{"id":"B","teks":"1949-1959"},{"id":"C","teks":"1959-1965"},{"id":"D","teks":"1966-1998"},{"id":"E","teks":"1998-sekarang"}]',
 '["C"]',
 'Demokrasi Terpimpin berlangsung sejak Dekret Presiden 5 Juli 1959 hingga peralihan kekuasaan ke Orde Baru pada tahun 1965/1966.',
 'ai','valid', false);

-- =========================================================
-- JPN - Bahasa Jepang (dasar)
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='JPN'), 'Salam dan sapaan', 'mudah', 'pg', null,
 'Kata "konnichiwa" dalam bahasa Jepang berarti ...',
 '[{"id":"A","teks":"Selamat pagi"},{"id":"B","teks":"Halo / selamat siang"},{"id":"C","teks":"Selamat malam"},{"id":"D","teks":"Selamat tinggal"},{"id":"E","teks":"Terima kasih"}]',
 '["B"]',
 '"Konnichiwa" adalah sapaan umum yang berarti "halo" atau "selamat siang", biasa digunakan pada siang hari.',
 'ai','valid', true),

((select id from tka_mapel where kode='JPN'), 'Kosakata dasar', 'mudah', 'pg', null,
 'Kata "arigatou" dalam bahasa Jepang berarti ...',
 '[{"id":"A","teks":"Maaf"},{"id":"B","teks":"Tolong"},{"id":"C","teks":"Terima kasih"},{"id":"D","teks":"Selamat"},{"id":"E","teks":"Permisi"}]',
 '["C"]',
 '"Arigatou" adalah ungkapan terima kasih dalam bahasa Jepang.',
 'ai','valid', false),

((select id from tka_mapel where kode='JPN'), 'Huruf hiragana', 'mudah', 'pg', null,
 'Huruf hiragana "a" ditulis sebagai ...',
 '[{"id":"A","teks":"あ"},{"id":"B","teks":"い"},{"id":"C","teks":"う"},{"id":"D","teks":"え"},{"id":"E","teks":"お"}]',
 '["A"]',
 'Huruf hiragana untuk bunyi "a" adalah あ; huruf-huruf lain pada pilihan berturut-turut berbunyi i, u, e, o.',
 'ai','valid', false),

((select id from tka_mapel where kode='JPN'), 'Salam dan sapaan', 'sedang', 'pg', null,
 'Ungkapan "ohayou gozaimasu" digunakan untuk mengucapkan ...',
 '[{"id":"A","teks":"Selamat pagi (formal)"},{"id":"B","teks":"Selamat siang"},{"id":"C","teks":"Selamat malam"},{"id":"D","teks":"Selamat tidur"},{"id":"E","teks":"Selamat datang"}]',
 '["A"]',
 '"Ohayou gozaimasu" adalah bentuk formal dari ucapan selamat pagi dalam bahasa Jepang.',
 'ai','valid', false),

((select id from tka_mapel where kode='JPN'), 'Angka dasar', 'sedang', 'pg', null,
 'Kata "yon" dalam bahasa Jepang menunjukkan angka ...',
 '[{"id":"A","teks":"1"},{"id":"B","teks":"2"},{"id":"C","teks":"3"},{"id":"D","teks":"4"},{"id":"E","teks":"5"}]',
 '["D"]',
 '"Yon" adalah salah satu cara membaca angka 4 dalam bahasa Jepang.',
 'ai','valid', false),

((select id from tka_mapel where kode='JPN'), 'Salam dan sapaan', 'sedang', 'pg_kompleks', null,
 'Kata-kata berikut yang termasuk ungkapan sapaan/salam dalam bahasa Jepang adalah ...',
 '[{"id":"A","teks":"konnichiwa (halo)"},{"id":"B","teks":"sayounara (selamat tinggal)"},{"id":"C","teks":"neko (kucing)"},{"id":"D","teks":"oyasumi (selamat tidur)"},{"id":"E","teks":"taberu (makan)"}]',
 '["A","B","D"]',
 'Konnichiwa (A), sayounara (B), dan oyasumi (D) adalah ungkapan sapaan/salam. Neko (C) berarti kucing dan taberu (E) berarti makan, keduanya bukan ungkapan salam.',
 'ai','valid', false),

((select id from tka_mapel where kode='JPN'), 'Tata bahasa dasar', 'sedang', 'kategori',
 'Kalimat bahasa Jepang: "Watashi wa gakusei desu."',
 'Tentukan benar atau salah setiap pernyataan berikut mengenai kalimat tersebut.',
 '[{"id":"1","teks":"Kalimat tersebut berarti Saya adalah pelajar/siswa."},{"id":"2","teks":"Kata gakusei berarti guru."}]',
 '{"1":true,"2":false}',
 '"Watashi wa gakusei desu" berarti "Saya adalah pelajar" (pernyataan 1 benar). "Gakusei" berarti pelajar/siswa, bukan guru (guru = sensei), sehingga pernyataan 2 salah.',
 'ai','valid', false),

((select id from tka_mapel where kode='JPN'), 'Tata bahasa dasar', 'sulit', 'pg', null,
 'Dalam kalimat bahasa Jepang, partikel "wa" (は) umumnya berfungsi sebagai penanda ...',
 '[{"id":"A","teks":"Objek kalimat"},{"id":"B","teks":"Topik/subjek kalimat"},{"id":"C","teks":"Keterangan tempat"},{"id":"D","teks":"Keterangan waktu"},{"id":"E","teks":"Kepemilikan"}]',
 '["B"]',
 'Partikel "wa" (は) menandai topik atau subjek yang sedang dibicarakan dalam kalimat.',
 'ai','valid', false),

((select id from tka_mapel where kode='JPN'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "tabemasu" merupakan bentuk sopan (masu-form) dari kata kerja yang berarti ...',
 '[{"id":"A","teks":"Minum"},{"id":"B","teks":"Makan"},{"id":"C","teks":"Pergi"},{"id":"D","teks":"Melihat"},{"id":"E","teks":"Membaca"}]',
 '["B"]',
 '"Tabemasu" adalah bentuk sopan dari kata kerja "taberu" yang berarti makan.',
 'ai','valid', false),

((select id from tka_mapel where kode='JPN'), 'Huruf katakana', 'sulit', 'pg', null,
 'Huruf katakana dalam bahasa Jepang umumnya digunakan untuk menuliskan ...',
 '[{"id":"A","teks":"Kata asli bahasa Jepang"},{"id":"B","teks":"Kata serapan dari bahasa asing"},{"id":"C","teks":"Partikel tata bahasa"},{"id":"D","teks":"Bilangan"},{"id":"E","teks":"Tanda baca"}]',
 '["B"]',
 'Katakana umumnya digunakan untuk menuliskan kata serapan dari bahasa asing (gairaigo) dan nama asing.',
 'ai','valid', false);

-- =========================================================
-- MAN - Bahasa Mandarin (dasar)
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='MAN'), 'Salam dan sapaan', 'mudah', 'pg', null,
 'Ucapan "Ni hao" dalam bahasa Mandarin berarti ...',
 '[{"id":"A","teks":"Selamat pagi"},{"id":"B","teks":"Halo / apa kabar"},{"id":"C","teks":"Selamat malam"},{"id":"D","teks":"Terima kasih"},{"id":"E","teks":"Selamat tinggal"}]',
 '["B"]',
 '"Ni hao" adalah sapaan umum yang berarti "halo" dalam bahasa Mandarin.',
 'ai','valid', true),

((select id from tka_mapel where kode='MAN'), 'Kosakata dasar', 'mudah', 'pg', null,
 'Ucapan "xiexie" dalam bahasa Mandarin berarti ...',
 '[{"id":"A","teks":"Maaf"},{"id":"B","teks":"Tolong"},{"id":"C","teks":"Terima kasih"},{"id":"D","teks":"Selamat"},{"id":"E","teks":"Permisi"}]',
 '["C"]',
 '"Xiexie" adalah ungkapan terima kasih dalam bahasa Mandarin.',
 'ai','valid', false),

((select id from tka_mapel where kode='MAN'), 'Angka dasar', 'mudah', 'pg', null,
 'Karakter "yi" (satu coretan mendatar) dalam bahasa Mandarin melambangkan angka ...',
 '[{"id":"A","teks":"1"},{"id":"B","teks":"2"},{"id":"C","teks":"3"},{"id":"D","teks":"4"},{"id":"E","teks":"5"}]',
 '["A"]',
 '"Yi" adalah pelafalan angka 1 dalam bahasa Mandarin.',
 'ai','valid', true),

((select id from tka_mapel where kode='MAN'), 'Salam dan sapaan', 'sedang', 'pg', null,
 'Ucapan "zaijian" digunakan ketika seseorang hendak mengucapkan ...',
 '[{"id":"A","teks":"Selamat pagi"},{"id":"B","teks":"Halo"},{"id":"C","teks":"Sampai jumpa / selamat tinggal"},{"id":"D","teks":"Terima kasih"},{"id":"E","teks":"Selamat malam"}]',
 '["C"]',
 '"Zaijian" berarti "sampai jumpa" dan digunakan saat berpisah.',
 'ai','valid', false),

((select id from tka_mapel where kode='MAN'), 'Kosakata dasar', 'sedang', 'pg', null,
 'Kata "mama" dalam bahasa Mandarin berarti ...',
 '[{"id":"A","teks":"Ayah"},{"id":"B","teks":"Ibu"},{"id":"C","teks":"Kakak"},{"id":"D","teks":"Adik"},{"id":"E","teks":"Nenek"}]',
 '["B"]',
 '"Mama" dalam bahasa Mandarin berarti ibu.',
 'ai','valid', false),

((select id from tka_mapel where kode='MAN'), 'Salam dan sapaan', 'sedang', 'pg_kompleks', null,
 'Ungkapan-ungkapan berikut yang termasuk sapaan/salam dalam bahasa Mandarin adalah ...',
 '[{"id":"A","teks":"Ni hao (halo)"},{"id":"B","teks":"Zaijian (selamat tinggal)"},{"id":"C","teks":"Mao (kucing)"},{"id":"D","teks":"Zaoshang hao (selamat pagi)"},{"id":"E","teks":"Chifan (makan)"}]',
 '["A","B","D"]',
 'Ni hao (A), zaijian (B), dan zaoshang hao (D) adalah ungkapan sapaan/salam. Mao (C) berarti kucing dan chifan (E) berarti makan, keduanya bukan ungkapan salam.',
 'ai','valid', false),

((select id from tka_mapel where kode='MAN'), 'Tata bahasa dasar', 'sedang', 'kategori',
 'Kalimat bahasa Mandarin: "Wo shi xuesheng."',
 'Tentukan benar atau salah setiap pernyataan berikut mengenai kalimat tersebut.',
 '[{"id":"1","teks":"Kalimat tersebut berarti Saya adalah pelajar."},{"id":"2","teks":"Kata xuesheng berarti guru."}]',
 '{"1":true,"2":false}',
 '"Wo shi xuesheng" berarti "Saya adalah pelajar" (pernyataan 1 benar). "Xuesheng" berarti pelajar/siswa, bukan guru (guru = laoshi), sehingga pernyataan 2 salah.',
 'ai','valid', false),

((select id from tka_mapel where kode='MAN'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "laoshi" dalam bahasa Mandarin berarti ...',
 '[{"id":"A","teks":"Siswa"},{"id":"B","teks":"Guru"},{"id":"C","teks":"Dokter"},{"id":"D","teks":"Petani"},{"id":"E","teks":"Pedagang"}]',
 '["B"]',
 '"Laoshi" berarti guru dalam bahasa Mandarin.',
 'ai','valid', false),

((select id from tka_mapel where kode='MAN'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "he" dalam bahasa Mandarin berarti ...',
 '[{"id":"A","teks":"Makan"},{"id":"B","teks":"Minum"},{"id":"C","teks":"Tidur"},{"id":"D","teks":"Berjalan"},{"id":"E","teks":"Membaca"}]',
 '["B"]',
 '"He" berarti minum dalam bahasa Mandarin.',
 'ai','valid', false),

((select id from tka_mapel where kode='MAN'), 'Sistem penulisan', 'sulit', 'pg', null,
 'Sistem romanisasi yang menggunakan huruf Latin untuk membantu pelafalan bahasa Mandarin disebut ...',
 '[{"id":"A","teks":"Hanzi"},{"id":"B","teks":"Pinyin"},{"id":"C","teks":"Kanji"},{"id":"D","teks":"Hangul"},{"id":"E","teks":"Katakana"}]',
 '["B"]',
 'Pinyin adalah sistem romanisasi resmi yang menggunakan huruf Latin untuk membantu pelafalan bahasa Mandarin.',
 'ai','valid', false);

-- =========================================================
-- KOR - Bahasa Korea (dasar)
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='KOR'), 'Salam dan sapaan', 'mudah', 'pg', null,
 'Ucapan "annyeonghaseyo" dalam bahasa Korea berarti ...',
 '[{"id":"A","teks":"Selamat pagi"},{"id":"B","teks":"Halo / apa kabar"},{"id":"C","teks":"Selamat malam"},{"id":"D","teks":"Terima kasih"},{"id":"E","teks":"Selamat tinggal"}]',
 '["B"]',
 '"Annyeonghaseyo" adalah sapaan formal umum yang berarti "halo" dalam bahasa Korea.',
 'ai','valid', true),

((select id from tka_mapel where kode='KOR'), 'Kosakata dasar', 'mudah', 'pg', null,
 'Ucapan "gamsahamnida" dalam bahasa Korea berarti ...',
 '[{"id":"A","teks":"Maaf"},{"id":"B","teks":"Tolong"},{"id":"C","teks":"Terima kasih"},{"id":"D","teks":"Selamat"},{"id":"E","teks":"Permisi"}]',
 '["C"]',
 '"Gamsahamnida" adalah ungkapan terima kasih formal dalam bahasa Korea.',
 'ai','valid', false),

((select id from tka_mapel where kode='KOR'), 'Kosakata dasar', 'mudah', 'pg', null,
 'Ucapan "joesonghamnida" dalam bahasa Korea berarti ...',
 '[{"id":"A","teks":"Terima kasih"},{"id":"B","teks":"Selamat pagi"},{"id":"C","teks":"Maaf"},{"id":"D","teks":"Tolong"},{"id":"E","teks":"Halo"}]',
 '["C"]',
 '"Joesonghamnida" adalah ungkapan permintaan maaf formal dalam bahasa Korea.',
 'ai','valid', true),

((select id from tka_mapel where kode='KOR'), 'Angka dasar', 'sedang', 'pg', null,
 'Dalam sistem angka asli Korea, kata "hana" menunjukkan angka ...',
 '[{"id":"A","teks":"1"},{"id":"B","teks":"2"},{"id":"C","teks":"3"},{"id":"D","teks":"4"},{"id":"E","teks":"5"}]',
 '["A"]',
 'Dalam sistem angka asli (native) Korea, "hana" berarti 1, diikuti "dul" (2), "set" (3), "net" (4), dan "daseot" (5).',
 'ai','valid', false),

((select id from tka_mapel where kode='KOR'), 'Kosakata dasar', 'sedang', 'pg', null,
 'Kata "eomma" dalam bahasa Korea berarti ...',
 '[{"id":"A","teks":"Ayah"},{"id":"B","teks":"Ibu"},{"id":"C","teks":"Kakak"},{"id":"D","teks":"Adik"},{"id":"E","teks":"Nenek"}]',
 '["B"]',
 '"Eomma" adalah sebutan akrab untuk ibu dalam bahasa Korea.',
 'ai','valid', false),

((select id from tka_mapel where kode='KOR'), 'Salam dan sapaan', 'sedang', 'pg_kompleks', null,
 'Ungkapan-ungkapan berikut yang termasuk sapaan/salam dalam bahasa Korea adalah ...',
 '[{"id":"A","teks":"Annyeonghaseyo (halo)"},{"id":"B","teks":"Annyeonghi gyeseyo (selamat tinggal, diucapkan pada yang tinggal)"},{"id":"C","teks":"Goyangi (kucing)"},{"id":"D","teks":"Joeun achimimnida (selamat pagi)"},{"id":"E","teks":"Meokda (makan)"}]',
 '["A","B","D"]',
 'Annyeonghaseyo (A), annyeonghi gyeseyo (B), dan joeun achimimnida (D) adalah ungkapan sapaan/salam. Goyangi (C) berarti kucing dan meokda (E) berarti makan, keduanya bukan ungkapan salam.',
 'ai','valid', false),

((select id from tka_mapel where kode='KOR'), 'Tata bahasa dasar', 'sedang', 'kategori',
 'Kalimat bahasa Korea: "Jeoneun haksaeng-imnida."',
 'Tentukan benar atau salah setiap pernyataan berikut mengenai kalimat tersebut.',
 '[{"id":"1","teks":"Kalimat tersebut berarti Saya adalah pelajar."},{"id":"2","teks":"Kata haksaeng berarti guru."}]',
 '{"1":true,"2":false}',
 '"Jeoneun haksaeng-imnida" berarti "Saya adalah pelajar" (pernyataan 1 benar). "Haksaeng" berarti pelajar/siswa, bukan guru (guru = seonsaengnim), sehingga pernyataan 2 salah.',
 'ai','valid', false),

((select id from tka_mapel where kode='KOR'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "seonsaengnim" dalam bahasa Korea berarti ...',
 '[{"id":"A","teks":"Siswa"},{"id":"B","teks":"Guru"},{"id":"C","teks":"Dokter"},{"id":"D","teks":"Petani"},{"id":"E","teks":"Pedagang"}]',
 '["B"]',
 '"Seonsaengnim" berarti guru dalam bahasa Korea, digunakan sebagai sapaan hormat.',
 'ai','valid', false),

((select id from tka_mapel where kode='KOR'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "masida" dalam bahasa Korea berarti ...',
 '[{"id":"A","teks":"Makan"},{"id":"B","teks":"Minum"},{"id":"C","teks":"Tidur"},{"id":"D","teks":"Berjalan"},{"id":"E","teks":"Membaca"}]',
 '["B"]',
 '"Masida" berarti minum dalam bahasa Korea.',
 'ai','valid', false),

((select id from tka_mapel where kode='KOR'), 'Sistem penulisan', 'sulit', 'pg', null,
 'Sistem tulisan asli Korea yang diciptakan pada masa pemerintahan Raja Sejong disebut ...',
 '[{"id":"A","teks":"Hanja"},{"id":"B","teks":"Hangul"},{"id":"C","teks":"Kanji"},{"id":"D","teks":"Kana"},{"id":"E","teks":"Pinyin"}]',
 '["B"]',
 'Hangul adalah sistem tulisan asli Korea yang diciptakan pada masa Raja Sejong pada abad ke-15.',
 'ai','valid', false);

-- =========================================================
-- ARB - Bahasa Arab (dasar)
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='ARB'), 'Salam dan sapaan', 'mudah', 'pg', null,
 'Ucapan "Assalamu''alaikum" dalam bahasa Arab berarti ...',
 '[{"id":"A","teks":"Selamat pagi"},{"id":"B","teks":"Semoga keselamatan tercurah kepadamu (salam umum)"},{"id":"C","teks":"Selamat malam"},{"id":"D","teks":"Terima kasih"},{"id":"E","teks":"Selamat tinggal"}]',
 '["B"]',
 '"Assalamu''alaikum" adalah salam umum yang bermakna "semoga keselamatan tercurah kepadamu".',
 'ai','valid', true),

((select id from tka_mapel where kode='ARB'), 'Kosakata dasar', 'mudah', 'pg', null,
 'Kata "syukron" dalam bahasa Arab berarti ...',
 '[{"id":"A","teks":"Maaf"},{"id":"B","teks":"Tolong"},{"id":"C","teks":"Terima kasih"},{"id":"D","teks":"Selamat"},{"id":"E","teks":"Permisi"}]',
 '["C"]',
 '"Syukron" adalah ungkapan terima kasih dalam bahasa Arab.',
 'ai','valid', false),

((select id from tka_mapel where kode='ARB'), 'Kosakata dasar', 'mudah', 'pg', null,
 'Kata "aasif" dalam bahasa Arab berarti ...',
 '[{"id":"A","teks":"Terima kasih"},{"id":"B","teks":"Selamat pagi"},{"id":"C","teks":"Maaf"},{"id":"D","teks":"Tolong"},{"id":"E","teks":"Halo"}]',
 '["C"]',
 '"Aasif" adalah ungkapan permintaan maaf (untuk penutur laki-laki) dalam bahasa Arab.',
 'ai','valid', true),

((select id from tka_mapel where kode='ARB'), 'Angka dasar', 'sedang', 'pg', null,
 'Kata "wahid" dalam bahasa Arab menunjukkan angka ...',
 '[{"id":"A","teks":"1"},{"id":"B","teks":"2"},{"id":"C","teks":"3"},{"id":"D","teks":"4"},{"id":"E","teks":"5"}]',
 '["A"]',
 '"Wahid" berarti angka 1 dalam bahasa Arab.',
 'ai','valid', false),

((select id from tka_mapel where kode='ARB'), 'Kosakata dasar', 'sedang', 'pg', null,
 'Kata "umm" dalam bahasa Arab berarti ...',
 '[{"id":"A","teks":"Ayah"},{"id":"B","teks":"Ibu"},{"id":"C","teks":"Kakak"},{"id":"D","teks":"Adik"},{"id":"E","teks":"Nenek"}]',
 '["B"]',
 '"Umm" berarti ibu dalam bahasa Arab.',
 'ai','valid', false),

((select id from tka_mapel where kode='ARB'), 'Salam dan sapaan', 'sedang', 'pg_kompleks', null,
 'Ungkapan-ungkapan berikut yang termasuk sapaan/salam dalam bahasa Arab adalah ...',
 '[{"id":"A","teks":"Assalamu''alaikum (salam umum)"},{"id":"B","teks":"Ma''a as-salamah (selamat tinggal / pergilah dengan selamat)"},{"id":"C","teks":"Qittah (kucing)"},{"id":"D","teks":"Sabah al-khair (selamat pagi)"},{"id":"E","teks":"Ya''kulu (dia makan)"}]',
 '["A","B","D"]',
 'Assalamu''alaikum (A), ma''a as-salamah (B), dan sabah al-khair (D) adalah ungkapan sapaan/salam. Qittah (C) berarti kucing dan ya''kulu (E) berarti dia makan, keduanya bukan ungkapan salam.',
 'ai','valid', false),

((select id from tka_mapel where kode='ARB'), 'Tata bahasa dasar', 'sedang', 'kategori',
 'Kalimat bahasa Arab: "Ana thalib." (diucapkan oleh penutur laki-laki)',
 'Tentukan benar atau salah setiap pernyataan berikut mengenai kalimat tersebut.',
 '[{"id":"1","teks":"Kalimat tersebut berarti Saya adalah pelajar."},{"id":"2","teks":"Kata thalib berarti guru."}]',
 '{"1":true,"2":false}',
 '"Ana thalib" berarti "Saya adalah pelajar" (pernyataan 1 benar). "Thalib" berarti pelajar/siswa, bukan guru (guru = mu''allim), sehingga pernyataan 2 salah.',
 'ai','valid', false),

((select id from tka_mapel where kode='ARB'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "mu''allim" dalam bahasa Arab berarti ...',
 '[{"id":"A","teks":"Siswa"},{"id":"B","teks":"Guru"},{"id":"C","teks":"Dokter"},{"id":"D","teks":"Petani"},{"id":"E","teks":"Pedagang"}]',
 '["B"]',
 '"Mu''allim" berarti guru (laki-laki) dalam bahasa Arab.',
 'ai','valid', false),

((select id from tka_mapel where kode='ARB'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "yashrabu" dalam bahasa Arab berarti dia ...',
 '[{"id":"A","teks":"Makan"},{"id":"B","teks":"Minum"},{"id":"C","teks":"Tidur"},{"id":"D","teks":"Berjalan"},{"id":"E","teks":"Membaca"}]',
 '["B"]',
 '"Yashrabu" berarti "dia (laki-laki) minum" dalam bahasa Arab.',
 'ai','valid', false),

((select id from tka_mapel where kode='ARB'), 'Sistem penulisan', 'sulit', 'pg', null,
 'Tulisan Arab dibaca dan ditulis dengan arah ...',
 '[{"id":"A","teks":"Kiri ke kanan"},{"id":"B","teks":"Kanan ke kiri"},{"id":"C","teks":"Atas ke bawah"},{"id":"D","teks":"Bawah ke atas"},{"id":"E","teks":"Tidak beraturan"}]',
 '["B"]',
 'Aksara Arab ditulis dan dibaca dari arah kanan ke kiri.',
 'ai','valid', false);

-- =========================================================
-- PRA - Bahasa Prancis (dasar)
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='PRA'), 'Salam dan sapaan', 'mudah', 'pg', null,
 'Ucapan "Bonjour" dalam bahasa Prancis berarti ...',
 '[{"id":"A","teks":"Selamat pagi / siang / halo (umum)"},{"id":"B","teks":"Selamat malam"},{"id":"C","teks":"Terima kasih"},{"id":"D","teks":"Selamat tinggal"},{"id":"E","teks":"Maaf"}]',
 '["A"]',
 '"Bonjour" adalah sapaan umum dalam bahasa Prancis yang digunakan pada pagi hingga sore hari.',
 'ai','valid', true),

((select id from tka_mapel where kode='PRA'), 'Kosakata dasar', 'mudah', 'pg', null,
 'Kata "merci" dalam bahasa Prancis berarti ...',
 '[{"id":"A","teks":"Maaf"},{"id":"B","teks":"Tolong"},{"id":"C","teks":"Terima kasih"},{"id":"D","teks":"Selamat"},{"id":"E","teks":"Permisi"}]',
 '["C"]',
 '"Merci" adalah ungkapan terima kasih dalam bahasa Prancis.',
 'ai','valid', false),

((select id from tka_mapel where kode='PRA'), 'Salam dan sapaan', 'mudah', 'pg', null,
 'Ucapan "au revoir" dalam bahasa Prancis berarti ...',
 '[{"id":"A","teks":"Halo"},{"id":"B","teks":"Terima kasih"},{"id":"C","teks":"Selamat tinggal / sampai jumpa"},{"id":"D","teks":"Maaf"},{"id":"E","teks":"Tolong"}]',
 '["C"]',
 '"Au revoir" adalah ungkapan perpisahan yang berarti "sampai jumpa" dalam bahasa Prancis.',
 'ai','valid', true),

((select id from tka_mapel where kode='PRA'), 'Tata bahasa dasar', 'sedang', 'pg', null,
 'Kata ganti "je" dalam bahasa Prancis berarti ...',
 '[{"id":"A","teks":"Kamu"},{"id":"B","teks":"Saya"},{"id":"C","teks":"Dia (laki-laki)"},{"id":"D","teks":"Kita"},{"id":"E","teks":"Mereka"}]',
 '["B"]',
 '"Je" adalah kata ganti orang pertama tunggal yang berarti "saya" dalam bahasa Prancis.',
 'ai','valid', false),

((select id from tka_mapel where kode='PRA'), 'Kosakata dasar', 'sedang', 'pg', null,
 'Kata "manger" dalam bahasa Prancis berarti ...',
 '[{"id":"A","teks":"Minum"},{"id":"B","teks":"Makan"},{"id":"C","teks":"Tidur"},{"id":"D","teks":"Berjalan"},{"id":"E","teks":"Membaca"}]',
 '["B"]',
 '"Manger" berarti makan dalam bahasa Prancis.',
 'ai','valid', false),

((select id from tka_mapel where kode='PRA'), 'Salam dan sapaan', 'sedang', 'pg_kompleks', null,
 'Ungkapan-ungkapan berikut yang termasuk sapaan/salam dalam bahasa Prancis adalah ...',
 '[{"id":"A","teks":"Bonjour (halo)"},{"id":"B","teks":"Bonsoir (selamat malam)"},{"id":"C","teks":"Chat (kucing)"},{"id":"D","teks":"Au revoir (selamat tinggal)"},{"id":"E","teks":"Manger (makan)"}]',
 '["A","B","D"]',
 'Bonjour (A), bonsoir (B), dan au revoir (D) adalah ungkapan sapaan/salam. Chat (C) berarti kucing dan manger (E) berarti makan, keduanya bukan ungkapan salam.',
 'ai','valid', false),

((select id from tka_mapel where kode='PRA'), 'Tata bahasa dasar', 'sedang', 'kategori',
 'Kalimat bahasa Prancis: "Je suis etudiant." (diucapkan oleh penutur laki-laki)',
 'Tentukan benar atau salah setiap pernyataan berikut mengenai kalimat tersebut.',
 '[{"id":"1","teks":"Kalimat tersebut berarti Saya adalah pelajar/mahasiswa."},{"id":"2","teks":"Kata etudiant berarti guru."}]',
 '{"1":true,"2":false}',
 '"Je suis etudiant" berarti "Saya adalah mahasiswa/pelajar" (pernyataan 1 benar). "Etudiant" berarti pelajar/mahasiswa, bukan guru (guru = professeur), sehingga pernyataan 2 salah.',
 'ai','valid', false),

((select id from tka_mapel where kode='PRA'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "professeur" dalam bahasa Prancis berarti ...',
 '[{"id":"A","teks":"Siswa"},{"id":"B","teks":"Guru / dosen"},{"id":"C","teks":"Dokter"},{"id":"D","teks":"Petani"},{"id":"E","teks":"Pedagang"}]',
 '["B"]',
 '"Professeur" berarti guru atau dosen dalam bahasa Prancis.',
 'ai','valid', false),

((select id from tka_mapel where kode='PRA'), 'Tata bahasa dasar', 'sulit', 'pg', null,
 'Bentuk konjugasi kata kerja "etre" (menjadi/adalah) untuk kata ganti "je" adalah ...',
 '[{"id":"A","teks":"suis"},{"id":"B","teks":"es"},{"id":"C","teks":"est"},{"id":"D","teks":"sommes"},{"id":"E","teks":"etes"}]',
 '["A"]',
 'Konjugasi kata kerja "etre" untuk subjek "je" adalah "suis" (je suis = saya adalah).',
 'ai','valid', false),

((select id from tka_mapel where kode='PRA'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "boire" dalam bahasa Prancis berarti ...',
 '[{"id":"A","teks":"Makan"},{"id":"B","teks":"Minum"},{"id":"C","teks":"Tidur"},{"id":"D","teks":"Berjalan"},{"id":"E","teks":"Membaca"}]',
 '["B"]',
 '"Boire" berarti minum dalam bahasa Prancis.',
 'ai','valid', false);

-- =========================================================
-- JER - Bahasa Jerman (dasar)
-- =========================================================
insert into tka_soal (mapel_id, topik, kesulitan, bentuk, stimulus, pertanyaan, opsi, kunci, pembahasan, sumber, status, soal_harian) values
((select id from tka_mapel where kode='JER'), 'Salam dan sapaan', 'mudah', 'pg', null,
 'Ucapan "Guten Tag" dalam bahasa Jerman berarti ...',
 '[{"id":"A","teks":"Selamat pagi"},{"id":"B","teks":"Selamat siang / halo (umum)"},{"id":"C","teks":"Selamat malam"},{"id":"D","teks":"Terima kasih"},{"id":"E","teks":"Selamat tinggal"}]',
 '["B"]',
 '"Guten Tag" adalah sapaan umum dalam bahasa Jerman yang digunakan pada siang hari.',
 'ai','valid', true),

((select id from tka_mapel where kode='JER'), 'Kosakata dasar', 'mudah', 'pg', null,
 'Kata "danke" dalam bahasa Jerman berarti ...',
 '[{"id":"A","teks":"Maaf"},{"id":"B","teks":"Tolong"},{"id":"C","teks":"Terima kasih"},{"id":"D","teks":"Selamat"},{"id":"E","teks":"Permisi"}]',
 '["C"]',
 '"Danke" adalah ungkapan terima kasih dalam bahasa Jerman.',
 'ai','valid', false),

((select id from tka_mapel where kode='JER'), 'Salam dan sapaan', 'mudah', 'pg', null,
 'Ucapan "Auf Wiedersehen" dalam bahasa Jerman berarti ...',
 '[{"id":"A","teks":"Halo"},{"id":"B","teks":"Terima kasih"},{"id":"C","teks":"Selamat tinggal / sampai jumpa"},{"id":"D","teks":"Maaf"},{"id":"E","teks":"Tolong"}]',
 '["C"]',
 '"Auf Wiedersehen" adalah ungkapan perpisahan formal yang berarti "sampai jumpa" dalam bahasa Jerman.',
 'ai','valid', true),

((select id from tka_mapel where kode='JER'), 'Tata bahasa dasar', 'sedang', 'pg', null,
 'Kata ganti "ich" dalam bahasa Jerman berarti ...',
 '[{"id":"A","teks":"Kamu"},{"id":"B","teks":"Saya"},{"id":"C","teks":"Dia (laki-laki)"},{"id":"D","teks":"Kita"},{"id":"E","teks":"Mereka"}]',
 '["B"]',
 '"Ich" adalah kata ganti orang pertama tunggal yang berarti "saya" dalam bahasa Jerman.',
 'ai','valid', false),

((select id from tka_mapel where kode='JER'), 'Kosakata dasar', 'sedang', 'pg', null,
 'Kata "essen" dalam bahasa Jerman berarti ...',
 '[{"id":"A","teks":"Minum"},{"id":"B","teks":"Makan"},{"id":"C","teks":"Tidur"},{"id":"D","teks":"Berjalan"},{"id":"E","teks":"Membaca"}]',
 '["B"]',
 '"Essen" berarti makan dalam bahasa Jerman.',
 'ai','valid', false),

((select id from tka_mapel where kode='JER'), 'Salam dan sapaan', 'sedang', 'pg_kompleks', null,
 'Ungkapan-ungkapan berikut yang termasuk sapaan/salam dalam bahasa Jerman adalah ...',
 '[{"id":"A","teks":"Guten Tag (halo/selamat siang)"},{"id":"B","teks":"Guten Abend (selamat malam)"},{"id":"C","teks":"Katze (kucing)"},{"id":"D","teks":"Auf Wiedersehen (selamat tinggal)"},{"id":"E","teks":"Essen (makan)"}]',
 '["A","B","D"]',
 'Guten Tag (A), guten Abend (B), dan Auf Wiedersehen (D) adalah ungkapan sapaan/salam. Katze (C) berarti kucing dan essen (E) berarti makan, keduanya bukan ungkapan salam.',
 'ai','valid', false),

((select id from tka_mapel where kode='JER'), 'Tata bahasa dasar', 'sedang', 'kategori',
 'Kalimat bahasa Jerman: "Ich bin Student." (diucapkan oleh penutur laki-laki)',
 'Tentukan benar atau salah setiap pernyataan berikut mengenai kalimat tersebut.',
 '[{"id":"1","teks":"Kalimat tersebut berarti Saya adalah pelajar/mahasiswa."},{"id":"2","teks":"Kata Student berarti guru."}]',
 '{"1":true,"2":false}',
 '"Ich bin Student" berarti "Saya adalah mahasiswa/pelajar" (pernyataan 1 benar). "Student" berarti pelajar/mahasiswa, bukan guru (guru = Lehrer), sehingga pernyataan 2 salah.',
 'ai','valid', false),

((select id from tka_mapel where kode='JER'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "Lehrer" dalam bahasa Jerman berarti ...',
 '[{"id":"A","teks":"Siswa"},{"id":"B","teks":"Guru"},{"id":"C","teks":"Dokter"},{"id":"D","teks":"Petani"},{"id":"E","teks":"Pedagang"}]',
 '["B"]',
 '"Lehrer" berarti guru (laki-laki) dalam bahasa Jerman.',
 'ai','valid', false),

((select id from tka_mapel where kode='JER'), 'Tata bahasa dasar', 'sulit', 'pg', null,
 'Bentuk konjugasi kata kerja "sein" (menjadi/adalah) untuk kata ganti "ich" adalah ...',
 '[{"id":"A","teks":"bin"},{"id":"B","teks":"bist"},{"id":"C","teks":"ist"},{"id":"D","teks":"sind"},{"id":"E","teks":"seid"}]',
 '["A"]',
 'Konjugasi kata kerja "sein" untuk subjek "ich" adalah "bin" (ich bin = saya adalah).',
 'ai','valid', false),

((select id from tka_mapel where kode='JER'), 'Kosakata dasar', 'sulit', 'pg', null,
 'Kata "trinken" dalam bahasa Jerman berarti ...',
 '[{"id":"A","teks":"Makan"},{"id":"B","teks":"Minum"},{"id":"C","teks":"Tidur"},{"id":"D","teks":"Berjalan"},{"id":"E","teks":"Membaca"}]',
 '["B"]',
 '"Trinken" berarti minum dalam bahasa Jerman.',
 'ai','valid', false);
