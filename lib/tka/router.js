import { ambilPengguna, ambilAdmin } from './auth.js';
import { HttpError } from './util.js';

/**
 * Satu serverless function menangani banyak action (hemat kuota function Vercel Hobby = 12).
 * URL: /api/tka/<action>  → req.query.action
 */
export function buatRouter(routes, { adminOnly = false } = {}) {
  return async function handler(req, res) {
    res.setHeader('Cache-Control', 'no-store');
    try {
      const action = [].concat(req.query.action || '').join('/');
      const fn = routes[`${req.method} ${action}`];
      if (!fn) throw new HttpError(404, `Endpoint ${req.method} ${action} tidak ada`);

      const user = adminOnly ? await ambilAdmin(req) : await ambilPengguna(req);

      let body = req.body;
      if (typeof body === 'string') { try { body = JSON.parse(body); } catch { body = {}; } }
      const { action: _a, ...query } = req.query || {};

      const out = await fn({ req, user, body: body || {}, query });
      res.status(200).json(out);
    } catch (e) {
      const status = e.status || 500;
      if (status >= 500) console.error('[TKA]', e);
      res.status(status).json({ error: status === 500 ?'Terjadi kesalahan di server. Coba lagi sebentar.' : e.message });
    }
  };
}
