import { CONFIG } from './config.js';

const urut = (a) => [...a].map(String).sort();

/**
 * Nilai jawaban siswa terhadap kunci.
 *   pg / pg_kompleks : jawaban = "A" atau ["A","C"], kunci = ["A","C"]
 *   kategori         : jawaban = {"1":true,"2":false}, kunci = {"1":true,"2":false}
 * pg_kompleks & kategori dinilai benar hanya jika SEMUA bagian tepat (sesuai format TKA).
 */
export function nilaiJawaban(soal, jawaban) {
  const { bentuk, kunci } = soal;
  if (bentuk === 'kategori') {
    if (!jawaban || typeof jawaban !== 'object' || Array.isArray(jawaban)) return false;
    const keys = Object.keys(kunci);
    return keys.length > 0 && keys.every((k) => Boolean(jawaban[k]) === Boolean(kunci[k]) && k in jawaban);
  }
  const j = Array.isArray(jawaban) ? jawaban : jawaban == null || jawaban === '' ? [] : [jawaban];
  const k = Array.isArray(kunci) ? kunci : [kunci];
  if (bentuk === 'pg' && j.length !== 1) return false;
  const a = urut(j), b = urut(k);
  return a.length === b.length && a.every((x, i) => x === b[i]);
}

export function bonusStreak(streak) {
  const hariBonus = Math.max(0, (streak || 1) - 1);
  return Math.min(hariBonus * CONFIG.BONUS_STREAK_PER_HARI, CONFIG.BONUS_STREAK_MAKS);
}

/** Poin kotor untuk satu jawaban benar (sebelum aturan anti-farming) */
export function poinDasar({ kesulitan, mode, streak }) {
  const bk = CONFIG.BOBOT_KESULITAN[kesulitan] ?? 1;
  const bm = CONFIG.BOBOT_MODE[mode] ?? 1;
  return Math.round(bk * bm * (1 + bonusStreak(streak)) * 100) / 100;
}

/**
 * Terapkan aturan fair play. Mengembalikan { poin, catatan }.
 * ctx: { benar, durasiDetik, sudahPernahDapatPoin, poinHariIni }
 */
export function hitungPoin(soal, mode, streak, ctx) {
  if (!ctx.benar) return { poin: 0, catatan: 'salah' };
  if (ctx.durasiDetik != null && ctx.durasiDetik < CONFIG.MIN_DETIK_JAWAB) return { poin: 0, catatan: 'terlalu_cepat' };
  if (ctx.sudahPernahDapatPoin) return { poin: 0, catatan: 'sudah_pernah' };
  const sisa = CONFIG.POIN_BATAS_HARIAN_PER_MAPEL - (ctx.poinHariIni || 0);
  if (sisa <= 0) return { poin: 0, catatan: 'batas_harian' };
  const p = poinDasar({ kesulitan: soal.kesulitan, mode, streak });
  return p > sisa ? { poin: Math.round(sisa * 100) / 100, catatan: 'batas_harian' } : { poin: p, catatan: null };
}

/** Skor tryout 0–100 */
export function skorTryout(jumlahBenar, totalSoal) {
  return totalSoal ? Math.round((jumlahBenar / totalSoal) * 10000) / 100 : 0;
}

export const PESAN_CATATAN = {
  salah: 'Jawaban belum tepat.',
  terlalu_cepat: 'Dijawab terlalu cepat, jadi tidak mendapat poin.',
  sudah_pernah: 'Soal ini sudah pernah memberimu poin di periode ini.',
  batas_harian: 'Batas poin harian untuk mapel ini sudah tercapai. Latihan tetap tercatat!',
};
