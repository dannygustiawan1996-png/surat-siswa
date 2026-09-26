// Handler endpoint siswa: /api/tka/<action>
import { db } from './supabase.js';
import { CONFIG } from './config.js';
import { nilaiJawaban, hitungPoin, skorTryout, PESAN_CATATAN } from './scoring.js';
import { jelaskanJawaban, chatTutor } from './ai.js';
import { bad, forbidden, notFound, cek, wajib, hariIni, selisihHari, acak, acakUrut, soalPublik, isiTemplate } from './util.js';

// ---------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------
async function periodeAktif() {
  const t = hariIni();
  return cek(
    await db().from('tka_periode').select('*').eq('aktif', true).lte('mulai', t).gte('selesai', t).maybeSingle()
  );
}

async function mapelSiswa(userId) {
  const wajibM = cek(await db().from('tka_mapel').select('id,kode,nama,kelompok').eq('kelompok', 'wajib').eq('aktif', true).order('urutan'));
  const pil = cek(await db().from('tka_pilihan_mapel').select('mapel:tka_mapel(id,kode,nama,kelompok)').eq('user_id', userId));
  return [...wajibM, ...pil.map((p) => p.mapel).filter(Boolean)];
}

async function streakSiswa(userId) {
  const r = cek(await db().from('tka_streak').select('*').eq('user_id', userId).maybeSingle());
  if (!r) return 0;
  // Streak dianggap putus jika terakhir latihan sebelum kemarin
  return r.terakhir_latihan && selisihHari(r.terakhir_latihan, hariIni()) <= 1 ? r.streak_hari : 0;
}

async function peringkatSiswa(userId, mapelId) {
  const rows = cek(await db().rpc('tka_leaderboard', { p_mapel_id: mapelId, p_rentang: 'minggu', p_limit: 10, p_user: userId }));
  return rows.find((r) => r.saya)?.peringkat ?? null;
}

async function ambilSesi(sesiId, userId) {
  const s = cek(await db().from('tka_sesi').select('*').eq('id', sesiId).maybeSingle());
  if (!s) throw notFound('Sesi tidak ditemukan');
  if (s.user_id !== userId) throw forbidden();
  return s;
}

async function sesiTryoutBerjalan(userId) {
  const rows = cek(await db().from('tka_sesi').select('id,soal_ids').eq('user_id', userId).eq('mode', 'tryout').is('selesai_at', null));
  return rows;
}

// ---------------------------------------------------------------------
// GET profil — data awal halaman latihan
// ---------------------------------------------------------------------
async function profil({ user }) {
  const mapel = cek(await db().from('tka_mapel').select('id,kode,nama,kelompok,jumlah_soal_tka,durasi_menit').eq('aktif', true).order('urutan'));
  const pilihan = cek(await db().from('tka_pilihan_mapel').select('mapel_id').eq('user_id', user.user_id)).map((r) => r.mapel_id);
  const lencana = cek(await db().from('tka_lencana_siswa').select('kode, lencana:tka_lencana(nama)').eq('user_id', user.user_id));
  return {
    pengguna: { nama: user.nama, kelas: user.kelas, angkatan: user.angkatan, nama_tampilan: user.nama_tampilan, anonim: user.anonim },
    streak: await streakSiswa(user.user_id),
    mapel,
    pilihan_mapel: pilihan,
    lencana,
  };
}

// PUT pilihan-mapel { mapel_ids: [id, id] }
async function simpanPilihanMapel({ user, body }) {
  const ids = [...new Set((body.mapel_ids || []).map(Number))];
  if (ids.length > 2) throw bad('Maksimal 2 mapel pilihan');
  cek(await db().from('tka_pilihan_mapel').delete().eq('user_id', user.user_id));
  if (ids.length) cek(await db().from('tka_pilihan_mapel').insert(ids.map((mapel_id) => ({ user_id: user.user_id, mapel_id }))), 'Gagal menyimpan');
  return { ok: true, pilihan_mapel: ids };
}

