// Handler endpoint admin: /api/tka-admin/<action>
import { db } from './supabase.js';
import { generateDrafSoal } from './ai.js';
import { bad, notFound, cek, wajib, hariIni } from './util.js';

const BENTUK = ['pg', 'pg_kompleks', 'kategori'];
const KESULITAN = ['mudah', 'sedang', 'sulit'];

function validasiSoal(s) {
  wajib(s, ['mapel_id', 'topik', 'pertanyaan', 'opsi', 'kunci']);
  if (s.bentuk && !BENTUK.includes(s.bentuk)) throw bad('Bentuk soal tidak valid');
  if (s.kesulitan && !KESULITAN.includes(s.kesulitan)) throw bad('Kesulitan tidak valid');
  if (!Array.isArray(s.opsi) || s.opsi.length < 2) throw bad('Opsi minimal 2');
  const ids = s.opsi.map((o) => String(o.id));
  if ((s.bentuk || 'pg') === 'kategori') {
    if (typeof s.kunci !== 'object' || Array.isArray(s.kunci)) throw bad('Kunci kategori harus objek {"1":true,...}');
    if (!ids.every((id) => id in s.kunci)) throw bad('Setiap pernyataan harus punya kunci benar/salah');
  } else {
    if (!Array.isArray(s.kunci) || !s.kunci.length) throw bad('Kunci harus array, mis. ["C"]');
    if (!s.kunci.every((k) => ids.includes(String(k)))) throw bad('Kunci tidak ada di daftar opsi');
    if ((s.bentuk || 'pg') === 'pg' && s.kunci.length !== 1) throw bad('Pilihan ganda biasa hanya 1 kunci');
  }
}

const KOLOM_SOAL = ['mapel_id', 'topik', 'subtopik', 'kesulitan', 'bentuk', 'stimulus', 'pertanyaan', 'opsi', 'kunci', 'pembahasan', 'sumber', 'status', 'soal_harian'];
const pilih = (o, keys) => Object.fromEntries(keys.filter((k) => k in o).map((k) => [k, o[k]]));

// GET soal?status=&mapel_id=&q=&page=
async function daftarSoal({ query }) {
  const page = Math.max(1, Number(query.page) || 1), per = 25;
  let q = db().from('tka_soal').select('*, mapel:tka_mapel(nama)', { count: 'exact' }).order('created_at', { ascending: false }).range((page - 1) * per, page * per - 1);
  if (query.id) q = q.eq('id', query.id);
  if (query.status) q = q.eq('status', query.status);
  if (query.mapel_id) q = q.eq('mapel_id', Number(query.mapel_id));
  if (query.q) q = q.ilike('pertanyaan', `%${query.q}%`);
  const { data, count, error } = await q;
  if (error) throw error;
  return { soal: data, total: count, page, per };
}

// POST soal { ...soal }  |  POST soal { soal: [ ... ] } (impor massal)
async function buatSoal({ user, body }) {
  const list = Array.isArray(body.soal) ? body.soal : [body];
  list.forEach(validasiSoal);
  const rows = list.map((s) => ({ ...pilih(s, KOLOM_SOAL), dibuat_oleh: user.user_id, sumber: s.sumber || 'admin', status: s.status || 'draf' }));
  const data = cek(await db().from('tka_soal').insert(rows).select('id'), 'Gagal menyimpan soal');
  return { ok: true, jumlah: data.length, ids: data.map((d) => d.id) };
}

// PUT soal { id, ...perubahan }
async function ubahSoal({ body }) {
  wajib(body, ['id']);
  const lama = cek(await db().from('tka_soal').select('*').eq('id', body.id).maybeSingle());
  if (!lama) throw notFound('Soal tidak ditemukan');
  const baru = { ...lama, ...pilih(body, KOLOM_SOAL) };
  validasiSoal(baru);
  const upd = { ...pilih(body, KOLOM_SOAL), updated_at: new Date().toISOString() };
  if (body.status === 'valid' && lama.status !== 'valid') upd.divalidasi_at = new Date().toISOString();
  cek(await db().from('tka_soal').update(upd).eq('id', body.id), 'Gagal mengubah soal');
  // Kunci/pembahasan berubah → hapus cache pembahasan AI
  if ('kunci' in body || 'pembahasan' in body || 'opsi' in body) await db().from('tka_pembahasan_cache').delete().eq('soal_id', body.id);
  return { ok: true };
}

