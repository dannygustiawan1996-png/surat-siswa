import Anthropic from '@anthropic-ai/sdk';
import { CONFIG } from './config.js';
import { db } from './supabase.js';
import { HttpError, cek, hariIni, md5 } from './util.js';

let _client;
function client() {
  if (!_client) {
    if (!process.env.ANTHROPIC_API_KEY) throw new Error('ANTHROPIC_API_KEY belum diset');
    _client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _client;
}

const SYSTEM_TUTOR = `Kamu adalah "Kak TKA", tutor latihan Tes Kemampuan Akademik (TKA) SMA untuk siswa UPH College.

Aturan:
- Jawab dalam bahasa yang dipakai siswa (Indonesia atau Inggris), ramah, singkat, jelas. Maksimal ±200 kata kecuali diminta lebih.
- Fokus hanya pada materi TKA (Bahasa Indonesia, Matematika, Bahasa Inggris, dan mapel pilihan TKA) serta strategi belajar. Tolak dengan sopan topik di luar itu.
- Jika konteks soal disertai KUNCI, kunci itu sudah divalidasi admin — jangan pernah membantahnya. Jelaskan langkah menuju kunci tersebut.
- Jika konteks soal TIDAK menyertakan kunci, jangan menebak atau memberikan jawaban akhir. Beri petunjuk konsep saja.
- Jangan pernah membantu mengerjakan soal tryout yang sedang berlangsung.
- Untuk matematika, tulis langkah bernomor. Hindari LaTeX; gunakan simbol biasa (×, ÷, ², √).
- Akhiri pembahasan dengan 1 kalimat tips atau konsep kunci yang perlu diingat.`;

async function cekBatasHarian(userId) {
  const mulai = new Date(`${hariIni()}T00:00:00+07:00`).toISOString();
  const { count, error } = await db()
    .from('tka_ai_log')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId)
    .in('jenis', ['pembahasan', 'chat'])
    .gte('created_at', mulai);
  if (error) throw error;
  if (count >= CONFIG.AI_BATAS_HARIAN) {
    throw new HttpError(429, `Batas ${CONFIG.AI_BATAS_HARIAN} pertanyaan AI per hari sudah tercapai. Coba lagi besok ya!`);
  }
}

async function catat(userId, jenis, soalId, usage) {
  await db().from('tka_ai_log').insert({
    user_id: userId, jenis, soal_id: soalId ?? null,
    token_in: usage?.input_tokens ?? null, token_out: usage?.output_tokens ?? null,
  });
}

function teksDari(resp) {
  return resp.content.filter((b) => b.type === 'text').map((b) => b.text).join('\n').trim();
}

export function formatSoal(soal, { denganKunci }) {
  const opsi =
    soal.bentuk === 'kategori'
      ? soal.opsi.map((o) => `(${o.id}) ${o.teks} — Benar/Salah`).join('\n')
      : soal.opsi.map((o) => `${o.id}. ${o.teks}`).join('\n');
  const bentuk = { pg: 'Pilihan ganda (1 jawaban)', pg_kompleks: 'Pilihan ganda kompleks (bisa >1 jawaban)', kategori: 'Benar/Salah per pernyataan' }[soal.bentuk];
  let t = `Bentuk: ${bentuk}\nTopik: ${soal.topik}\n`;
  if (soal.stimulus) t += `Stimulus:\n${soal.stimulus}\n`;
  t += `Pertanyaan:\n${soal.pertanyaan}\nOpsi:\n${opsi}\n`;
  if (denganKunci) {
    t += `KUNCI: ${JSON.stringify(soal.kunci)}\n`;
    if (soal.pembahasan) t += `Pembahasan resmi (acuan): ${soal.pembahasan}\n`;
  }
  return t;
}

/** Pembahasan personal untuk jawaban siswa (dengan cache per soal + jawaban) */
export async function jelaskanJawaban({ userId, soal, jawabanSiswa, benar }) {
  const hash = md5(jawabanSiswa ?? null);
  const cache = cek(
    await db().from('tka_pembahasan_cache').select('teks').eq('soal_id', soal.id).eq('jawaban_hash', hash).maybeSingle()
  );
  if (cache) return cache.teks;

  await cekBatasHarian(userId);
  const resp = await client().messages.create({
    model: CONFIG.AI_MODEL,
    max_tokens: CONFIG.AI_MAX_TOKENS,
    system: SYSTEM_TUTOR,
    messages: [{
      role: 'user',
      content: `${formatSoal(soal, { denganKunci: true })}\nJawaban siswa: ${JSON.stringify(jawabanSiswa)} (${benar ? 'BENAR' : 'SALAH'}).\n` +
        (benar
          ? 'Jelaskan singkat kenapa jawaban ini benar dan konsep yang diuji.'
          : 'Jelaskan letak kekeliruan siswa, lalu langkah menuju jawaban yang benar.'),
    }],
  });
  const teks = teksDari(resp);
  await catat(userId, 'pembahasan', soal.id, resp.usage);
  await db().from('tka_pembahasan_cache').upsert({ soal_id: soal.id, jawaban_hash: hash, teks });
  return teks;
}