// PUT tampilan { nama_tampilan, anonim }
async function simpanTampilan({ user, body }) {
  const nama_tampilan = body.nama_tampilan ? String(body.nama_tampilan).slice(0, 40) : null;
  cek(await db().from('tka_pengguna').update({ nama_tampilan, anonim: Boolean(body.anonim) }).eq('user_id', user.user_id));
  return { ok: true };
}

// ---------------------------------------------------------------------
// GET popup — dipanggil setiap kali siswa membuka web surat
// ---------------------------------------------------------------------
async function popup({ user }) {
  const tidak = (alasan) => ({ tampil: false, alasan });

  const set = cek(await db().from('tka_popup_pengaturan').select('*').eq('id', 1).single());
  const t = hariIni();
  if (!set.aktif) return tidak('nonaktif');
  if (set.tanggal_mulai && t < set.tanggal_mulai) return tidak('belum_mulai');
  if (set.tanggal_selesai && t > set.tanggal_selesai) return tidak('sudah_selesai');
  if (set.target_angkatan?.length && !set.target_angkatan.includes(user.angkatan)) return tidak('bukan_target');

  // Maksimal 1 kali per hari (bisa dimatikan sementara lewat CONFIG.POPUP_SEKALI_SEHARI untuk uji coba)
  if (CONFIG.POPUP_SEKALI_SEHARI) {
    const log = cek(await db().from('tka_popup_log').select('aksi').eq('user_id', user.user_id).eq('tanggal', t));
    if (log.length) return tidak('sudah_tampil_hari_ini');
  }

  // Pilih mapel & soal harian yang belum pernah dijawab benar
  const daftarMapel = await mapelSiswa(user.user_id);
  const mapel = set.mapel_harian_id ? daftarMapel.find((m) => m.id === set.mapel_harian_id) || daftarMapel[0] : acak(daftarMapel);
  if (!mapel) return tidak('tidak_ada_mapel');

  const sudahBenar = cek(await db().from('tka_jawaban').select('soal_id').eq('user_id', user.user_id).eq('mapel_id', mapel.id).eq('benar', true)).map((r) => r.soal_id);
  let q = db().from('tka_soal').select('id').eq('mapel_id', mapel.id).eq('status', 'valid').eq('soal_harian', true).limit(300);
  const kandidat = cek(await q).map((r) => r.id).filter((id) => !sudahBenar.includes(id));
  if (!kandidat.length) return tidak('soal_harian_habis');
  const soal = cek(await db().from('tka_soal').select('*').eq('id', acak(kandidat)).single());

  const sesi = cek(await db().from('tka_sesi').insert({ user_id: user.user_id, mapel_id: mapel.id, mode: 'popup', soal_ids: [soal.id] }).select('id').single());
  await db().from('tka_popup_log').upsert(
    { user_id: user.user_id, tanggal: t, aksi: 'tampil', soal_id: soal.id },
    { onConflict: 'user_id,tanggal,aksi', ignoreDuplicates: true }
  );

  const streak = await streakSiswa(user.user_id);
  const peringkat = await peringkatSiswa(user.user_id, mapel.id);
  const hari = set.tanggal_tka ? Math.max(0, selisihHari(t, set.tanggal_tka)) : null;
  const data = { nama: (user.nama_tampilan || user.nama).split(' ')[0], hari, streak, peringkat, mapel: mapel.nama };

  // Pilih template yang semua placeholder-nya bisa diisi
  const cocok = set.pesan.filter((p) => [...p.matchAll(/\{(\w+)\}/g)].every(([, k]) => data[k] !== null && data[k] !== undefined && !(k === 'streak' && !data[k])));
  const pesan = isiTemplate(acak(cocok.length ? cocok : ['Halo {nama}! Yuk jawab 1 soal TKA hari ini.']), data);

  return {
    tampil: true,
    judul: set.judul,
    pesan,
    hari_menuju_tka: hari,
    streak,
    peringkat,
    mapel: { id: mapel.id, nama: mapel.nama },
    sesi_id: sesi.id,
    soal: soalPublik(soal),
  };
}

