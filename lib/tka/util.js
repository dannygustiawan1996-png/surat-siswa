import crypto from 'node:crypto';
import { CONFIG } from './config.js';

export class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

export const bad = (msg) => new HttpError(400, msg);
export const forbidden = (msg = 'Akses ditolak') => new HttpError(403, msg);
export const notFound = (msg = 'Data tidak ditemukan') => new HttpError(404, msg);

/** Tanggal hari ini (YYYY-MM-DD) di zona Asia/Jakarta */
export function hariIni(date = new Date()) {
  return new Intl.DateTimeFormat('en-CA', { timeZone: CONFIG.TIMEZONE }).format(date);
}

/** Selisih hari (b - a), keduanya 'YYYY-MM-DD' */
export function selisihHari(a, b) {
  return Math.round((Date.parse(b + 'T00:00:00Z') - Date.parse(a + 'T00:00:00Z')) / 86400000);
}

export function acak(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

export function acakUrut(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export function md5(v) {
  return crypto.createHash('md5').update(JSON.stringify(v)).digest('hex');
}

/** Buang kunci & pembahasan sebelum soal dikirim ke browser */
export function soalPublik(s) {
  if (!s) return null;
  const { kunci, pembahasan, dibuat_oleh, status, sumber, divalidasi_at, created_at, updated_at, ...rest } = s;
  return rest;
}

/** Throw jika query Supabase error */
export function cek({ data, error }, pesan = 'Kesalahan database') {
  if (error) {
    const e = new HttpError(500, `${pesan}: ${error.message}`);
    e.code = error.code;
    throw e;
  }
  return data;
}

export function wajib(obj, fields) {
  for (const f of fields) {
    if (obj?.[f] === undefined || obj?.[f] === null || obj?.[f] === '') throw bad(`Field "${f}" wajib diisi`);
  }
}

/** Isi template pesan pop-up: {nama} {hari} {streak} {peringkat} {mapel} */
export function isiTemplate(tpl, data) {
  return tpl.replace(/\{(\w+)\}/g, (_, k) => (data[k] ?? `{${k}}`));
}