/**
 * Chat bebas dengan tutor.
 * riwayat: [{role:'user'|'assistant', content:'...'}] maks 10 pesan terakhir (dari browser).
 * konteksSoal: { soal, denganKunci } opsional.
 */
export async function chatTutor({ userId, pesan, riwayat = [], konteksSoal }) {
  await cekBatasHarian(userId);
  const bersih = riwayat
    .filter((m) => (m.role === 'user' || m.role === 'assistant') && typeof m.content === 'string')
    .slice(-10)
    .map((m) => ({ role: m.role, content: m.content.slice(0, 2000) }));
  // Pesan harus diawali user
  while (bersih.length && bersih[0].role !== 'user') bersih.shift();

  let isi = String(pesan).slice(0, 2000);
  if (konteksSoal?.soal) {
    isi = `[Konteks soal yang sedang dibahas]\n${formatSoal(konteksSoal.soal, { denganKunci: konteksSoal.denganKunci })}\n[Pertanyaan siswa]\n${isi}`;
  }
  const resp = await client().messages.create({
    model: CONFIG.AI_MODEL,
    max_tokens: CONFIG.AI_MAX_TOKENS,
    system: SYSTEM_TUTOR,
    messages: [...bersih, { role: 'user', content: isi }],
  });
  await catat(userId, 'chat', konteksSoal?.soal?.id, resp.usage);
  return teksDari(resp);
}

/** Admin: buat draf soal dari kisi-kisi. Hasil WAJIB divalidasi admin sebelum tayang. */
export async function generateDrafSoal({ userId, mapel, topik, kesulitan, bentuk, jumlah, catatan }) {
  const contoh = {
    pg: '{"opsi":[{"id":"A","teks":"..."},{"id":"B","teks":"..."},{"id":"C","teks":"..."},{"id":"D","teks":"..."},{"id":"E","teks":"..."}],"kunci":["C"]}',
    pg_kompleks: '{"opsi":[{"id":"A","teks":"..."},{"id":"B","teks":"..."},{"id":"C","teks":"..."},{"id":"D","teks":"..."}],"kunci":["A","C"]}',
    kategori: '{"opsi":[{"id":"1","teks":"pernyataan"},{"id":"2","teks":"pernyataan"},{"id":"3","teks":"pernyataan"}],"kunci":{"1":true,"2":false,"3":true}}',
  }[bentuk];

  const resp = await client().messages.create({
    model: CONFIG.AI_MODEL,
    max_tokens: 4000,
    system: 'Kamu penyusun soal TKA SMA Indonesia yang teliti. Soal harus HOTS (penalaran, bukan hafalan), sesuai kisi-kisi TKA, satu kunci yang pasti benar, bahasa baku. Keluarkan HANYA JSON valid tanpa teks lain.',
    messages: [{
      role: 'user',
      content: `Buat ${jumlah} soal TKA.
Mapel: ${mapel.nama}
Topik: ${topik}
Kesulitan: ${kesulitan}
Bentuk: ${bentuk}
${catatan ? `Catatan admin: ${catatan}\n` : ''}
Format keluaran: array JSON. Tiap elemen:
{"subtopik":"...","stimulus":"... atau null","pertanyaan":"...", ...${contoh.slice(1, -1)}, "pembahasan":"langkah penyelesaian singkat"}`,
    }],
  });
  await catat(userId, 'generate_soal', null, resp.usage);

  const teks = teksDari(resp).replace(/^```(?:json)?\s*|\s*```$/g, '');
  let arr;
  try {
    arr = JSON.parse(teks);
  } catch {
    throw new HttpError(502, 'AI tidak mengembalikan JSON yang valid. Coba lagi.');
  }
  if (!Array.isArray(arr)) throw new HttpError(502, 'Format hasil AI tidak sesuai.');
  return arr;
}