// POST popup-aksi { aksi: 'mulai_latihan' | 'ditutup' }
async function popupAksi({ user, body }) {
  if (!['mulai_latihan', 'ditutup'].includes(body.aksi)) throw bad('Aksi tidak dikenal');
  await db().from('tka_popup_log').upsert(
    { user_id: user.user_id, tanggal: hariIni(), aksi: body.aksi },
    { onConflict: 'user_id,tanggal,aksi', ignoreDuplicates: true }
  );
  return { ok: true };
}

// ---------------------------------------------------------------------
// POST mulai — mulai sesi latihan / tryout
//   latihan: { mode:'latihan', mapel_id, jumlah?, topik?, kesulitan? }
//   tryout : { mode:'tryout', tryout_id }
// ---------------------------------------------------------------------
async function mulai({ user, body }) {
  const mode = body.mode || 'latihan';

  if (mode === 'tryout') {
    wajib(body, ['tryout_id']);
    const to = cek(await db().from('tka_tryout').select('*').eq('id', body.tryout_id).maybeSingle());
    const now = new Date();
    if (!to || !to.aktif || now < new Date(to.dibuka_at) || now > new Date(to.ditutup_at)) throw bad('Tryout tidak tersedia saat ini');
    const lama = cek(await db().from('tka_sesi').select('id,selesai_at').eq('user_id', user.user_id).eq('tryout_id', to.id).eq('mode', 'tryout').maybeSingle());
    if (lama?.selesai_at) throw bad('Kamu sudah menyelesaikan tryout ini. Coba mode latihan untuk mengulang soal.');
    const rel = cek(await db().from('tka_tryout_soal').select('urutan, soal:tka_soal(*)').eq('tryout_id', to.id).order('urutan'));
    const soal = rel.map((r) => r.soal);
    let sesi = lama;
    if (!sesi) {
      sesi = cek(await db().from('tka_sesi').insert({ user_id: user.user_id, mapel_id: to.mapel_id, mode, tryout_id: to.id, soal_ids: soal.map((s) => s.id) }).select('*').single());
    } else {
      sesi = cek(await db().from('tka_sesi').select('*').eq('id', sesi.id).single());
    }
    const dijawab = cek(await db().from('tka_jawaban').select('soal_id').eq('sesi_id', sesi.id)).map((r) => r.soal_id);
    const batas = new Date(new Date(sesi.mulai_at).getTime() + to.durasi_menit * 60000);
    return { sesi_id: sesi.id, mode, judul: to.judul, berakhir_at: batas.toISOString(), soal: soal.map(soalPublik), sudah_dijawab: dijawab };
  }

  wajib(body, ['mapel_id']);
  const mapelId = Number(body.mapel_id);
  const jumlah = Math.min(Number(body.jumlah) || CONFIG.JUMLAH_SOAL_DEFAULT, CONFIG.JUMLAH_SOAL_MAKS);

  let q = db().from('tka_soal').select('id').eq('mapel_id', mapelId).eq('status', 'valid').limit(500);
  if (body.topik) q = q.eq('topik', body.topik);
  if (body.kesulitan) q = q.eq('kesulitan', body.kesulitan);
  const semua = cek(await q).map((r) => r.id);
  if (!semua.length) throw bad('Belum ada soal untuk pilihan ini. Coba topik atau mapel lain.');

  // Prioritaskan soal yang belum pernah dijawab benar
  const benar = new Set(cek(await db().from('tka_jawaban').select('soal_id').eq('user_id', user.user_id).eq('mapel_id', mapelId).eq('benar', true)).map((r) => r.soal_id));
  const baru = acakUrut(semua.filter((id) => !benar.has(id)));
  const ulang = acakUrut(semua.filter((id) => benar.has(id)));
  const ids = [...baru, ...ulang].slice(0, jumlah);

  const soal = cek(await db().from('tka_soal').select('*').in('id', ids));
  const urut = ids.map((id) => soal.find((s) => s.id === id)).filter(Boolean);
  const sesi = cek(await db().from('tka_sesi').insert({ user_id: user.user_id, mapel_id: mapelId, mode: 'latihan', soal_ids: ids }).select('id').single());
  return { sesi_id: sesi.id, mode: 'latihan', soal: urut.map(soalPublik) };
}