// POST validasi { ids: [...], status: 'valid'|'arsip'|'draf' }
async function validasi({ body }) {
  wajib(body, ['ids', 'status']);
  if (!['valid', 'arsip', 'draf'].includes(body.status)) throw bad('Status tidak valid');
  const upd = { status: body.status, updated_at: new Date().toISOString() };
  if (body.status === 'valid') upd.divalidasi_at = new Date().toISOString();
  cek(await db().from('tka_soal').update(upd).in('id', body.ids));
  return { ok: true };
}

// POST generate { mapel_id, topik, kesulitan, bentuk, jumlah, catatan? } → draf soal AI
async function generate({ user, body }) {
  wajib(body, ['mapel_id', 'topik']);
  const mapel = cek(await db().from('tka_mapel').select('*').eq('id', Number(body.mapel_id)).single());
  const bentuk = BENTUK.includes(body.bentuk) ? body.bentuk : 'pg';
  const kesulitan = KESULITAN.includes(body.kesulitan) ? body.kesulitan : 'sedang';
  const jumlah = Math.min(Math.max(Number(body.jumlah) || 5, 1), 10);
  const hasil = await generateDrafSoal({ userId: user.user_id, mapel, topik: body.topik, kesulitan, bentuk, jumlah, catatan: body.catatan });

  const rows = [], gagal = [];
  for (const h of hasil) {
    const s = { mapel_id: mapel.id, topik: body.topik, subtopik: h.subtopik ?? null, kesulitan, bentuk, stimulus: h.stimulus ?? null, pertanyaan: h.pertanyaan, opsi: h.opsi, kunci: h.kunci, pembahasan: h.pembahasan ?? null, sumber: 'ai', status: 'draf', dibuat_oleh: user.user_id };
    try { validasiSoal(s); rows.push(s); } catch (e) { gagal.push({ pertanyaan: h.pertanyaan, error: e.message }); }
  }
  const data = rows.length ? cek(await db().from('tka_soal').insert(rows).select('id')) : [];
  return { ok: true, dibuat: data.length, gagal, pesan: 'Draf tersimpan dengan status "draf". Periksa & validasi sebelum tayang.' };
}

// GET/PUT popup
async function lihatPopup() {
  return cek(await db().from('tka_popup_pengaturan').select('*').eq('id', 1).single());
}
async function ubahPopup({ body }) {
  const kolom = ['aktif', 'judul', 'pesan', 'target_angkatan', 'tanggal_mulai', 'tanggal_selesai', 'tanggal_tka', 'mapel_harian_id'];
  const upd = { ...pilih(body, kolom), updated_at: new Date().toISOString() };
  if (upd.pesan && (!Array.isArray(upd.pesan) || !upd.pesan.length)) throw bad('Pesan harus array teks, minimal 1');
  cek(await db().from('tka_popup_pengaturan').update(upd).eq('id', 1), 'Gagal menyimpan pengaturan');
  return { ok: true };
}

// GET/PUT laporan
async function daftarLaporan({ query }) {
  let q = db().from('tka_laporan_soal').select('*, soal:tka_soal(id,pertanyaan,topik), pengguna:tka_pengguna(nama,kelas)').order('created_at', { ascending: false }).limit(100);
  if (query.status) q = q.eq('status', query.status);
  return { laporan: cek(await q) };
}
async function ubahLaporan({ body }) {
  wajib(body, ['id', 'status']);
  cek(await db().from('tka_laporan_soal').update({ status: body.status, catatan_admin: body.catatan_admin ?? null }).eq('id', body.id));
  return { ok: true };
}

