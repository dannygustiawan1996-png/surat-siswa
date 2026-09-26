import { db } from './supabase.js';
import { HttpError, cek } from './util.js';

/**
 * Identitas siswa TANPA LOGIN: browser mengirim Nama + NIS (dan opsional
 * Kelas/Angkatan) lewat header, diisi sekali oleh siswa dan disimpan di
 * localStorage (lihat tka/tka-api.js pastikanProfil()). Server
 * percaya begitu saja — sama seperti field "Student ID/NIS" yang sudah
 * dipakai di form-form lain web surat ini, tidak ada verifikasi identitas.
 */
export async function ambilPengguna(req) {
  const nis = String(req.headers['x-tka-nis'] || '').trim().slice(0, 40);
  if (!nis) throw new HttpError(401, 'Isi profil (Nama & NIS) dulu ya');
  const nama = String(req.headers['x-tka-nama'] || '').trim().slice(0, 80) || 'Siswa';
  const kelasRaw = req.headers['x-tka-kelas'];
  const kelas = kelasRaw ? String(kelasRaw).trim().slice(0, 20) : null;
  const angkatanRaw = req.headers['x-tka-angkatan'];
  const angkatan = angkatanRaw ? Number(angkatanRaw) || null : null;

  return cek(
    await db()
      .from('tka_pengguna')
      .upsert({ user_id: nis, nama, kelas, angkatan }, { onConflict: 'user_id' })
      .select('*')
      .single(),
    'Gagal menyimpan profil TKA'
  );
}

/**
 * Identitas admin: sesi Supabase Auth yang SAMA dengan login Dashboard
 * Admin di halaman utama web surat (header "Authorization: Bearer <token>").
 * Tidak ada tabel peran terpisah — siapa pun yang punya sesi admin valid
 * di project Supabase ini otomatis dianggap Admin TKA juga.
 */
export async function ambilAdmin(req) {
  const h = req.headers.authorization || req.headers.Authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) throw new HttpError(401, 'Silakan login admin terlebih dahulu');
  const { data, error } = await db().auth.getUser(token);
  if (error || !data?.user) throw new HttpError(401, 'Sesi admin tidak valid, silakan login ulang');
  return { user_id: data.user.id, email: data.user.email, nama: data.user.email };
}