// GET topik?mapel_id= — daftar topik yang punya soal valid
async function topik({ query }) {
  wajib(query, ['mapel_id']);
  const rows = cek(await db().from('tka_soal').select('topik').eq('mapel_id', Number(query.mapel_id)).eq('status', 'valid').limit(2000));
  return { topik: [...new Set(rows.map((r) => r.topik))].sort() };
}

// GET tryout — tryout yang sedang dibuka
async function daftarTryout({ user }) {
  const now = new Date().toISOString();
  const rows = cek(await db().from('tka_tryout').select('id,judul,durasi_menit,dibuka_at,ditutup_at,mapel:tka_mapel(id,nama)').eq('aktif', true).lte('dibuka_at', now).gte('ditutup_at', now).order('dibuka_at'));
  const sesi = cek(await db().from('tka_sesi').select('tryout_id,selesai_at,skor').eq('user_id', user.user_id).eq('mode', 'tryout'));
  return { tryout: rows.map((t) => ({ ...t, sesi: sesi.find((s) => s.tryout_id === t.id) || null })) };
}

// ---------------------------------------------------------------------
// POST jawab { sesi_id, soal_id, jawaban, durasi_detik }
// ---------------------------------------------------------------------
async function jawab({ user, body }) {
  wajib(body, ['sesi_id', 'soal_id']);
  const sesi = await ambilSesi(body.sesi_id, user.user_id);
  if (sesi.selesai_at) throw bad('Sesi sudah selesai');
  if (!sesi.soal_ids.includes(body.soal_id)) throw bad('Soal bukan bagian dari sesi ini');

  if (sesi.mode === 'tryout') {
    const to = cek(await db().from('tka_tryout').select('durasi_menit').eq('id', sesi.tryout_id).single());
    const batas = new Date(sesi.mulai_at).getTime() + to.durasi_menit * 60000 + 30000; // toleransi 30 dtk
    if (Date.now() > batas) throw bad('Waktu tryout sudah habis');
  }

  const soal = cek(await db().from('tka_soal').select('*').eq('id', body.soal_id).single());
  const benar = nilaiJawaban(soal, body.jawaban);
  const durasi = body.durasi_detik == null ? null : Math.max(0, Math.round(Number(body.durasi_detik)));
  const periode = await periodeAktif();

  // Streak dihitung setiap kali siswa menjawab
  const streak = cek(await db().rpc('tka_update_streak', { p_user: user.user_id }));

  let sudahPernah = false;
  if (periode) {
    const r = cek(await db().from('tka_jawaban').select('id').eq('user_id', user.user_id).eq('soal_id', soal.id).eq('periode_id', periode.id).gt('poin', 0).limit(1));
    sudahPernah = r.length > 0;
  }
  const poinHariIni = Number(cek(await db().rpc('tka_poin_hari_ini', { p_user: user.user_id, p_mapel: soal.mapel_id })));
  let { poin, catatan } = periode
    ? hitungPoin(soal, sesi.mode, streak, { benar, durasiDetik: durasi, sudahPernahDapatPoin: sudahPernah, poinHariIni })
    : { poin: 0, catatan: benar ? null : 'salah' };

  const baris = {
    sesi_id: sesi.id, user_id: user.user_id, soal_id: soal.id, mapel_id: soal.mapel_id,
    periode_id: periode?.id ?? null, jawaban: body.jawaban ?? null, benar, durasi_detik: durasi, poin, catatan_poin: catatan,
  };
  let ins = await db().from('tka_jawaban').insert(baris).select('id').single();
  if (ins.error?.code === '23505') {
    // Sudah dijawab di sesi ini, atau balapan dengan uq_tka_poin_sekali
    if (ins.error.message.includes('sesi_id')) throw bad('Soal ini sudah kamu jawab di sesi ini');
    poin = 0; catatan = 'sudah_pernah';
    ins = await db().from('tka_jawaban').insert({ ...baris, poin, catatan_poin: catatan }).select('id').single();
  }
  cek(ins, 'Gagal menyimpan jawaban');

  if (poin > 0) {
    cek(await db().from('tka_sesi').update({ total_poin: Number(sesi.total_poin) + poin }).eq('id', sesi.id));
  }
  if (sesi.mode === 'popup') {
    await db().from('tka_popup_log').upsert({ user_id: user.user_id, tanggal: hariIni(), aksi: 'dijawab', soal_id: soal.id }, { onConflict: 'user_id,tanggal,aksi', ignoreDuplicates: true });
    cek(await db().from('tka_sesi').update({ selesai_at: new Date().toISOString(), skor: benar ? 100 : 0 }).eq('id', sesi.id));
  }

  // Tryout: hasil & kunci baru dibuka setelah sesi selesai
  if (sesi.mode === 'tryout') return { tersimpan: true };

  return {
    benar,
    kunci: soal.kunci,
    pembahasan: soal.pembahasan,
    poin,
    catatan: catatan && catatan !== 'salah' ? PESAN_CATATAN[catatan] : null,
    streak,
  };
}

