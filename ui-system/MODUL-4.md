# Modul 4 - Web Client dan Offline Capability (PWA)

Implementasi melanjutkan dashboard Modul 3: tiga sensor Q2.1, Q2.2, Q2.3, warna yang sudah dipilih, dan tombol detail/ringkas tetap tersedia. Data masih simulasi BFF di `src/App.jsx`, belum pembacaan API atau perangkat IoT.

## Menjalankan aplikasi

Dari folder utama proyek:

```powershell
cd ui-system
npm.cmd install
npm.cmd run build
npm.cmd run preview
```

Buka `http://localhost:4173` sekali saat online dan tunggu service worker aktif. Setelah aset tersimpan, halaman dapat di-refresh dan dibuka kembali saat offline. Pemasangan aplikasi dapat dilakukan melalui menu Install di Chrome atau Edge dengan profil normal. Akses pertama tanpa cache tetap membutuhkan jaringan. Untuk hosting di luar localhost, gunakan HTTPS dan sajikan isi `dist` dari root domain.

`npm.cmd run dev` digunakan untuk pengembangan UI saja. Service worker tidak diaktifkan pada mode development agar cache tidak mengganggu perubahan kode.

## Implementasi

| Bagian modul | Implementasi proyek |
| --- | --- |
| Plugin PWA | `vite-plugin-pwa` menjadi dev dependency frontend `ui-system`, dengan `registerType: 'autoUpdate'` |
| Manifest | Nama SensorNodes, `start_url: '/'`, `scope: '/'`, `display: 'standalone'`, bahasa Indonesia |
| Design system | Warna manifest dan meta `theme-color` dibaca dari `tech.primary` di `tailwind.config.js`; latar dari `tech.bg` |
| Ikon | PNG 192 dan 512 piksel, ikon maskable 512 piksel dengan latar penuh/area aman, SVG favicon, Apple touch icon 180 piksel |
| Registrasi service worker | `src/main.jsx` menggunakan `virtual:pwa-register`; plugin otomatis mendeteksinya sehingga tidak terjadi registrasi ganda |
| Cache aset | Workbox melakukan precache HTML, JavaScript, CSS, dan ikon; navigation fallback ke `index.html`; cache lama dibersihkan saat pembaruan |
| Deteksi jaringan | `src/hooks/useNetworkStatus.js` menggunakan `navigator.onLine`, event online/offline, serta cleanup listener |
| UX offline | Banner merah dan badge Offline; banner hilang saat koneksi pulih; tombol detail/ringkas tetap bekerja |

Registrasi virtual menggantikan contoh script manual `/sw.js` di PDF. Jangan menambahkan script manual lagi di `index.html`. Saat build, plugin menghasilkan manifest, service worker, dan kode registrasi produksi.

Data contoh berada di bundle JavaScript yang dicache. Belum ada runtime cache API atau sinkronisasi backend. Status Online menunjukkan koneksi jaringan browser, bukan bukti bahwa server BFF dapat dihubungi.

## Pengujian manual

1. Jalankan build dan preview, lalu buka URL preview saat online.
2. Buka DevTools > Application > Manifest untuk memeriksa identitas dan ikon.
3. Di Application > Service Workers, tunggu status activated/running. Pastikan **Bypass for network** tidak aktif. Cache Storage harus berisi aset aplikasi.
4. Aktifkan **Offline** pada Service Workers atau Network > throttling. Banner harus menampilkan "Anda sedang offline. Menampilkan data dari cache lokal."
5. Refresh halaman. Ketiga kartu, CSS, dan tombol detail/ringkas harus tetap bekerja.
6. Kembalikan jaringan ke online. Banner harus hilang dan badge kembali menjadi Online.

## Pengujian otomatis

Dari `ui-system`, dengan Microsoft Edge terpasang:

```powershell
npm.cmd run lint
npm.cmd run test:pwa
```

Tes membangun versi produksi dan menjalankan preview sendiri pada port 4173; hentikan preview manual sebelum menjalankannya. Empat pengujian mencakup manifest/ikon/installability dan alur offline pada desktop 1280 px serta mobile 390 px. Pengujian mematikan jaringan browser, melakukan reload, membuka tab baru saat offline, mencoba tombol, memeriksa cache dan overflow, lalu menyambungkan kembali jaringan. Screenshot dan bukti JSON disimpan ke `../output/modul-4/`.

Context Playwright memakai mode incognito, sehingga pengujian installability mengabaikan hanya pembatasan `in-incognito`. Kesalahan manifest, ikon, atau HTTPS tetap menggagalkan tes. Uji pemasangan melalui UI memakai profil browser normal.

Jika Edge tidak tersedia, jalankan `npx.cmd playwright install chromium`, lalu di PowerShell tetapkan `$env:PWA_BROWSER = 'chromium'` sebelum menjalankan tes.

## Audit Lighthouse

Kategori **Progressive Web App** telah dihapus mulai Lighthouse 12 ([catatan rilis resmi](https://github.com/GoogleChrome/lighthouse/releases/tag/v12.0.0)). Karena modul meminta laporan kategori tersebut, gunakan Lighthouse **11.7.1** sebagai audit kompatibilitas modul. Hasil versi ini bukan skor PWA dari Lighthouse terbaru. Uji offline aktual tetap dilakukan oleh Playwright.

Dengan preview sudah berjalan, jalankan dari `ui-system`:

```powershell
$env:CHROME_PATH = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
npx.cmd --yes lighthouse@11.7.1 http://localhost:4173 --only-categories=pwa --chrome-flags="--headless=new" --output=html --output=json --output-path=../output/modul-4/lighthouse-pwa
```

Gunakan path Chrome/Edge yang sesuai komputer Anda. Laporan HTML dapat dibuka langsung di browser. Pemeriksaan manual pada laporan, seperti alur antarbrowser dan perangkat fisik, tetap membutuhkan pemeriksaan pengguna.

## Berkas pengumpulan

Bukti pengujian: build dan lint lulus, 4/4 tes browser lulus, serta skor Lighthouse PWA 11.7.1 sebesar **100/100**. Rincian dan batas pengujian ada di [hasil pengujian](../output/modul-4/HASIL-PENGUJIAN.md).

Bukti pengujian berada di `../output/modul-4/`:

- `offline-desktop.png`: dashboard desktop setelah refresh dengan jaringan browser dimatikan.
- `offline-mobile.png`: tampilan mobile full-page dalam kondisi offline yang sama.
- `offline-desktop.json` dan `offline-mobile.json`: hasil pemeriksaan offline, versi browser, waktu pengujian, dan daftar cache.
- `lighthouse-pwa.report.html` dan `lighthouse-pwa.report.json`: laporan asli Lighthouse 11.7.1.

Sertakan bukti tersebut bersama source `ui-system` (tanpa `node_modules`) untuk pengumpulan. Screenshot memperlihatkan data simulasi, bukan pembacaan sensor langsung.

Referensi implementasi: [dokumentasi Vite PWA](https://vite-pwa-org.netlify.app/guide/) dan Modul 4 yang diberikan pengguna.
