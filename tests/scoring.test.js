import { test } from 'node:test';
import assert from 'node:assert/strict';
import { nilaiJawaban, poinDasar, hitungPoin, bonusStreak, skorTryout } from '../lib/tka/scoring.js';
import { isiTemplate, selisihHari, soalPublik } from '../lib/tka/util.js';

test('nilai pg', () => {
  const s = { bentuk: 'pg', kunci: ['C'] };
  assert.equal(nilaiJawaban(s, 'C'), true);
  assert.equal(nilaiJawaban(s, ['C']), true);
  assert.equal(nilaiJawaban(s, 'A'), false);
  assert.equal(nilaiJawaban(s, ['C', 'A']), false);
  assert.equal(nilaiJawaban(s, null), false);
});

test('nilai pg kompleks: harus tepat semua', () => {
  const s = { bentuk: 'pg_kompleks', kunci: ['A', 'C'] };
  assert.equal(nilaiJawaban(s, ['C', 'A']), true);
  assert.equal(nilaiJawaban(s, ['A']), false);
  assert.equal(nilaiJawaban(s, ['A', 'B', 'C']), false);
});

test('nilai kategori', () => {
  const s = { bentuk: 'kategori', kunci: { 1: false, 2: true } };
  assert.equal(nilaiJawaban(s, { 1: false, 2: true }), true);
  assert.equal(nilaiJawaban(s, { 1: true, 2: true }), false);
  assert.equal(nilaiJawaban(s, { 2: true }), false);
  assert.equal(nilaiJawaban(s, ['A']), false);
});

test('bonus streak', () => {
  assert.equal(bonusStreak(1), 0);
  assert.equal(bonusStreak(3), 0.2);
  assert.equal(bonusStreak(20), 0.5);
});

test('poin dasar', () => {
  assert.equal(poinDasar({ kesulitan: 'mudah', mode: 'latihan', streak: 1 }), 1);
  assert.equal(poinDasar({ kesulitan: 'sulit', mode: 'tryout', streak: 1 }), 4.5);
  assert.equal(poinDasar({ kesulitan: 'sedang', mode: 'latihan', streak: 6 }), 3);
});

test('aturan fair play', () => {
  const soal = { kesulitan: 'sedang' };
  const base = { benar: true, durasiDetik: 20, sudahPernahDapatPoin: false, poinHariIni: 0 };
  assert.deepEqual(hitungPoin(soal, 'latihan', 1, base), { poin: 2, catatan: null });
  assert.equal(hitungPoin(soal, 'latihan', 1, { ...base, benar: false }).poin, 0);
  assert.equal(hitungPoin(soal, 'latihan', 1, { ...base, durasiDetik: 1 }).catatan, 'terlalu_cepat');
  assert.equal(hitungPoin(soal, 'latihan', 1, { ...base, sudahPernahDapatPoin: true }).catatan, 'sudah_pernah');
  assert.equal(hitungPoin(soal, 'latihan', 1, { ...base, poinHariIni: 60 }).catatan, 'batas_harian');
  assert.deepEqual(hitungPoin(soal, 'latihan', 1, { ...base, poinHariIni: 59 }), { poin: 1, catatan: 'batas_harian' });
});

test('skor tryout', () => {
  assert.equal(skorTryout(18, 25), 72);
  assert.equal(skorTryout(0, 0), 0);
});

test('util', () => {
  assert.equal(isiTemplate('Halo {nama}, {hari} hari', { nama: 'Ani', hari: 30 }), 'Halo Ani, 30 hari');
  assert.equal(selisihHari('2026-09-26', '2026-10-26'), 30);
  const pub = soalPublik({ id: 1, pertanyaan: 'x', kunci: ['A'], pembahasan: 'p', status: 'valid' });
  assert.equal('kunci' in pub, false);
  assert.equal('pembahasan' in pub, false);
});