// POST selesai { sesi_id }
async function selesai({ user, body }) {
  wajib(body, ['sesi_id']);
  const sesi = await ambilSesi(body.sesi_id, user.user_id);
  const jawaban = cek(await db().from('tka_jawaban').select('soal_id,jawaban,benar,poin').eq('sesi_id', sesi.id));
  const jBenar = jawaban.filter((j) => j.benar).length;
  const total = sesi.soal_ids.length;
  const skor = skorTryout(jBenar, total);
  const totalPoin = jawaban.reduce((a, j) => a + Number(j.poin), 0);

  if (!sesi.selesai_at) {
    cek(await db().from('tka_sesi').update({ selesai_at: new Date().toISOString(), skor, total_poin: totalPoin }).eq('id', sesi.id));
  }

  const hasil = { sesi_id: sesi.id, mode: sesi.mode, benar: jBenar, total, dijawab: jawaban.length, skor, total_poin: totalPoin };

  if (sesi.mode === 'tryout') {
    const soal = cek(await db().from('tka_soal').select('id,pertanyaan,kunci,pembahasan,topik').in('id', sesi.soal_ids));
    hasil.rincian = sesi.soal_ids.map((id) => {
      const s = soal.find((x) => x.id === id);
      const j = jawaban.find((x) => x.soal_id === id);
      return { soal_id: id, topik: s?.topik, jawaban: j?.jawaban ?? null, benar: j?.benar ?? false, kunci: s?.kunci, pembahasan: s?.pembahasan };
    });
    if (skor >= 90) {
      await db().from('tka_lencana_siswa').upsert({ user_id: user.user_id, kode: 'TRYOUT_90', periode_id: (await periodeAktif())?.id ?? null }, { ignoreDuplicates: true });
    }
  }

  // Topik terlemah di mapel ini (untuk rekomendasi)
  const riwayat = cek(await db().from('tka_jawaban').select('benar, soal:tka_soal(topik)').eq('user_id', user.user_id).eq('mapel_id', sesi.mapel_id).order('dijawab_at', { ascending: false }).limit(200));
  const perTopik = {};
  for (const r of riwayat) {
    const tp = r.soal?.topik; if (!tp) continue;
    perTopik[tp] ??= { topik: tp, dijawab: 0, benar: 0 };
    perTopik[tp].dijawab++; if (r.benar) perTopik[tp].benar++;
  }
  hasil.rekomendasi = Object.values(perTopik)
    .filter((t) => t.dijawab >= 3)
    .map((t) => ({ ...t, persen: Math.round((100 * t.benar) / t.dijawab) }))
    .sort((a, b) => a.persen - b.persen)
    .slice(0, 3);
  return hasil;
}

