/* Komponen kartu soal (dipakai pop-up dan halaman latihan). Butuh tka-api.js. */
(function () {
  const { esc } = window.TKA;

  /**
   * Render soal ke elemen `el`.
   * opts.onJawab(jawaban, durasiDetik) → Promise<hasil|null>
   * opts.labelTombol  (default "Kirim Jawaban")
   * Mengembalikan { tampilkanHasil(hasil) }.
   */
  function renderSoal(el, soal, opts = {}) {
    const mulai = Date.now();
    const nama = `tka-${soal.id}-${Math.random().toString(36).slice(2, 7)}`;
    let opsiHtml;

    if (soal.bentuk === 'kategori') {
      opsiHtml = `<table class="tka-kategori"><thead><tr><th>Pernyataan</th><th>Benar</th><th>Salah</th></tr></thead><tbody>${soal.opsi
        .map(
          (o) => `<tr data-id="${esc(o.id)}"><td>${esc(o.teks)}</td>
          <td><input type="radio" name="${nama}-${esc(o.id)}" value="true" aria-label="Benar"></td>
          <td><input type="radio" name="${nama}-${esc(o.id)}" value="false" aria-label="Salah"></td></tr>`
        )
        .join('')}</tbody></table>`;
    } else {
      const tipe = soal.bentuk === 'pg_kompleks' ? 'checkbox' : 'radio';
      opsiHtml = `<div class="tka-opsi">${soal.opsi
        .map(
          (o) => `<label class="tka-opsi-item" data-id="${esc(o.id)}"><input type="${tipe}" name="${nama}" value="${esc(o.id)}">
          <span class="tka-opsi-id">${esc(o.id)}</span><span>${esc(o.teks)}</span></label>`
        )
        .join('')}</div>`;
    }

    const petunjuk = { pg: 'Pilih satu jawaban.', pg_kompleks: 'Pilih semua jawaban yang benar.', kategori: 'Tentukan benar atau salah setiap pernyataan.' }[soal.bentuk];

    el.innerHTML = `
      <div class="tka-soal">
        <div class="tka-soal-meta">${esc(soal.topik)} · ${esc(soal.kesulitan)}</div>
        ${soal.stimulus ? `<div class="tka-stimulus">${window.TKA.teks(soal.stimulus)}</div>` : ''}
        <div class="tka-pertanyaan">${window.TKA.teks(soal.pertanyaan)}</div>
        <div class="tka-petunjuk">${petunjuk}</div>
        ${opsiHtml}
        <div class="tka-soal-aksi">
          <button type="button" class="tka-btn tka-btn-utama" data-kirim>${esc(opts.labelTombol || 'Kirim Jawaban')}</button>
        </div>
        <div class="tka-hasil" hidden></div>
      </div>`;

    const tombol = el.querySelector('[data-kirim]');
    const hasilEl = el.querySelector('.tka-hasil');

    function ambilJawaban() {
      if (soal.bentuk === 'kategori') {
        const j = {};
        for (const o of soal.opsi) {
          const r = el.querySelector(`input[name="${nama}-${CSS.escape(String(o.id))}"]:checked`);
          if (!r) return null;
          j[o.id] = r.value === 'true';
        }
        return j;
      }
      const dipilih = [...el.querySelectorAll(`input[name="${nama}"]:checked`)].map((i) => i.value);
      if (!dipilih.length) return null;
      return soal.bentuk === 'pg' ? dipilih[0] : dipilih;
    }

    tombol.addEventListener('click', async () => {
      const jawaban = ambilJawaban();
      if (jawaban === null) {
        hasilEl.hidden = false;
        hasilEl.className = 'tka-hasil tka-info';
        hasilEl.textContent = 'Lengkapi jawabanmu dulu ya.';
        return;
      }
      tombol.disabled = true;
      tombol.textContent = 'Memeriksa...';
      try {
        const hasil = await opts.onJawab?.(jawaban, Math.round((Date.now() - mulai) / 1000));
        el.querySelectorAll('input').forEach((i) => (i.disabled = true));
        if (hasil) tampilkanHasil(hasil);
        tombol.remove();
      } catch (e) {
        tombol.disabled = false;
        tombol.textContent = opts.labelTombol || 'Kirim Jawaban';
        hasilEl.hidden = false;
        hasilEl.className = 'tka-hasil tka-salah';
        hasilEl.textContent = e.message;
      }
    });

    function tampilkanHasil(h) {
      if (h.tersimpan) {
        hasilEl.hidden = false;
        hasilEl.className = 'tka-hasil tka-info';
        hasilEl.textContent = 'Jawaban tersimpan.';
        return;
      }
      // Tandai kunci
      if (soal.bentuk === 'kategori') {
        for (const [id, v] of Object.entries(h.kunci || {})) {
          const tr = el.querySelector(`tr[data-id="${CSS.escape(id)}"]`);
          tr?.classList.add(v ? 'tka-kunci-benar' : 'tka-kunci-salah');
        }
      } else {
        for (const id of h.kunci || []) el.querySelector(`.tka-opsi-item[data-id="${CSS.escape(String(id))}"]`)?.classList.add('tka-kunci');
      }
      hasilEl.hidden = false;
      hasilEl.className = `tka-hasil ${h.benar ? 'tka-benar' : 'tka-salah'}`;
      hasilEl.innerHTML = `
        <div class="tka-hasil-judul">${h.benar ? 'Benar!' : 'Belum tepat'}${h.poin > 0 ? ` <span class="tka-poin">+${h.poin} poin</span>` : ''}</div>
        ${h.catatan ? `<div class="tka-catatan">${esc(h.catatan)}</div>` : ''}
        ${h.pembahasan ? `<div class="tka-pembahasan"><strong>Pembahasan:</strong><br>${window.TKA.teks(h.pembahasan)}</div>` : ''}
        ${h.streak ? `<div class="tka-catatan">Streak: ${h.streak} hari</div>` : ''}`;
    }

    return { tampilkanHasil };
  }

  window.TKA.renderSoal = renderSoal;
})();
