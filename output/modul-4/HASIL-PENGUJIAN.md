# Hasil Pengujian Modul 4

Tanggal: 2 November 2026 (WIB). Aplikasi diuji dari build produksi Vite pada `http://localhost:4173`.

## Hasil

| Pemeriksaan | Hasil |
| --- | --- |
| Build frontend + pembuatan manifest/service worker | Lulus |
| ESLint frontend | Lulus |
| Tes browser Playwright | 4/4 lulus |
| Manifest, ukuran ikon, warna tema, dan persyaratan instalasi | Lulus pada desktop dan mobile |
| Refresh halaman dengan jaringan browser dimatikan | Lulus pada desktop dan mobile |
| Membuka tab baru saat offline | Lulus pada desktop dan mobile |
| Tombol detail/ringkas saat offline | Lulus pada desktop dan mobile |
| Kembali online | Banner hilang, indikator Online, dashboard dapat dimuat ulang |
| Tampilan 1280 px dan 390 px | Tidak ada overflow horizontal |
| Lighthouse 11.7.1, kategori PWA | **100/100**; tidak ada runtime error atau peringatan audit |

## Bukti

- [Screenshot desktop offline](offline-desktop.png)
- [Screenshot mobile offline](offline-mobile.png)
- [Hasil tes desktop](offline-desktop.json)
- [Hasil tes mobile](offline-mobile.json)
- [Laporan Lighthouse HTML](lighthouse-pwa.report.html)
- [Laporan Lighthouse JSON](lighthouse-pwa.report.json)

Screenshot diambil setelah reload dengan `navigator.onLine === false`. Pengujian mematikan jaringan context browser secara nyata, bukan sekadar mengganti badge atau mengirim event offline buatan. Aset diambil dari service worker/Cache Storage.

Lighthouse **11.7.1** dipakai untuk memenuhi format tugas karena [kategori PWA telah dihapus sejak Lighthouse 12](https://github.com/GoogleChrome/lighthouse/releases/tag/v12.0.0). Enam audit otomatis pada laporan lulus; tiga pemeriksaan manual pada laporan tidak diberi skor dan tidak dianggap telah diuji oleh Lighthouse. Pengujian mobile memakai emulasi viewport/touch pada Edge, bukan perangkat fisik. Pemasangan aplikasi melalui UI dan pemeriksaan lintas browser belum dilakukan.

Dashboard tetap menggunakan data simulasi Modul 3. Bukti ini tidak menunjukkan koneksi ke perangkat IoT atau caching respons API. Panduan implementasi dan cara mengulang pengujian ada di [MODUL-4.md](../../ui-system/MODUL-4.md).
