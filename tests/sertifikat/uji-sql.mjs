// Uji migrasi 005 (sertifikat) di Postgres lokal.
//   PGLITE_DIR=<folder pglite> node tests/sertifikat/uji-sql.mjs
import { bukaDb, rpc, sebagai } from './pg-lokal.mjs';

let lulus = 0, gagal = 0;
function cek(nama, ok, info) {
  if (ok) { lulus++; console.log('  ok  ' + nama); }
  else { gagal++; console.log('GAGAL ' + nama, info === undefined ? '' : JSON.stringify(info).slice(0, 300)); }
}
async function harusGagal(nama, fn, pola) {
  try { const r = await fn(); cek(nama, false, { hasil: r }); }
  catch (e) { cek(nama, !pola || pola.test(e.message), e.message); }
}

const ADMIN = { sub: 'u1', email: 'danny@uphcollege.com', role: 'authenticated', app_metadata: { sertifikat_admin: true } };
const BIASA = { sub: 'u2', email: 'guru@uphcollege.com', role: 'authenticated', app_metadata: { surat_admin: true } };
const NAKAL = { sub: 'u3', email: 'x@x.com', role: 'authenticated', user_metadata: { sertifikat_admin: true } };
const tahun = Number(new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Jakarta', year: 'numeric' }).format(new Date()));
const hari = `${tahun}-11-20`;
const item = (nama, x) => Object.assign({ title: 'appreciation', name: nama, lead: { t: 'for achieving', brk: 0 }, conn: 'at', ach: 'First Place',
  role: '', event: 'Science Fair', subtitle: '', organizer: '', mode: 'single', d1: hari, d2: '', ay: '', issuedOn: hari }, x || {});
const idp = (s) => (s + 'abcdefghjkmnpqrstuvwxyz23456789').slice(0, 24);
const PNG = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

const db = await bukaDb();
const A = (f, a) => rpc(db, 'authenticated', ADMIN, f, a);

console.log('Akses');
await harusGagal('anon tidak bisa membaca tabel sertifikat', () => sebagai(db, 'anon', {}, 'select * from sertifikat'), /permission denied/);
await harusGagal('akun login biasa tidak bisa membaca tabel langsung', () => sebagai(db, 'authenticated', ADMIN, 'select * from sertifikat_ttd'), /permission denied/);
await harusGagal('anon tidak bisa memanggil fungsi terbit', () => rpc(db, 'anon', {}, 'terbitkan_sertifikat', { p_items: [item('X')], p_id_permintaan: idp('a') }), /permission denied/);
await harusGagal('akun tanpa tanda sertifikat_admin ditolak', () => rpc(db, 'authenticated', BIASA, 'sertifikat_awal', {}), /belum diberi akses/);
await harusGagal('tanda di user_metadata (bisa diubah sendiri) tidak dihitung', () => rpc(db, 'authenticated', NAKAL, 'sertifikat_awal', {}), /belum diberi akses/);
await harusGagal('fungsi pembantu tidak bisa dipanggil dari luar', () => rpc(db, 'authenticated', ADMIN, 'sertifikat_perlu_admin', {}), /permission denied/);

console.log('Awal');
let r = await A('sertifikat_awal', {});
cek('data awal lengkap', r.me === ADMIN.email && Array.isArray(r.records) && r.phrases.v === 3 && r.settings.unit === 'CERT' && r.settings.startYear === tahun, r);

console.log('TTD');
await harusGagal('gambar berisi skrip ditolak', () => A('simpan_ttd_sertifikat', { p_sisi: 'l', p_nama: 'Hans', p_jabatan: 'P', p_gambar: 'x" onerror="alert(1)' }), /PNG atau JPEG/);
await harusGagal('SVG ditolak (harus PNG/JPEG)', () => A('simpan_ttd_sertifikat', { p_sisi: 'l', p_nama: 'Hans', p_jabatan: 'P', p_gambar: 'data:image/svg+xml;base64,PHN2Zz4=' }), /PNG atau JPEG/);
r = await A('simpan_ttd_sertifikat', { p_sisi: 'l', p_nama: 'Hans Deny', p_jabatan: 'Academic Principal', p_gambar: PNG });
cek('TTD kiri tersimpan', r.sig.name === 'Hans Deny' && r.sig.img === PNG && r.logs[0].action === 'Signatories Updated', r);
await A('simpan_ttd_sertifikat', { p_sisi: 'r', p_nama: 'Wiginy Kusliawan', p_jabatan: 'Executive Director', p_gambar: PNG });

console.log('Terbit');
r = await A('terbitkan_sertifikat', { p_items: [item('Budi Santoso'), item('Siti Rahma', { ach: 'Best Speaker' })], p_id_permintaan: idp('req1') });
const budi = r.records[0];
cek('2 sertifikat terbit', r.records.length === 2, r);
cek('nomor 0001 dan 0002', budi.num === `0001/CERT/UPHC/XI/${tahun}` && r.records[1].num === `0002/CERT/UPHC/XI/${tahun}`, r.records.map((x) => x.num));
cek('token 24 karakter acak', /^[a-z0-9]{24}$/.test(budi.token) && budi.token !== r.records[1].token, budi.token);
cek('pembuat = email admin', budi.issuedBy === ADMIN.email, budi.issuedBy);
cek('tanggal tetap YYYY-MM-DD', budi.issuedOn === hari && budi.d1 === hari, budi);
cek('seq berupa angka', budi.seq === 1, budi.seq);
cek('TTD ikut tercatat', r.sigs[budi.sigL] && r.sigs[budi.sigL].name === 'Hans Deny' && r.sigs[budi.sigR].name === 'Wiginy Kusliawan', r.sigs);
r = await A('terbitkan_sertifikat', { p_items: [item('Budi Santoso'), item('Siti Rahma')], p_id_permintaan: idp('req1') });
cek('kirim ulang ID yang sama tidak membuat ganda', r.replay === true && r.records.length === 2 && r.records[0].token === budi.token, r);
r = await A('sertifikat_awal', {});
cek('registri tetap 2', r.records.length === 2, r.records.length);

await harusGagal('nama kosong ditolak', () => A('terbitkan_sertifikat', { p_items: [item('  ')], p_id_permintaan: idp('b1') }), /Nama belum diisi/);
await harusGagal('tanpa prestasi & acara ditolak', () => A('terbitkan_sertifikat', { p_items: [item('A', { ach: '', event: '' })], p_id_permintaan: idp('b2') }), /prestasi atau acara/);
await harusGagal('tanggal mustahil ditolak', () => A('terbitkan_sertifikat', { p_items: [item('A', { issuedOn: `${tahun}-02-30` })], p_id_permintaan: idp('b3') }), /Tanggal terbit/);
await harusGagal('tanggal selesai sebelum mulai ditolak', () => A('terbitkan_sertifikat', { p_items: [item('A', { mode: 'range', d1: hari, d2: `${tahun}-01-01` })], p_id_permintaan: idp('b4') }), /sebelum tanggal mulai/);
await harusGagal('lebih dari 100 ditolak', () => A('terbitkan_sertifikat', { p_items: Array.from({ length: 101 }, (_, i) => item('P' + i)), p_id_permintaan: idp('b5') }), /100/);
await harusGagal('batch gagal di tengah tidak menyimpan apa pun', () => A('terbitkan_sertifikat', { p_items: [item('Ok'), item('')], p_id_permintaan: idp('b6') }), /baris 2/);
r = await A('sertifikat_awal', {});
cek('setelah batch gagal registri tetap 2', r.records.length === 2, r.records.length);
await harusGagal('ID permintaan aneh ditolak', () => A('terbitkan_sertifikat', { p_items: [item('A')], p_id_permintaan: "x'; drop table sertifikat;--" }), /ID permintaan/);

r = await A('terbitkan_sertifikat', { p_items: [item('Andi', { mode: 'multi', d1: `${tahun}-10-05,${tahun}-10-03,${tahun}-10-05,bukan` }), item('Dewi', { mode: 'academic', ay: '2025' }), item('<img src=x onerror=alert(1)>  Eka', { mode: 'none' })], p_id_permintaan: idp('req2') });
cek('beberapa tanggal: diurutkan & dobel dibuang', r.records[0].d1 === `${tahun}-10-03,${tahun}-10-05`, r.records[0].d1);
cek('tahun ajaran tersimpan', r.records[1].ay === '2025' && r.records[1].mode === 'academic', r.records[1]);
cek('nama berisi HTML disimpan apa adanya sebagai teks (halaman yang meng-escape)', r.records[2].name === '<img src=x onerror=alert(1)> Eka', r.records[2].name);
const eka = r.records[2];

console.log('Halaman QR (anon)');
r = await rpc(db, 'anon', {}, 'cek_sertifikat', { p_token: budi.token });
cek('sertifikat sah ditemukan', r.found && r.rec.status === 'valid' && r.rec.name === 'Budi Santoso' && r.rec.num === budi.num, r);
cek('tanpa gambar TTD, pembuat, alasan batal', !JSON.stringify(r).includes('base64') && !('issuedBy' in r.rec) && !('voidReason' in r.rec) && !('token' in r.rec), r.rec);
cek('nama penanda tangan ikut', r.rec.signers[0].name === 'Hans Deny' && r.rec.signers[1].title === 'Executive Director', r.rec.signers);
r = await rpc(db, 'anon', {}, 'cek_sertifikat', { p_token: 'zzzzzzzzzzzzzzzzzzzzzzzz' });
cek('token tak dikenal: tidak ditemukan', r.found === false, r);
r = await rpc(db, 'anon', {}, 'cek_sertifikat', { p_token: "' or 1=1 --" });
cek('token aneh: tidak ditemukan', r.found === false, r);

console.log('Void');
await harusGagal('alasan terlalu pendek ditolak', () => A('batalkan_sertifikat', { p_token: budi.token, p_alasan: 'no' }), /minimal 5/);
r = await A('batalkan_sertifikat', { p_token: budi.token, p_alasan: 'Nama salah ketik' });
cek('void berhasil & tercatat', r.logs[0].action === 'Voided' && r.logs[0].code === budi.num, r);
await harusGagal('void dua kali ditolak', () => A('batalkan_sertifikat', { p_token: budi.token, p_alasan: 'Nama salah ketik' }), /sudah dibatalkan/);
await harusGagal('void oleh akun tanpa akses ditolak', () => rpc(db, 'authenticated', BIASA, 'batalkan_sertifikat', { p_token: eka.token, p_alasan: 'iseng saja' }), /belum diberi akses/);
r = await rpc(db, 'anon', {}, 'cek_sertifikat', { p_token: budi.token });
cek('halaman QR menunjukkan dibatalkan', r.rec.status === 'voided', r.rec.status);

console.log('Versi TTD');
await A('simpan_ttd_sertifikat', { p_sisi: 'l', p_nama: 'Orang Baru', p_jabatan: 'Principal', p_gambar: '' });
r = await rpc(db, 'anon', {}, 'cek_sertifikat', { p_token: eka.token });
cek('sertifikat lama tetap memakai TTD lama', r.rec.signers[0].name === 'Hans Deny', r.rec.signers);
r = await A('terbitkan_sertifikat', { p_items: [item('Fajar')], p_id_permintaan: idp('req3') });
cek('sertifikat baru memakai TTD baru', r.sigs[r.records[0].sigL].name === 'Orang Baru', r.sigs);

console.log('Penomoran');
await harusGagal('nomor di bawah yang terpakai ditolak', () => A('simpan_setelan_sertifikat', { p_unit: 'CERT', p_mulai: 3 }), /tidak boleh di bawah 0007/);
await harusGagal('kode unit aneh ditolak', () => A('simpan_setelan_sertifikat', { p_unit: 'c!', p_mulai: 50 }), /Kode unit/);
r = await A('simpan_setelan_sertifikat', { p_unit: 'sert', p_mulai: 50 });
cek('setelan tersimpan (unit jadi huruf besar)', r.settings.unit === 'SERT' && r.settings.start === 50 && r.settings.startYear === tahun, r);
r = await A('terbitkan_sertifikat', { p_items: [item('Gita')], p_id_permintaan: idp('req4') });
cek('nomor berikutnya 0050/SERT', r.records[0].num === `0050/SERT/UPHC/XI/${tahun}`, r.records[0].num);
r = await A('terbitkan_sertifikat', { p_items: [item('Hadi', { issuedOn: `${tahun + 1}-01-05`, d1: `${tahun + 1}-01-05` })], p_id_permintaan: idp('req5') });
cek('tahun depan mulai lagi dari 0001', r.records[0].num === `0001/SERT/UPHC/I/${tahun + 1}`, r.records[0].num);

console.log('Kalimat & log');
r = await A('simpan_frasa_sertifikat', { p_frasa: { v: 3, lead: [{ t: 'For Winning', brk: 1 }], conn: ['At'] }, p_detail: 'Added phrase' });
cek('kalimat tersimpan', r.logs[0].action === 'Wording Updated', r);
await harusGagal('daftar kosong ditolak', () => A('simpan_frasa_sertifikat', { p_frasa: { lead: [], conn: ['at'] }, p_detail: '' }), /1–40/);
r = await A('catat_unduh_sertifikat', { p_nomor: '0050/SERT', p_detail: 'Gita (digital copy)' });
cek('log unduh kembali sebagai entry', r.entry.action === 'Downloaded' && r.entry.who === ADMIN.email, r);
r = await A('sertifikat_awal', {});
cek('kalimat jadi huruf kecil', r.phrases.lead[0].t === 'for winning' && r.phrases.lead[0].brk === 1 && r.phrases.conn[0] === 'at', r.phrases);
cek('riwayat lengkap dengan pelaku', r.logs.length >= 10 && r.logs.every((l) => l.who === ADMIN.email), r.logs.length);
cek('registri: 8 sertifikat (2+3+1+1+1)', r.records.length === 8, r.records.length);
cek('sigs berisi semua versi TTD yang dipakai', Object.keys(r.sigs).length === 3, Object.keys(r.sigs));

console.log('Nomor > 9999');
await db.exec(`update sertifikat_setelan set nomor_mulai = 9999, tahun_mulai = ${tahun}`);
r = await A('terbitkan_sertifikat', { p_items: [item('I1'), item('I2')], p_id_permintaan: idp('req6') });
cek('nomor 9999 lalu 10000 (tidak terpotong)', r.records[0].num.startsWith('9999/') && r.records[1].num.startsWith('10000/'), r.records.map((x) => x.num));

console.log(`\n${lulus} lulus, ${gagal} gagal`);
process.exit(gagal ? 1 : 0);