// ---------------------------------------------------------------------
// POST pembahasan { sesi_id, soal_id } — penjelasan AI personal
// ---------------------------------------------------------------------
async function pembahasan({ user, body }) {
  wajib(body, ['sesi_id', 'soal_id']);
  const sesi = await ambilSesi(body.sesi_id, user.user_id);
  if (sesi.mode === 'tryout' && !sesi.selesai_at) throw bad('Pembahasan tryout dibuka setelah tryout selesai');
  const j = cek(await db().from('tka_jawaban').select('jawaban,benar').eq('sesi_id', sesi.id).eq('soal_id', body.soal_id).maybeSingle());
  if (!j) throw bad('Jawab soalnya dulu, baru minta pembahasan ya');
  const soal = cek(await db().from('tka_soal').select('*').eq('id', body.soal_id).single());
  const teks = await jelaskanJawaban({ userId: user.user_id, soal, jawabanSiswa: j.jawaban, benar: j.benar });
  return { pembahasan: teks };
}

// POST chat { pesan, riwayat?, soal_id? }
async function chat({ user, body }) {
  wajib(body, ['pesan']);
  let konteksSoal = null;
  if (body.soal_id) {
    const tryout = await sesiTryoutBerjalan(user.user_id);
    if (tryout.some((s) => s.soal_ids.includes(body.soal_id))) throw bad('Soal ini bagian dari tryout yang sedang berjalan, jadi belum bisa dibahas.');
    const soal = cek(await db().from('tka_soal').select('*').eq('id', body.soal_id).maybeSingle());
    if (soal) {
      const pernah = cek(await db().from('tka_jawaban').select('id').eq('user_id', user.user_id).eq('soal_id', soal.id).limit(1));
      konteksSoal = { soal, denganKunci: pernah.length > 0 }; // kunci hanya jika siswa sudah menjawab
    }
  }
  const balasan = await chatTutor({ userId: user.user_id, pesan: body.pesan, riwayat: body.riwayat || [], konteksSoal });
  return { balasan };
}

// ---------------------------------------------------------------------
// GET leaderboard?mapel_id=&rentang=minggu|bulan|periode&kelas=
// ---------------------------------------------------------------------
async function leaderboard({ user, query }) {
  const rentang = ['minggu', 'bulan', 'periode'].includes(query.rentang) ? query.rentang : 'minggu';
  const rows = cek(await db().rpc('tka_leaderboard', {
    p_mapel_id: query.mapel_id ? Number(query.mapel_id) : null,
    p_rentang: rentang,
    p_kelas: query.kelas || null,
    p_angkatan: query.angkatan ? Number(query.angkatan) : user.angkatan ?? null,
    p_limit: Math.min(Number(query.limit) || 10, 50),
    p_user: user.user_id,
  }));
  return {
    rentang,
    peringkat: rows.map(({ user_id, ...r }) => ({ ...r, total_poin: Number(r.total_poin) })),
    saya: rows.find((r) => r.saya) ? { peringkat: rows.find((r) => r.saya).peringkat } : null,
    streak: await streakSiswa(user.user_id),
  };
}

// GET riwayat — 20 sesi terakhir
async function riwayat({ user }) {
  const rows = cek(await db().from('tka_sesi').select('id,mode,mulai_at,selesai_at,skor,total_poin,mapel:tka_mapel(nama)').eq('user_id', user.user_id).order('mulai_at', { ascending: false }).limit(20));
  return { sesi: rows };
}

// POST lapor { soal_id, alasan }
async function lapor({ user, body }) {
  wajib(body, ['soal_id', 'alasan']);
  cek(await db().from('tka_laporan_soal').insert({ soal_id: body.soal_id, user_id: user.user_id, alasan: String(body.alasan).slice(0, 1000) }), 'Gagal mengirim laporan');
  return { ok: true, pesan: 'Terima kasih! Laporanmu akan ditinjau admin.' };
}

export const siswaRoutes = {
  'GET profil': profil,
  'PUT pilihan-mapel': simpanPilihanMapel,
  'PUT tampilan': simpanTampilan,
  'GET popup': popup,
  'POST popup-aksi': popupAksi,
  'GET topik': topik,
  'GET tryout': daftarTryout,
  'POST mulai': mulai,
  'POST jawab': jawab,
  'POST selesai': selesai,
  'POST pembahasan': pembahasan,
  'POST chat': chat,
  'GET leaderboard': leaderboard,
  'GET riwayat': riwayat,
  'POST lapor': lapor,
};
