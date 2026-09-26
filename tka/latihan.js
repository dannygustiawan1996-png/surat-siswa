/* Halaman chatbot latihan TKA */
(function () {
  const T = window.TKA;
  const $ = (s) => document.querySelector(s);
  const log = $('#chat-log');

  const state = {
    profil: null,
    sesi: null,        // { sesi_id, mode, soal:[], idx, berakhir_at }
    soalAktifId: null, // untuk konteks chat AI
    riwayatChat: [],
    timer: null,
  };

  // ------------------------------------------------------------------
  // Tampilan chat
  // ------------------------------------------------------------------
  function bubble(dari, html) {
    const el = document.createElement('div');
    el.className = `tka-bubble tka-${dari}`;
    el.innerHTML = html;
    log.appendChild(el);
    el.scrollIntoView({ behavior: 'smooth', block: 'end' });
    return el;
  }
  const bot = (html) => bubble('bot', html);
  const saya = (teks) => bubble('saya', T.esc(teks));
  const mengetik = () => bot('<span class="tka-mengetik"><i></i><i></i><i></i></span>');

  function tombol(label, onClick, utama) {
    const b = document.createElement('button');
    b.type = 'button';
    b.className = `tka-btn${utama ? ' tka-btn-utama' : ''}`;
    b.textContent = label;
    b.onclick = onClick;
    return b;
  }
  function barisTombol(el, list) {
    const w = document.createElement('div');
    w.className = 'tka-baris-tombol';
    list.forEach(([l, f, u]) => w.appendChild(tombol(l, f, u)));
    el.appendChild(w);
    return w;
  }
  const namaMapel = (id) => state.profil.mapel.find((m) => m.id === Number(id))?.nama || 'mapel';

  // ------------------------------------------------------------------
  // Inisialisasi
  // ------------------------------------------------------------------
  async function init() {
    await T.pastikanProfil();
    try {
      state.profil = await T.get('profil');
    } catch (e) {
      bot(`Gagal memuat data: ${T.esc(e.message)}`);
      return;
    }
    const p = state.profil;
    $('#info-streak').textContent = `Streak ${p.streak} hari`;
    isiDropdownMapel();

    const qMapel = new URLSearchParams(location.search).get('mapel_id');
    if (qMapel) $('#pilih-mapel').value = qMapel;
    await muatTopik();

    bot(`Halo <strong>${T.esc(p.pengguna.nama_tampilan || p.pengguna.nama)}</strong>! Aku Kak TKA, teman latihanmu.<br>
      Pilih mapel di panel kiri lalu tekan <strong>Mulai Latihan</strong>, atau ketik pertanyaan materi apa saja.`);

    if (!p.pilihan_mapel.length) tampilkanPilihMapel();
    if (qMapel) mulaiLatihan();
  }

  function isiDropdownMapel() {
    const p = state.profil;
    const wajib = p.mapel.filter((m) => m.kelompok === 'wajib');
    const pilihan = p.mapel.filter((m) => p.pilihan_mapel.includes(m.id));
    const lain = p.mapel.filter((m) => m.kelompok === 'pilihan' && !p.pilihan_mapel.includes(m.id));
    const opt = (m) => `<option value="${m.id}">${T.esc(m.nama)}</option>`;
    $('#pilih-mapel').innerHTML =
      `<optgroup label="Mapel wajib">${wajib.map(opt).join('')}</optgroup>` +
      (pilihan.length ? `<optgroup label="Mapel pilihanmu">${pilihan.map(opt).join('')}</optgroup>` : '') +
      `<optgroup label="Mapel pilihan lain">${lain.map(opt).join('')}</optgroup>`;
  }

  async function muatTopik() {
    try {
      const { topik } = await T.get('topik', { mapel_id: $('#pilih-mapel').value });
      $('#pilih-topik').innerHTML = '<option value="">Semua topik</option>' + topik.map((t) => `<option>${T.esc(t)}</option>`).join('');
    } catch { /* abaikan */ }
  }

  // ------------------------------------------------------------------
  // Pilihan mapel (maks 2)
  // ------------------------------------------------------------------
  function tampilkanPilihMapel() {
    const pil = state.profil.mapel.filter((m) => m.kelompok === 'pilihan');
    const el = bot(`<strong>Pilih 2 mapel pilihan TKA-mu</strong> agar latihan & pop-up harian sesuai:
      <div class="tka-cek-grid">${pil
        .map((m) => `<label><input type="checkbox" value="${m.id}" ${state.profil.pilihan_mapel.includes(m.id) ? 'checked' : ''}> ${T.esc(m.nama)}</label>`)
        .join('')}</div>`);
    el.querySelectorAll('input').forEach((i) =>
      i.addEventListener('change', () => {
        if (el.querySelectorAll('input:checked').length > 2) { i.checked = false; alertKecil(el, 'Maksimal 2 mapel.'); }
      })
    );
    barisTombol(el, [['Simpan', async () => {
      const ids = [...el.querySelectorAll('input:checked')].map((i) => Number(i.value));
      try {
        await T.put('pilihan-mapel', { mapel_ids: ids });
        state.profil.pilihan_mapel = ids;
        isiDropdownMapel();
        el.querySelector('.tka-baris-tombol').remove();
        bot(`Tersimpan: ${ids.map(namaMapel).join(' & ') || 'belum ada'}.`);
      } catch (e) { alertKecil(el, e.message); }
    }, true]]);
  }
  function alertKecil(el, pesan) {
    let a = el.querySelector('.tka-catatan-err');
    if (!a) { a = document.createElement('div'); a.className = 'tka-catatan tka-catatan-err'; el.appendChild(a); }
    a.textContent = pesan;
  }

  // ------------------------------------------------------------------
  // Latihan
  // ------------------------------------------------------------------
  async function mulaiLatihan(opsi = {}) {
    hentikanTimer();
    const mapel_id = opsi.mapel_id || $('#pilih-mapel').value;
    const body = {
      mode: 'latihan', mapel_id,
      jumlah: opsi.jumlah || Number($('#pilih-jumlah').value),
      topik: opsi.topik ?? ($('#pilih-topik').value || undefined),
      kesulitan: $('#pilih-kesulitan').value || undefined,
    };
    const t = mengetik();
    try {
      const d = await T.post('mulai', body);
      t.remove();
      state.sesi = { ...d, idx: 0, mapel_id };
      bot(`Siap! <strong>${d.soal.length} soal ${T.esc(namaMapel(mapel_id))}</strong>. Semangat!`);
      tampilkanSoal();
    } catch (e) {
      t.remove();
      bot(T.esc(e.message));
    }
  }

  function tampilkanSoal() {
    const s = state.sesi;
    const soal = s.soal[s.idx];
    state.soalAktifId = soal.id;
    const el = bot(`<div class="tka-nomor">Soal ${s.idx + 1} dari ${s.soal.length}</div><div class="tka-wadah-soal"></div>`);
    el.classList.add('tka-bubble-lebar');

    T.renderSoal(el.querySelector('.tka-wadah-soal'), soal, {
      onJawab: async (jawaban, durasi_detik) => {
        const h = await T.post('jawab', { sesi_id: s.sesi_id, soal_id: soal.id, jawaban, durasi_detik });
        if (h.streak) $('#info-streak').textContent = `Streak ${h.streak} hari`;
        setTimeout(() => setelahJawab(el, soal, h), 0);
        return h;
      },
    });
  }

  function setelahJawab(el, soal, h) {
    const s = state.sesi;
    const akhir = s.idx >= s.soal.length - 1;
    const aksi = [];
    if (!h.tersimpan) aksi.push(['Jelaskan lebih detail', () => mintaPembahasan(soal.id)]);
    aksi.push(['Laporkan soal', () => laporkan(soal.id)]);
    aksi.push([akhir ? 'Lihat hasil' : 'Soal berikutnya', () => {
      el.querySelector('.tka-baris-tombol')?.remove();
      if (akhir) selesaikan(); else { s.idx++; tampilkanSoal(); }
    }, true]);
    barisTombol(el, aksi);
  }

  async function mintaPembahasan(soalId) {
    const t = mengetik();
    try {
      const { pembahasan } = await T.post('pembahasan', { sesi_id: state.sesi.sesi_id, soal_id: soalId });
      t.remove();
      bot(T.teks(pembahasan));
      state.riwayatChat.push({ role: 'assistant', content: pembahasan });
    } catch (e) { t.remove(); bot(T.esc(e.message)); }
  }

  function laporkan(soalId) {
    const el = bot(`Apa yang keliru dari soal ini?<textarea class="tka-input" rows="2" placeholder="mis. kunci salah, opsi ganda, typo"></textarea>`);
    barisTombol(el, [['Kirim laporan', async () => {
      const alasan = el.querySelector('textarea').value.trim();
      if (!alasan) return;
      try {
        const r = await T.post('lapor', { soal_id: soalId, alasan });
        el.innerHTML = T.esc(r.pesan);
      } catch (e) { alertKecil(el, e.message); }
    }, true]]);
  }

  async function selesaikan() {
    hentikanTimer();
    const t = mengetik();
    try {
      const r = await T.post('selesai', { sesi_id: state.sesi.sesi_id });
      t.remove();
      let html = `<strong>Selesai!</strong> Benar ${r.benar}/${r.total} · skor ${r.skor} · <strong>+${r.total_poin} poin</strong>`;
      if (r.rincian) {
        html += `<ol class="tka-rincian">${r.rincian
          .map((x) => `<li class="${x.benar ? 'ok' : 'x'}">${T.esc(x.topik)} — ${x.benar ? 'benar' : `salah (kunci: ${T.esc(JSON.stringify(x.kunci))})`}</li>`)
          .join('')}</ol>`;
      }
      if (r.rekomendasi?.length) {
        html += `<div class="tka-catatan">Topik yang perlu dilatih lagi: ${r.rekomendasi.map((x) => `<strong>${T.esc(x.topik)}</strong> (${x.persen}%)`).join(', ')}</div>`;
      }
      const el = bot(html);
      const aksi = [['Latihan lagi', () => mulaiLatihan({ mapel_id: state.sesi.mapel_id }), true]];
      if (r.rekomendasi?.[0]) aksi.unshift([`Latih "${r.rekomendasi[0].topik}"`, () => mulaiLatihan({ mapel_id: state.sesi.mapel_id, topik: r.rekomendasi[0].topik })]);
      aksi.push(['Leaderboard', () => (location.href = window.TKA_CONFIG.halamanLeaderboard)]);
      barisTombol(el, aksi);
    } catch (e) { t.remove(); bot(T.esc(e.message)); }
  }

  // ------------------------------------------------------------------
  // Tryout
  // ------------------------------------------------------------------
  async function lihatTryout() {
    const t = mengetik();
    try {
      const { tryout } = await T.get('tryout');
      t.remove();
      if (!tryout.length) { bot('Belum ada tryout yang dibuka saat ini. Pantau terus ya!'); return; }
      const el = bot('<strong>Tryout yang sedang dibuka:</strong>');
      barisTombol(el, tryout.map((to) => [
        `${to.judul} · ${to.mapel?.nama} · ${to.durasi_menit} mnt${to.sesi?.selesai_at ? ` (skor ${to.sesi.skor})` : ''}`,
        () => (to.sesi?.selesai_at ? bot('Tryout ini sudah kamu selesaikan. Hasil tercatat di leaderboard.') : mulaiTryout(to)),
      ]));
    } catch (e) { t.remove(); bot(T.esc(e.message)); }
  }

  async function mulaiTryout(to) {
    const el = bot(`Tryout <strong>${T.esc(to.judul)}</strong>: ${to.durasi_menit} menit. Tryout hanya dihitung <strong>satu kali</strong> untuk leaderboard dan pembahasan dibuka setelah selesai. Mulai sekarang?`);
    barisTombol(el, [['Mulai', async () => {
      el.querySelector('.tka-baris-tombol').remove();
      try {
        const d = await T.post('mulai', { mode: 'tryout', tryout_id: to.id });
        const sisa = d.soal.filter((s) => !d.sudah_dijawab.includes(s.id));
        state.sesi = { ...d, soal: sisa.length ? sisa : d.soal, idx: 0, mapel_id: to.mapel?.id };
        mulaiTimer(new Date(d.berakhir_at));
        tampilkanSoal();
      } catch (e) { bot(T.esc(e.message)); }
    }, true]]);
  }

  function mulaiTimer(akhir) {
    hentikanTimer();
    const chip = $('#info-streak');
    const asli = chip.textContent;
    state.timer = setInterval(() => {
      const d = Math.max(0, Math.round((akhir - Date.now()) / 1000));
      chip.textContent = `Sisa ${Math.floor(d / 60)}:${String(d % 60).padStart(2, '0')}`;
      if (d <= 0) { hentikanTimer(); chip.textContent = asli; bot('Waktu habis!'); selesaikan(); }
    }, 1000);
  }
  function hentikanTimer() { if (state.timer) clearInterval(state.timer); state.timer = null; }

  // ------------------------------------------------------------------
  // Chat bebas + perintah sederhana
  // ------------------------------------------------------------------
  function cariMapelDariTeks(teks) {
    const t = teks.toLowerCase();
    const alias = { mtk: 'Matematika', matematika: 'Matematika', mat: 'Matematika', indo: 'Bahasa Indonesia', 'b indo': 'Bahasa Indonesia', inggris: 'Bahasa Inggris', english: 'Bahasa Inggris' };
    const byNama = [...state.profil.mapel].sort((a, b) => b.nama.length - a.nama.length).find((m) => t.includes(m.nama.toLowerCase()));
    if (byNama) return byNama;
    for (const [k, v] of Object.entries(alias)) if (t.includes(k)) return state.profil.mapel.find((m) => m.nama === v);
    return null;
  }

  $('#chat-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const input = $('#chat-input');
    const pesan = input.value.trim();
    if (!pesan) return;
    input.value = '';
    saya(pesan);

    // Perintah "latihan <mapel> <n> soal"
    if (/^(latihan|mulai|kerjain|kerjakan)\b/i.test(pesan)) {
      const m = cariMapelDariTeks(pesan);
      const n = Number((pesan.match(/(\d+)\s*soal/i) || [])[1]) || undefined;
      if (m) { $('#pilih-mapel').value = m.id; return mulaiLatihan({ mapel_id: m.id, jumlah: n }); }
    }
    if (/^tryout\b/i.test(pesan)) return lihatTryout();

    const t = mengetik();
    try {
      const { balasan } = await T.post('chat', { pesan, riwayat: state.riwayatChat, soal_id: state.soalAktifId || undefined });
      t.remove();
      bot(T.teks(balasan));
      state.riwayatChat.push({ role: 'user', content: pesan }, { role: 'assistant', content: balasan });
      state.riwayatChat = state.riwayatChat.slice(-10);
    } catch (err) { t.remove(); bot(T.esc(err.message)); }
  });

  $('#btn-mulai').onclick = () => mulaiLatihan();
  $('#btn-tryout').onclick = lihatTryout;
  $('#btn-pilihan').onclick = tampilkanPilihMapel;
  $('#pilih-mapel').onchange = muatTopik;

  init();
})();
