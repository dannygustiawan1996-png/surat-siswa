/*
 * POP-UP AJAKAN LATIHAN TKA
 * Pasang di halaman utama web surat:
 *   <link rel="stylesheet" href="/tka/tka.css">
 *   <script src="/tka/tka-config.js"></script>
 *   <script src="/tka/tka-api.js"></script>
 *   <script src="/tka/tka-soal.js"></script>
 *   <script src="/tka/tka-popup.js"></script>
 * Lalu panggil  TKA.tampilkanPopup()  saat halaman dimuat.
 * Tidak ada login siswa — kalau profil (Nama+NIS) belum pernah diisi,
 * fungsi ini akan menampilkan form kecil dulu (boleh dilewati "Nanti saja").
 * Server yang menentukan boleh tampil atau tidak (maks. 1x/hari, target angkatan, dll).
 */
(function () {
  const { esc } = window.TKA;
  let sedangTampil = false;

  async function tampilkanPopup() {
    if (sedangTampil) return;
    const profil = await window.TKA.pastikanProfil({ opsional: true });
    if (!profil) return; // siswa memilih "Nanti saja"

    let d;
    try {
      d = await window.TKA.get('popup');
    } catch (e) {
      if (e.status !== 401) console.warn('[TKA] popup:', e.message);
      return;
    }
    if (!d.tampil) return;
    sedangTampil = true;

    const overlay = document.createElement('div');
    overlay.className = 'tka-overlay';
    overlay.innerHTML = `
      <div class="tka-modal" role="dialog" aria-modal="true" aria-labelledby="tka-popup-judul">
        <button type="button" class="tka-tutup" aria-label="Tutup">×</button>
        <div class="tka-popup-head">
          <div class="tka-badge">Latihan TKA</div>
          <h2 id="tka-popup-judul">${esc(d.judul)}</h2>
          <p>${esc(d.pesan)}</p>
          <div class="tka-statistik">
            ${d.hari_menuju_tka != null ? `<div><strong>${d.hari_menuju_tka}</strong><span>hari menuju TKA</span></div>` : ''}
            <div><strong>${d.streak || 0}</strong><span>hari streak</span></div>
            <div><strong>${d.peringkat ? '#' + d.peringkat : '–'}</strong><span>${esc(d.mapel.nama)} minggu ini</span></div>
          </div>
        </div>
        <div class="tka-popup-soal-label">Soal Harian · ${esc(d.mapel.nama)}</div>
        <div class="tka-popup-soal"></div>
        <div class="tka-popup-aksi">
          <button type="button" class="tka-btn" data-nanti>Nanti saja</button>
          <button type="button" class="tka-btn tka-btn-utama" data-mulai>Mulai Latihan</button>
        </div>
      </div>`;
    document.body.appendChild(overlay);
    document.body.classList.add('tka-no-scroll');

    const tutup = async (aksi) => {
      overlay.remove();
      document.body.classList.remove('tka-no-scroll');
      sedangTampil = false;
      if (aksi) { try { await window.TKA.post('popup-aksi', { aksi }); } catch { /* abaikan */ } }
    };

    window.TKA.renderSoal(overlay.querySelector('.tka-popup-soal'), d.soal, {
      onJawab: (jawaban, durasi_detik) =>
        window.TKA.post('jawab', { sesi_id: d.sesi_id, soal_id: d.soal.id, jawaban, durasi_detik }),
    });

    overlay.querySelector('.tka-tutup').onclick = () => tutup('ditutup');
    overlay.querySelector('[data-nanti]').onclick = () => tutup('ditutup');
    overlay.querySelector('[data-mulai]').onclick = async () => {
      await tutup('mulai_latihan');
      const url = new URL(window.TKA_CONFIG.halamanLatihan, location.origin);
      url.searchParams.set('mapel_id', d.mapel.id);
      location.href = url.toString();
    };
    overlay.addEventListener('click', (e) => { if (e.target === overlay) tutup('ditutup'); });
    document.addEventListener('keydown', function esc(e) {
      if (e.key === 'Escape' && sedangTampil) { tutup('ditutup'); document.removeEventListener('keydown', esc); }
    });
  }

  window.TKA.tampilkanPopup = tampilkanPopup;
})();
