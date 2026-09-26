/* Panel admin modul TKA */
(async function () {
  const T = window.TKA, A = T.admin, $ = (s) => document.querySelector(s), esc = T.esc;
  const st = { mapel: [], page: 1, terpilih: new Set(), soalCache: new Map(), editId: null };

  // Pastikan admin (sesi Supabase Auth yang sama dengan login Dashboard Admin)
  try {
    const m = await A.get('mapel');
    st.mapel = m.mapel;
  } catch (e) {
    if (e.status === 401) {
      document.body.innerHTML = `<p style="padding:24px">Silakan <a href="${window.TKA_CONFIG.halamanUtama}">login sebagai admin</a> dulu di halaman utama, lalu buka halaman ini lagi.</p>`;
    } else {
      document.body.innerHTML = `<p style="padding:24px">${esc(e.message)}</p>`;
    }
    return;
  }

  const opsiMapel = (kosong) => (kosong ? `<option value="">${kosong}</option>` : '') + st.mapel.map((m) => `<option value="${m.id}">${esc(m.nama)}</option>`).join('');
  $('#f-mapel').innerHTML = opsiMapel('Semua mapel');
  $('#g-mapel').innerHTML = opsiMapel();
  $('#p-mapel').innerHTML = opsiMapel('Acak dari mapel siswa');
  $('#ed-mapel').innerHTML = opsiMapel();

  // Tabs
  const loader = { dashboard: muatDashboard, soal: muatSoal, popup: muatPopup, laporan: muatLaporan, tryout: muatTryout, generate: () => {} };
  $('#tabs').onclick = (e) => {
    const b = e.target.closest('button'); if (!b) return;
    document.querySelectorAll('#tabs button').forEach((x) => x.classList.toggle('aktif', x === b));
    document.querySelectorAll('[data-panel]').forEach((p) => (p.hidden = p.dataset.panel !== b.dataset.tab));
    loader[b.dataset.tab]();
  };
  const gagal = (el, e) => { el.innerHTML = `<tr><td colspan="9">${esc(e.message)}</td></tr>`; };

  // ---------------- Dashboard ----------------
  async function muatDashboard() {
    try {
      const d = await A.get('dashboard');
      const r = d.ringkasan;
      const kartu = [
        ['Siswa terdaftar', r.siswa], ['Aktif 7 hari', r.siswa_aktif_7_hari], ['Soal valid', r.soal_valid],
        ['Soal draf', r.soal_draf], ['Laporan baru', r.laporan_baru], ['Panggilan AI hari ini', r.ai_hari_ini.panggilan],
      ];
      $('#dash-kartu').innerHTML = kartu.map(([l, v]) => `<div class="tka-kartu"><strong>${v ?? 0}</strong><span>${l}</span></div>`).join('');
      $('#dash-topik').innerHTML = d.topik_terlemah.map((t) => `<tr><td>${esc(t.mapel)}</td><td>${esc(t.topik)}</td><td class="kanan">${t.dijawab}</td><td class="kanan">${t.persen_benar}%</td><td class="kanan">${t.jumlah_siswa}</td></tr>`).join('') || '<tr><td colspan="5">Belum ada data.</td></tr>';
      $('#dash-popup').innerHTML = d.popup_14_hari.map((p) => `<tr><td>${p.tanggal}</td><td class="kanan">${p.tampil}</td><td class="kanan">${p.dijawab}</td><td class="kanan">${p.mulai_latihan}</td><td class="kanan">${p.ditutup}</td></tr>`).join('') || '<tr><td colspan="5">Belum ada data.</td></tr>';
    } catch (e) { $('#dash-kartu').textContent = e.message; }
  }

  // ---------------- Bank soal ----------------
  async function muatSoal() {
    const el = $('#daftar-soal');
    el.textContent = 'Memuat...';
    try {
      const d = await A.get('soal', { status: $('#f-status').value, mapel_id: $('#f-mapel').value, q: $('#f-q').value.trim(), page: st.page });
      d.soal.forEach((s) => st.soalCache.set(s.id, s));
      el.innerHTML = d.soal.length ? `<table class="tka-tabel"><thead><tr><th></th><th>Mapel</th><th>Topik</th><th>Soal</th><th>Bentuk</th><th>Status</th><th>Sumber</th><th></th></tr></thead><tbody>${d.soal.map((s) => `
        <tr><td><input type="checkbox" data-pilih="${s.id}" ${st.terpilih.has(s.id) ? 'checked' : ''}></td>
        <td>${esc(s.mapel?.nama)}</td><td>${esc(s.topik)}</td><td>${esc(s.pertanyaan.slice(0, 90))}${s.pertanyaan.length > 90 ? '…' : ''}</td>
        <td>${s.bentuk}</td><td><span class="tka-chip tka-st-${s.status}">${s.status}</span>${s.soal_harian ? ' <span class="tka-chip">harian</span>' : ''}</td>
        <td>${s.sumber}</td><td><button class="tka-btn" data-edit="${s.id}">Periksa</button></td></tr>`).join('')}</tbody></table>` : '<p>Tidak ada soal.</p>';
      const hal = Math.ceil(d.total / d.per) || 1;
      $('#paging').innerHTML = `<span class="tka-catatan">${d.total} soal · hal ${d.page}/${hal}</span>` +
        (d.page > 1 ? '<button class="tka-btn" data-hal="-1">‹ Sebelumnya</button>' : '') +
        (d.page < hal ? '<button class="tka-btn" data-hal="1">Berikutnya ›</button>' : '');
    } catch (e) { el.textContent = e.message; }
  }
  $('#btn-cari').onclick = () => { st.page = 1; muatSoal(); };
  $('#paging').onclick = (e) => { const b = e.target.closest('[data-hal]'); if (b) { st.page += Number(b.dataset.hal); muatSoal(); } };
  $('#daftar-soal').onclick = (e) => {
    const c = e.target.closest('[data-pilih]');
    if (c) { c.checked ? st.terpilih.add(c.dataset.pilih) : st.terpilih.delete(c.dataset.pilih); return; }
    const b = e.target.closest('[data-edit]');
    if (b) bukaEditor(st.soalCache.get(b.dataset.edit));
  };

  async function ubahStatusTerpilih(status) {
    if (!st.terpilih.size) return alert('Pilih soal dulu.');
    await A.post('validasi', { ids: [...st.terpilih], status });
    st.terpilih.clear(); muatSoal();
  }
  $('#btn-valid-terpilih').onclick = () => ubahStatusTerpilih('valid');
  $('#btn-arsip-terpilih').onclick = () => ubahStatusTerpilih('arsip');
  $('#btn-tryout-terpilih').onclick = async () => {
    const ids = [...st.terpilih];
    if (!ids.length) return alert('Pilih soal valid dulu.');
    const s0 = st.soalCache.get(ids[0]);
    const judul = prompt('Judul tryout:', `Tryout ${s0?.mapel?.nama || ''}`);
    if (!judul) return;
    const durasi = Number(prompt('Durasi (menit):', '60')) || 60;
    const dibuka = prompt('Dibuka (YYYY-MM-DD HH:MM):', new Date().toISOString().slice(0, 16).replace('T', ' '));
    const ditutup = prompt('Ditutup (YYYY-MM-DD HH:MM):', dibuka);
    const iso = (s) => new Date(s.replace(' ', 'T') + ':00+07:00').toISOString();
    try {
      await A.post('tryout', { mapel_id: s0.mapel_id, judul, durasi_menit: durasi, dibuka_at: iso(dibuka), ditutup_at: iso(ditutup), soal_ids: ids });
      alert('Tryout dibuat.'); st.terpilih.clear(); muatSoal();
    } catch (e) { alert(e.message); }
  };

  // Editor
  const f = (id) => $(`#ed-${id}`);
  function bukaEditor(s) {
    st.editId = s?.id || null;
    $('#ed-judul').textContent = s ? 'Periksa / ubah soal' : 'Soal baru';
    f('mapel').value = s?.mapel_id || $('#f-mapel').value || st.mapel[0]?.id;
    f('topik').value = s?.topik || ''; f('subtopik').value = s?.subtopik || '';
    f('kesulitan').value = s?.kesulitan || 'sedang'; f('bentuk').value = s?.bentuk || 'pg';
    f('status').value = s?.status || 'draf'; f('stimulus').value = s?.stimulus || '';
    f('pertanyaan').value = s?.pertanyaan || '';
    f('opsi').value = JSON.stringify(s?.opsi || [{ id: 'A', teks: '' }, { id: 'B', teks: '' }, { id: 'C', teks: '' }, { id: 'D', teks: '' }, { id: 'E', teks: '' }], null, 1);
    f('kunci').value = JSON.stringify(s?.kunci || ['A']);
    f('pembahasan').value = s?.pembahasan || ''; f('harian').checked = Boolean(s?.soal_harian);
    $('#ed-status-msg').textContent = '';
    $('#editor').hidden = false;
  }
  $('#btn-soal-baru').onclick = () => bukaEditor(null);
  document.querySelector('[data-tutup-editor]').onclick = () => ($('#editor').hidden = true);
  $('#btn-simpan-soal').onclick = async () => {
    let opsi, kunci;
    try { opsi = JSON.parse(f('opsi').value); kunci = JSON.parse(f('kunci').value); }
    catch { $('#ed-status-msg').textContent = 'Opsi/kunci bukan JSON yang valid.'; return; }
    const data = {
      mapel_id: Number(f('mapel').value), topik: f('topik').value.trim(), subtopik: f('subtopik').value.trim() || null,
      kesulitan: f('kesulitan').value, bentuk: f('bentuk').value, status: f('status').value,
      stimulus: f('stimulus').value.trim() || null, pertanyaan: f('pertanyaan').value.trim(),
      opsi, kunci, pembahasan: f('pembahasan').value.trim() || null, soal_harian: f('harian').checked,
    };
    try {
      if (st.editId) await A.put('soal', { id: st.editId, ...data }); else await A.post('soal', data);
      $('#editor').hidden = true; muatSoal();
    } catch (e) { $('#ed-status-msg').textContent = e.message; }
  };

  // ---------------- Generate AI ----------------
  $('#btn-generate').onclick = async () => {
    const b = $('#btn-generate'); b.disabled = true; $('#g-hasil').textContent = 'AI sedang menyusun soal (±20–40 detik)...';
    try {
      const r = await A.post('generate', {
        mapel_id: Number($('#g-mapel').value), topik: $('#g-topik').value.trim(), kesulitan: $('#g-kesulitan').value,
        bentuk: $('#g-bentuk').value, jumlah: Number($('#g-jumlah').value), catatan: $('#g-catatan').value.trim(),
      });
      $('#g-hasil').innerHTML = `${r.dibuat} draf dibuat. ${r.gagal.length ? `${r.gagal.length} ditolak karena format tidak valid.` : ''} ${esc(r.pesan)}`;
    } catch (e) { $('#g-hasil').textContent = e.message; }
    b.disabled = false;
  };

  // ---------------- Pop-up ----------------
  async function muatPopup() {
    const p = await A.get('popup');
    $('#p-aktif').checked = p.aktif; $('#p-judul').value = p.judul;
    $('#p-mulai').value = p.tanggal_mulai || ''; $('#p-selesai').value = p.tanggal_selesai || ''; $('#p-tka').value = p.tanggal_tka || '';
    $('#p-angkatan').value = (p.target_angkatan || []).join(', ');
    $('#p-mapel').value = p.mapel_harian_id || '';
    $('#p-pesan').value = (p.pesan || []).join('\n');
  }
  $('#btn-simpan-popup').onclick = async () => {
    const angk = $('#p-angkatan').value.split(',').map((x) => Number(x.trim())).filter(Boolean);
    try {
      await A.put('popup', {
        aktif: $('#p-aktif').checked, judul: $('#p-judul').value.trim(),
        tanggal_mulai: $('#p-mulai').value || null, tanggal_selesai: $('#p-selesai').value || null, tanggal_tka: $('#p-tka').value || null,
        target_angkatan: angk.length ? angk : null, mapel_harian_id: $('#p-mapel').value ? Number($('#p-mapel').value) : null,
        pesan: $('#p-pesan').value.split('\n').map((x) => x.trim()).filter(Boolean),
      });
      $('#p-status').textContent = 'Tersimpan.';
    } catch (e) { $('#p-status').textContent = e.message; }
  };

  // ---------------- Laporan ----------------
  async function muatLaporan() {
    const el = $('#daftar-laporan');
    try {
      const { laporan } = await A.get('laporan');
      el.innerHTML = laporan.map((l) => `<tr>
        <td>${new Date(l.created_at).toLocaleString('id-ID')}</td><td>${esc(l.pengguna?.nama)} ${esc(l.pengguna?.kelas || '')}</td>
        <td>${esc(l.soal?.pertanyaan?.slice(0, 70))} <button class="tka-btn" data-buka="${l.soal_id}">Buka</button></td>
        <td>${esc(l.alasan)}</td>
        <td><select class="tka-input" data-lap="${l.id}">${['baru', 'ditinjau', 'diperbaiki', 'ditolak'].map((s) => `<option ${s === l.status ? 'selected' : ''}>${s}</option>`).join('')}</select></td>
        <td></td></tr>`).join('') || '<tr><td colspan="6">Tidak ada laporan.</td></tr>';
    } catch (e) { gagal(el, e); }
  }
  $('#daftar-laporan').onchange = async (e) => {
    const s = e.target.closest('[data-lap]'); if (s) await A.put('laporan', { id: s.dataset.lap, status: s.value });
  };
  $('#daftar-laporan').onclick = async (e) => {
    const b = e.target.closest('[data-buka]'); if (!b) return;
    const d = await A.get('soal', { id: b.dataset.buka });
    if (d.soal[0]) { st.soalCache.set(d.soal[0].id, d.soal[0]); bukaEditor(d.soal[0]); } else alert('Soal tidak ditemukan.');
  };

  // ---------------- Tryout & periode ----------------
  async function muatTryout() {
    try {
      const { tryout } = await A.get('tryout');
      $('#daftar-tryout').innerHTML = tryout.map((t) => `<tr><td>${esc(t.judul)}</td><td>${esc(t.mapel?.nama)}</td><td>${t.durasi_menit} mnt</td><td>${new Date(t.dibuka_at).toLocaleString('id-ID')}</td><td>${new Date(t.ditutup_at).toLocaleString('id-ID')}</td></tr>`).join('') || '<tr><td colspan="5">Belum ada tryout.</td></tr>';
      const { periode } = await A.get('periode');
      $('#daftar-periode').innerHTML = periode.map((p) => `<tr><td>${esc(p.nama)}</td><td>${p.mulai}</td><td>${p.selesai}</td><td>${p.aktif ? 'Ya' : ''}</td></tr>`).join('') || '<tr><td colspan="4">Belum ada periode.</td></tr>';
    } catch (e) { gagal($('#daftar-tryout'), e); }
  }
  $('#btn-periode').onclick = async () => {
    try {
      await A.post('periode', { nama: $('#pr-nama').value.trim(), mulai: $('#pr-mulai').value, selesai: $('#pr-selesai').value, aktif: $('#pr-aktif').checked });
      muatTryout();
    } catch (e) { alert(e.message); }
  };

  muatDashboard();
})();