// GET/POST tryout
async function daftarTryoutAdmin() {
  return { tryout: cek(await db().from('tka_tryout').select('*, mapel:tka_mapel(nama)').order('dibuka_at', { ascending: false })) };
}
async function buatTryout({ body }) {
  wajib(body, ['mapel_id', 'judul', 'durasi_menit', 'dibuka_at', 'ditutup_at', 'soal_ids']);
  if (!Array.isArray(body.soal_ids) || !body.soal_ids.length) throw bad('Pilih soal untuk tryout');
  const to = cek(await db().from('tka_tryout').insert(pilih(body, ['mapel_id', 'judul', 'durasi_menit', 'dibuka_at', 'ditutup_at'])).select('id').single());
  cek(await db().from('tka_tryout_soal').insert(body.soal_ids.map((soal_id, i) => ({ tryout_id: to.id, soal_id, urutan: i + 1 }))));
  return { ok: true, id: to.id };
}

// GET/POST periode
async function daftarPeriode() {
  return { periode: cek(await db().from('tka_periode').select('*').order('mulai', { ascending: false })) };
}
async function buatPeriode({ body }) {
  wajib(body, ['nama', 'mulai', 'selesai']);
  if (body.aktif) cek(await db().from('tka_periode').update({ aktif: false }).eq('aktif', true));
  cek(await db().from('tka_periode').insert(pilih(body, ['nama', 'mulai', 'selesai', 'aktif'])));
  return { ok: true };
}

// GET dashboard
async function dashboard() {
  const t = hariIni();
  const [siswa, soalValid, soalDraf, laporanBaru, rekap, popup, ai] = await Promise.all([
    db().from('tka_pengguna').select('user_id', { count: 'exact', head: true }),
    db().from('tka_soal').select('id', { count: 'exact', head: true }).eq('status', 'valid'),
    db().from('tka_soal').select('id', { count: 'exact', head: true }).eq('status', 'draf'),
    db().from('tka_laporan_soal').select('id', { count: 'exact', head: true }).eq('status', 'baru'),
    db().from('tka_v_rekap_topik').select('*').order('persen_benar', { ascending: true }).limit(20),
    db().from('tka_v_popup_harian').select('*').order('tanggal', { ascending: false }).limit(14),
    db().from('tka_ai_log').select('token_in,token_out').gte('created_at', new Date(`${t}T00:00:00+07:00`).toISOString()),
  ]);
  const aktif7 = cek(await db().from('tka_jawaban').select('user_id').gte('dijawab_at', new Date(Date.now() - 7 * 86400000).toISOString()).limit(10000));
  return {
    ringkasan: {
      siswa: siswa.count, siswa_aktif_7_hari: new Set(aktif7.map((r) => r.user_id)).size,
      soal_valid: soalValid.count, soal_draf: soalDraf.count, laporan_baru: laporanBaru.count,
      ai_hari_ini: { panggilan: ai.data?.length ?? 0, token_in: (ai.data || []).reduce((a, r) => a + (r.token_in || 0), 0), token_out: (ai.data || []).reduce((a, r) => a + (r.token_out || 0), 0) },
    },
    topik_terlemah: rekap.data || [],
    popup_14_hari: popup.data || [],
  };
}

// GET mapel — daftar mapel untuk isi <select> di panel admin
async function daftarMapelAdmin() {
  return { mapel: cek(await db().from('tka_mapel').select('id,kode,nama,kelompok').order('urutan')) };
}

export const adminRoutes = {
  'GET dashboard': dashboard,
  'GET mapel': daftarMapelAdmin,
  'GET soal': daftarSoal,
  'POST soal': buatSoal,
  'PUT soal': ubahSoal,
  'POST validasi': validasi,
  'POST generate': generate,
  'GET popup': lihatPopup,
  'PUT popup': ubahPopup,
  'GET laporan': daftarLaporan,
  'PUT laporan': ubahLaporan,
  'GET tryout': daftarTryoutAdmin,
  'POST tryout': buatTryout,
  'GET periode': daftarPeriode,
  'POST periode': buatPeriode,
};
