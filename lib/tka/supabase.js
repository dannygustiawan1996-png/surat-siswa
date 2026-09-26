import { createClient } from '@supabase/supabase-js';

let _admin;

/** Client service role: melewati RLS. HANYA dipakai di server. */
export function db() {
  if (!_admin) {
    const url = process.env.SUPABASE_URL;
    const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
    if (!url || !key) throw new Error('SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY belum diset');
    _admin = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
  }
  return _admin;
}
