# SensorNodes - Modul 3

Prototipe Dashboard Monitoring Suhu dengan React, Vite, dan Tailwind CSS v3. Implementasi dimulai dari bagian **3. Pembuatan Reusable Component: StatusCard.jsx** sampai tugas akhir dashboard.

## Menjalankan frontend

Dari folder utama `modular-system`:

```powershell
cd ui-system
npm.cmd install
npm.cmd run dev
```

Buka URL Local yang ditampilkan Vite, biasanya `http://localhost:5173`. Backend NestJS tidak perlu berjalan untuk prototipe ini. Data di `src/App.jsx` adalah simulasi BFF, belum diambil dari API atau perangkat IoT. Status pada data simulasi disediakan secara eksplisit untuk menguji tiga variasi visual.

## Struktur dan persyaratan modul

```text
src/
  components/
    StatusCard.jsx
    PrimaryButton.jsx
  App.jsx
  index.css
tailwind.config.js
postcss.config.js
```

- `StatusCard` menerima `title`, `value`, dan `status` sesuai tugas akhir; juga mendukung `label`, `unit`, dan `isCompact` dari contoh komponen pada modul.
- Dashboard menampilkan tiga kartu suhu dan satu `PrimaryButton` yang mengubah tampilan detail/ringkas.
- Grid menggunakan satu kolom di bawah 768 px, dua kolom mulai 768 px, dan tiga kolom mulai 1024 px.
- Token `tech.primary`, `tech.warning`, `tech.danger`, dan `tech.bg` terpusat di konfigurasi Tailwind. Alias `brand.warning` memakai nilai `tech.warning` yang sama.
- `p-safe-area` dan `p-safe-pad` sama-sama menggunakan padding 1.25rem, mengikuti contoh dan tugas akhir modul.
- Status tidak hanya dibedakan berdasarkan warna: setiap kartu juga menampilkan label Normal, Peringatan, Kritis, atau Belum diketahui.

## Menggunakan kembali StatusCard

```jsx
import StatusCard from './components/StatusCard'

<StatusCard
  title="Suhu Ruangan"
  value={24.5}
  unit="°C"
  status="OK"
  isCompact={false}
/>
```

| Prop | Perilaku |
| --- | --- |
| `title` / `label` | Judul kartu; `title` diprioritaskan jika keduanya diisi |
| `value` | Nilai sensor; nilai yang belum tersedia ditampilkan sebagai tanda em dash |
| `unit` | Satuan opsional, misalnya °C, hPa, atau % |
| `status` | `OK`, `WARNING`, atau `DANGER`; `WARN` dari Modul 2 menjadi alias `WARNING` |
| `isCompact` | `true` menyembunyikan bagian integrity status; nilai dan badge tetap terlihat |

Status yang tidak dikenal menggunakan tampilan netral, bukan mengklaim sensor normal.

## Pengujian praktikum

```powershell
npm.cmd run build
npm.cmd run lint
```

1. Jalankan frontend, buka DevTools browser, lalu aktifkan Device Mode (`Ctrl+Shift+M` pada Chrome/Edge).
2. Coba lebar 390 px (mobile), 820 px (tablet), dan 1280 px (desktop). Pastikan grid berubah dari satu ke dua dan tiga kolom, tanpa scroll horizontal.
3. Klik **Gunakan tampilan ringkas**: bagian integrity status hilang dari ketiga kartu. Klik **Tampilkan detail** untuk mengembalikannya. Tombol juga dapat dioperasikan dengan keyboard.
4. Ubah `techColors.primary` di `tailwind.config.js`, misalnya menjadi `#8b5cf6`. Aksen header, kartu normal, dan tombol mengikuti token baru. Kartu peringatan/kritis tetap mengikuti token status masing-masing. Kembalikan nilai setelah pengujian.
5. Untuk menguji satu kartu secara terpisah, gunakan `isCompact={true}` hanya pada kartu tersebut.

### Analisis tampilan ringkas

Tampilan ringkas mengurangi detail visual sehingga nilai dan status lebih cepat dibaca teknisi di lapangan atau pada layar kecil. Tampilan detail memudahkan pemilik dashboard memeriksa informasi tambahan. Namun, `isCompact` sendiri hanya mengubah tampilan; penghematan bandwidth memerlukan payload BFF mobile yang lebih kecil, seperti endpoint mobile pada Modul 2.

## Berkas pengumpulan

Konfigurasi Tailwind dan kedua komponen sudah tersedia di proyek ini. Ambil screenshot dari aplikasi yang berjalan:

- `desktop.png`: lebar 1280 px atau lebih, memperlihatkan tiga kartu sejajar dan tombol.
- `mobile.png`: lebar 390 px, memperlihatkan susunan kartu dalam satu kolom; gunakan full-page screenshot bila diperlukan.

Sertakan screenshot tersebut bersama source proyek dalam ZIP untuk pengumpulan. Screenshot belum disertakan karena browser pratinjau tidak tersedia di sesi pengerjaan otomatis.
