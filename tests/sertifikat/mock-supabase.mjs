// Supabase tiruan untuk menguji /sertifikat/ dan /cek/ di komputer sendiri, tanpa menyentuh database asli.
//   PGLITE_DIR=<folder pglite> node tests/sertifikat/mock-supabase.mjs [port]
// - Postgres: PGlite + migrasi 005 (lihat pg-lokal.mjs)
// - /auth/v1/*   : login email+password tiruan (akun di tests/sertifikat/.akun-uji.json, dibuat otomatis)
// - /rest/v1/rpc : seperti PostgREST (peran anon/authenticated, klaim JWT dari token login)
// - selain itu   : file statis dari repo; alamat Supabase asli & /cek/ diganti ke server ini.
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { bukaDb, rpc } from './pg-lokal.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const PORT = +(process.argv[2] || 5800);
if (process.argv[3]) process.env.PGLITE_DIR = process.argv[3];   // folder pglite boleh juga lewat argumen ke-2
const ASLI = 'https://jxyfiinqxeswyljmzhge.supabase.co';
const LOKAL = `http://localhost:${PORT}`;

const akunFile = path.join(ROOT, 'tests', 'sertifikat', '.akun-uji.json');
const akun = [
  { id: crypto.randomUUID(), email: 'admin.uji@uphc.test', password: 'uji-' + crypto.randomBytes(8).toString('hex'), app_metadata: { provider: 'email', sertifikat_admin: true } },
  { id: crypto.randomUUID(), email: 'guru.uji@uphc.test', password: 'uji-' + crypto.randomBytes(8).toString('hex'), app_metadata: { provider: 'email', surat_admin: true } },
];
fs.writeFileSync(akunFile, JSON.stringify(akun.map(({ email, password }) => ({ email, password })), null, 2));

const db = await bukaDb();
const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
function sesiUntuk(u) {
  const exp = Math.floor(Date.now() / 1000) + 3600;
  const user = { id: u.id, aud: 'authenticated', role: 'authenticated', email: u.email, app_metadata: u.app_metadata, user_metadata: {}, created_at: '2026-01-01T00:00:00Z' };
  const claims = { sub: u.id, email: u.email, role: 'authenticated', aud: 'authenticated', exp, app_metadata: u.app_metadata, user_metadata: {} };
  return { access_token: `${b64({ alg: 'HS256', typ: 'JWT' })}.${b64(claims)}.uji`, token_type: 'bearer', expires_in: 3600, expires_at: exp, refresh_token: 'r-' + u.id, user };
}
function klaimDari(req) {
  const m = /^Bearer (.+)$/.exec(req.headers.authorization || '');
  const parts = m ? m[1].split('.') : [];
  if (parts.length !== 3) return null;                       // kunci publishable (bukan JWT) = anon
  try {
    const c = JSON.parse(Buffer.from(parts[1], 'base64url').toString());
    return c.exp * 1000 > Date.now() ? c : 'expired';
  } catch { return null; }
}

const TIPE = { '.html': 'text/html; charset=utf-8', '.png': 'image/png', '.js': 'text/javascript', '.svg': 'image/svg+xml', '.json': 'application/json' };
function kirim(res, code, body, type) {
  res.writeHead(code, { 'Content-Type': type || 'application/json', 'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*', 'Access-Control-Allow-Methods': 'GET,POST,OPTIONS' });
  res.end(typeof body === 'string' || Buffer.isBuffer(body) ? body : JSON.stringify(body));
}
function bacaBody(req) {
  return new Promise((ok) => { let s = ''; req.on('data', (d) => { s += d; }); req.on('end', () => ok(s)); });
}

http.createServer(async (req, res) => {
  const u = new URL(req.url, LOKAL);
  if (req.method === 'OPTIONS') return kirim(res, 204, '');
  try {
    // ---- auth ----
    if (u.pathname === '/auth/v1/token') {
      const b = JSON.parse((await bacaBody(req)) || '{}');
      let a = null;
      if (u.searchParams.get('grant_type') === 'password') a = akun.find((x) => x.email === String(b.email).toLowerCase() && x.password === b.password);
      if (u.searchParams.get('grant_type') === 'refresh_token') a = akun.find((x) => 'r-' + x.id === b.refresh_token);
      if (!a) return kirim(res, 400, { code: 400, error_code: 'invalid_credentials', msg: 'Invalid login credentials' });
      return kirim(res, 200, sesiUntuk(a));
    }
    if (u.pathname === '/auth/v1/logout') return kirim(res, 204, '');
    if (u.pathname === '/auth/v1/user') {
      const c = klaimDari(req);
      const a = c && c !== 'expired' && akun.find((x) => x.id === c.sub);
      return a ? kirim(res, 200, sesiUntuk(a).user) : kirim(res, 401, { code: 401, msg: 'invalid JWT' });
    }
    // ---- PostgREST rpc ----
    const m = /^\/rest\/v1\/rpc\/([a-z_]+)$/.exec(u.pathname);
    if (m && req.method === 'POST') {
      const c = klaimDari(req);
      if (c === 'expired') return kirim(res, 401, { code: 'PGRST301', message: 'JWT expired', details: null, hint: null });
      const args = JSON.parse((await bacaBody(req)) || '{}');
      const delay = +(process.env.MOCK_DELAY_MS || 0);
      if (delay) await new Promise((r) => setTimeout(r, delay));
      try {
        const hasil = await rpc(db, c ? 'authenticated' : 'anon', c || {}, m[1], args);
        return kirim(res, 200, hasil);
      } catch (e) {
        const code = e.code || '';
        const status = code === 'PGRST202' ? 404 : code === '42501' ? (c ? 403 : 401) : 400;
        return kirim(res, status, { code, message: e.message, details: null, hint: null });
      }
    }
    if (u.pathname.startsWith('/rest/') || u.pathname.startsWith('/auth/')) return kirim(res, 404, { message: 'tidak ada di server tiruan' });

    // ---- file statis dari repo ----
    let p = decodeURIComponent(u.pathname);
    if (p.endsWith('/')) p += 'index.html';
    const f = path.join(ROOT, path.normalize(p));
    if (!f.startsWith(ROOT) || f.includes(`${path.sep}tests${path.sep}`) || !fs.existsSync(f) || fs.statSync(f).isDirectory()) return kirim(res, 404, 'not found', 'text/plain');
    let isi = fs.readFileSync(f);
    if (f.endsWith('.html')) {
      isi = isi.toString('utf8').split(ASLI).join(LOKAL).split('https://surat-siswa.vercel.app/cek/').join(`${LOKAL}/cek/`);
    }
    return kirim(res, 200, isi, TIPE[path.extname(f)] || 'application/octet-stream');
  } catch (e) {
    console.error(e);
    return kirim(res, 500, { message: String(e.message || e) });
  }
}).listen(PORT, () => console.log(`Supabase tiruan siap: ${LOKAL}/sertifikat/  ·  ${LOKAL}/cek/#<token>  (akun uji: tests/sertifikat/.akun-uji.json)`));
