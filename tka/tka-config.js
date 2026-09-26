/*
 * KONFIGURASI MODUL TKA (browser)
 * --------------------------------
 * Siswa TIDAK login. Identitas (Nama + NIS, dst) diisi sekali lewat
 * form kecil (lihat TKA.pastikanProfil() di tka-api.js) dan disimpan di
 * localStorage, lalu dikirim di header tiap request ke /api/tka/*.
 *
 * Admin TETAP login (sama seperti Dashboard Admin di halaman utama),
 * lewat client Supabase project ini — dipakai untuk /api/tka-admin/*.
 */
window.TKA_CONFIG = {
  apiBase: '/api',
  SUPABASE_URL: 'https://jxyfiinqxeswyljmzhge.supabase.co',
  SUPABASE_ANON_KEY: 'sb_publishable_mRKDBw_XWZwHPAZQFEKYDg_n6au_AkQ', // sama dengan index.html

  // Profil siswa (Nama, NIS, Kelas, Angkatan) — null kalau belum diisi
  getProfil() {
    try { return JSON.parse(localStorage.getItem('tka_profil') || 'null'); } catch { return null; }
  },
  simpanProfil(p) {
    localStorage.setItem('tka_profil', JSON.stringify(p));
  },

  // Access token admin (sesi Supabase Auth yang sama dengan login web surat)
  async getAdminToken() {
    if (!window.supabase) return null;
    if (!this._sbAdmin) this._sbAdmin = window.supabase.createClient(this.SUPABASE_URL, this.SUPABASE_ANON_KEY);
    const { data } = await this._sbAdmin.auth.getSession();
    return data?.session?.access_token ?? null;
  },

  // Halaman-halaman modul TKA
  halamanLatihan: '/tka/latihan.html',
  halamanLeaderboard: '/tka/leaderboard.html',
  halamanUtama: '/', // halaman utama web surat (login admin ada di sini)
};
