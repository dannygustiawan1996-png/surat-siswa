// Postgres lokal (PGlite) yang meniru bagian Supabase yang dipakai sertifikat:
// peran anon/authenticated, schema auth dengan auth.jwt(), lalu migrasi 005.
// PGlite tidak ada di package.json (supaya Vercel tidak ikut memasangnya). Pasang sekali di folder lain:
//   npm install --prefix <folder> @electric-sql/pglite@0.2.17
// lalu jalankan dengan PGLITE_DIR=<folder>.
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL, fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');

export async function bukaDb() {
  const dir = process.env.PGLITE_DIR;
  if (!dir) throw new Error('Set PGLITE_DIR ke folder tempat @electric-sql/pglite dipasang.');
  const { PGlite } = await import(pathToFileURL(path.join(dir, 'node_modules', '@electric-sql', 'pglite', 'dist', 'index.js')).href);
  const db = new PGlite();
  await db.exec(`
    create role anon nologin;
    create role authenticated nologin;
    create schema auth;
    create function auth.jwt() returns jsonb language sql stable as $$
      select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb
    $$;
    grant usage on schema auth to anon, authenticated;
    grant execute on function auth.jwt() to anon, authenticated;
    grant usage on schema public to anon, authenticated;
    -- Supabase memberi hak tabel bawaan ke anon/authenticated; tiru supaya revoke di migrasi ikut teruji.
    alter default privileges in schema public grant all on tables to anon, authenticated;
  `);
  await db.exec(fs.readFileSync(path.join(ROOT, 'supabase', 'migrations', '005_sertifikat.sql'), 'utf8'));
  return db;
}

// Menjalankan satu query sebagai peran tertentu dengan klaim JWT tertentu (seperti PostgREST).
export async function sebagai(db, peran, klaim, sql, params) {
  return db.transaction(async (tx) => {
    await tx.query(`select set_config('request.jwt.claims', $1, true)`, [JSON.stringify(klaim || {})]);
    await tx.exec(`set local role ${peran}`);
    return tx.query(sql, params || []);
  });
}

// Memanggil fungsi RPC dengan argumen bernama, persis seperti PostgREST /rest/v1/rpc/<fungsi>.
export async function rpc(db, peran, klaim, fungsi, args) {
  if (!/^[a-z_]+$/.test(fungsi)) throw new Error('nama fungsi tidak sah');
  const keys = Object.keys(args || {});
  const tipe = await db.query(
    `select p.parameter_name as n, p.data_type as t from information_schema.parameters p
       join information_schema.routines r on r.specific_name = p.specific_name
      where r.routine_schema = 'public' and r.routine_name = $1 and p.parameter_mode = 'IN'`, [fungsi]);
  const peta = Object.fromEntries(tipe.rows.map((r) => [r.n, r.t]));
  const daftar = keys.map((k, i) => {
    if (!peta[k]) throw Object.assign(new Error(`Fungsi ${fungsi} tidak punya argumen ${k}`), { code: 'PGRST202' });
    return `${k} => $${i + 1}::${peta[k] === 'jsonb' ? 'jsonb' : peta[k] === 'integer' ? 'int' : 'text'}`;
  }).join(', ');
  const nilai = keys.map((k) => (peta[k] === 'jsonb' ? JSON.stringify(args[k]) : args[k]));
  const r = await sebagai(db, peran, klaim, `select public.${fungsi}(${daftar}) as hasil`, nilai);
  return r.rows[0].hasil;
}
