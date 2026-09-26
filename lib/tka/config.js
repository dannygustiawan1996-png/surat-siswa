// Konfigurasi aturan modul TKA. Ubah di sini atau lewat environment variable.
const num = (v, d) => (v === undefined || v === '' || isNaN(Number(v)) ? d : Number(v));

export const CONFIG = {
  TIMEZONE: 'Asia/Jakarta',

  // Poin = BOBOT_KESULITAN × BOBOT_MODE × (1 + bonus streak)
  BOBOT_KESULITAN: { mudah: 1, sedang: 2, sulit: 3 },
  BOBOT_MODE: { popup: 1, latihan: 1, tryout: 1.5 },
  BONUS_STREAK_PER_HARI: 0.1, // +10% per hari berturut-turut (hari pertama = 0%)
  BONUS_STREAK_MAKS: 0.5,     // maks. +50%

  // Anti-farming
  POIN_BATAS_HARIAN_PER_MAPEL: num(process.env.TKA_POIN_BATAS_HARIAN_PER_MAPEL, 60),
  MIN_DETIK_JAWAB: num(process.env.TKA_MIN_DETIK_JAWAB, 3),

  // Latihan
  JUMLAH_SOAL_DEFAULT: 10,
  JUMLAH_SOAL_MAKS: 20,

  // Pop-up: true = maks 1x/hari (perilaku normal). Set 'false' selama masa
  // uji coba supaya pop-up tampil tiap kali web dibuka (siswa tetap bisa
  // menutup/mengabaikannya). Ubah balik ke true sebelum rilis resmi.
  POPUP_SEKALI_SEHARI: (process.env.TKA_POPUP_SEKALI_SEHARI ?? 'false') !== 'false',

  // AI
  AI_MODEL: process.env.AI_MODEL || 'claude-sonnet-5',
  AI_BATAS_HARIAN: num(process.env.TKA_AI_BATAS_HARIAN, 30), // pesan chat/pembahasan per siswa per hari
  AI_MAX_TOKENS: 900,
};
