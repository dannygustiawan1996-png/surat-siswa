/* Pembungkus fetch ke API TKA. Butuh tka-config.js dimuat lebih dulu. */
(function () {
  const cfg = () => window.TKA_CONFIG || {};

  function headerProfil() {
    const p = cfg().getProfil?.();
    if (!p?.nis) {
      const e = new Error('Isi profil (Nama & NIS) dulu ya');
      e.status = 401;
      throw e;
    }
    const h = { 'X-Tka-Nis': p.nis, 'X-Tka-Nama': p.nama || '' };
    if (p.kelas) h['X-Tka-Kelas'] = p.kelas;
    if (p.angkatan) h['X-Tka-Angkatan'] = String(p.angkatan);
    return h;
  }

  async function baca(res) {
    let data = {};
    try { data = await res.json(); } catch { /* kosong */ }
    if (!res.ok) {
      const e = new Error(data.error || `Gagal (${res.status})`);
      e.status = res.status;
      throw e;
    }
    return data;
  }

  async function panggilSiswa(method, path, body) {
    const res = await fetch(`${cfg().apiBase || '/api'}/${path}`, {
      method,
      headers: { 'Content-Type': 'application/json', ...headerProfil() },
      body: body ? JSON.stringify(body) : undefined,
    });
    return baca(res);
  }

  async function panggilAdmin(method, path, body) {
    const token = await cfg().getAdminToken?.();
    if (!token) {
      const e = new Error('Silakan login admin terlebih dahulu');
      e.status = 401;
      throw e;
    }
    const res = await fetch(`${cfg().apiBase || '/api'}/${path}`, {
      method,
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: body ? JSON.stringify(body) : undefined,
    });
    return baca(res);
  }

  const qs = (o = {}) => {
    const p = new URLSearchParams(Object.entries(o).filter(([, v]) => v !== undefined && v !== null && v !== ''));
    const s = p.toString();
    return s ? `?${s}` : '';
  };

  /**
   * Pastikan profil (Nama+NIS) sudah ada di localStorage. Kalau belum,
   * tampilkan form kecil untuk mengisinya.
   * opts.opsional = true → ada tombol "Nanti saja" (dipakai pop-up ajakan),
   * default false → wajib diisi (dipakai halaman latihan/leaderboard).
   * Mengembalikan Promise<profil|null> (null hanya jika opsional & dilewati).
   */
  function pastikanProfil(opts = {}) {
    const ada = cfg().getProfil?.();
    if (ada?.nis) return Promise.resolve(ada);

    return new Promise((resolve) => {
      const overlay = document.createElement('div');
      overlay.className = 'tka-overlay';
      overlay.innerHTML = `
        <div class="tka-modal" role="dialog" aria-modal="true" aria-labelledby="tka-profil-judul">
          ${opts.opsional ? '<button type="button" class="tka-tutup" aria-label="Tutup">×</button>' : ''}
          <h2 id="tka-profil-judul">Yuk kenalan dulu 👋</h2>
          <p class="tka-catatan">Isi sekali saja — dipakai untuk mencatat progres &amp; leaderboard Latihan TKA-mu. Tidak perlu login.</p>
          <label class="tka-label">Nama <input id="tka-p-nama" class="tka-input" maxlength="80"></label>
          <label class="tka-label">NIS <input id="tka-p-nis" class="tka-input" maxlength="40"></label>
          <label class="tka-label">Kelas (opsional) <input id="tka-p-kelas" class="tka-input" maxlength="20" placeholder="mis. XII-A"></label>
          <label class="tka-label">Angkatan/tahun lulus (opsional) <input id="tka-p-angkatan" class="tka-input" maxlength="4" placeholder="mis. 2027"></label>
          <div class="tka-catatan tka-catatan-err" id="tka-p-err"></div>
          <div class="tka-popup-aksi">
            ${opts.opsional ? '<button type="button" class="tka-btn" data-lewati>Nanti saja</button>' : ''}
            <button type="button" class="tka-btn tka-btn-utama" data-simpan>Mulai</button>
          </div>
        </div>`;
      document.body.appendChild(overlay);
      document.body.classList.add('tka-no-scroll');

      const tutup = (hasil) => {
        overlay.remove();
        document.body.classList.remove('tka-no-scroll');
        resolve(hasil);
      };

      const simpan = () => {
        const nama = overlay.querySelector('#tka-p-nama').value.trim();
        const nis = overlay.querySelector('#tka-p-nis').value.trim();
        const kelas = overlay.querySelector('#tka-p-kelas').value.trim();
        const angkatan = Number(overlay.querySelector('#tka-p-angkatan').value.trim()) || null;
        if (!nama || !nis) {
          overlay.querySelector('#tka-p-err').textContent = 'Nama dan NIS wajib diisi.';
          return;
        }
        const profil = { nama, nis, kelas: kelas || null, angkatan };
        cfg().simpanProfil?.(profil);
        tutup(profil);
      };

      overlay.querySelector('[data-simpan]').onclick = simpan;
      overlay.querySelector('[data-lewati]')?.addEventListener('click', () => tutup(null));
      overlay.querySelector('.tka-tutup')?.addEventListener('click', () => tutup(null));
    });
  }

  window.TKA = {
    get: (path, query) => panggilSiswa('GET', `tka/${path}${qs(query)}`),
    post: (path, body) => panggilSiswa('POST', `tka/${path}`, body),
    put: (path, body) => panggilSiswa('PUT', `tka/${path}`, body),
    admin: {
      get: (path, query) => panggilAdmin('GET', `tka-admin/${path}${qs(query)}`),
      post: (path, body) => panggilAdmin('POST', `tka-admin/${path}`, body),
      put: (path, body) => panggilAdmin('PUT', `tka-admin/${path}`, body),
    },
    pastikanProfil,
    esc(s) {
      return String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
    },
    /** Teks → HTML aman: escape + baris baru + **tebal** */
    teks(s) {
      return window.TKA.esc(s).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>').replace(/\n/g, '<br>');
    },
  };
})();
