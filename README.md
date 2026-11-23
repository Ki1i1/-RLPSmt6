# Modular System - Modul 6

SensorNodes menghubungkan dashboard React di `ui-system` dan aplikasi Flutter di `iot_mobile_app` ke Backend for Frontend (BFF) NestJS.

## Menjalankan ketiga aplikasi

1. Buka terminal di folder utama untuk menjalankan NestJS.

   ```powershell
   npm.cmd install
   npm.cmd run start:dev
   ```

2. Buka terminal baru di folder utama untuk menjalankan React, lalu buka `http://localhost:5173`.

   ```powershell
   cd ui-system
   npm.cmd install
   npm.cmd run dev
   ```

3. Buka terminal ketiga di folder utama untuk menjalankan Flutter. Ganti `edge` dengan `chrome` untuk Chrome atau gunakan ID emulator Android dari `flutter devices`.

   ```powershell
   cd iot_mobile_app
   flutter pub get
   flutter run -d edge
   ```

Kedua dashboard memuat data saat dibuka. Gunakan tombol **Refresh dari API** untuk meminta pembacaan terbaru. BFF berjalan pada `http://localhost:3000` secara default. Flutter menggunakan `http://10.0.2.2:3000` untuk emulator Android agar dapat mengakses host.

Jika alamat backend berubah, atur `VITE_API_BASE_URL` saat menjalankan atau membangun React. Untuk Flutter, tambahkan `--dart-define=API_BASE_URL=https://api.example.com` pada perintah `flutter run` atau `flutter build`.

NestJS mengizinkan semua origin selama pengembangan. Untuk membatasi CORS, isi `CORS_ORIGINS` dengan daftar origin lengkap yang dipisahkan koma. Pada `NODE_ENV=production`, origin lintas situs perlu terdaftar secara eksplisit. Gunakan API HTTPS jika dashboard web juga disajikan melalui HTTPS.

Contoh pengaturan untuk React dan Flutter Web dengan port tetap 8080

```powershell
$env:CORS_ORIGINS = 'http://localhost:5173,http://localhost:8080'
npm.cmd run start:dev
```

Jalankan Flutter Web dengan `flutter run -d edge --web-port=8080` agar origin sesuai dengan daftar tersebut.

Backend menyediakan lima pembacaan sensor simulasi dan satu status lampu dari memori. React menampilkan status lampu dan kecerahan. Switch Flutter menampilkan status yang sama dari endpoint GET. Saat koneksi terputus, PWA menampilkan data terakhir yang berhasil dimuat atau data contoh lokal. [Panduan PWA Modul 4](ui-system/MODUL-4.md)

## Implementasi bagian 3 dan tugas lampu

| Bagian | Alur data |
| --- | --- |
| 3A | [`SensorService`](src/sensor/sensor.service.ts) membentuk dua array dari daftar `SensorData` yang sama. Respons mobile mengirim nilai dan status ringkas. Respons web mengirim nama perangkat, pembacaan, baterai, dan timestamp ISO. |
| 3B | [Bootstrap NestJS](src/main.ts) menangani preflight CORS dan mencatat status HTTP setelah server merespons permintaan. |
| 3C | [Klien Axios](ui-system/src/api/dashboard.js) mengambil sensor dan lampu. [Dashboard React](ui-system/src/App.jsx) merender daftar dengan `id` sebagai kunci kartu. |
| 3D | [ApiService Flutter](iot_mobile_app/lib/services/api_service.dart) membaca `/sensor/mobile/dashboard` dan mendekode JSON sebagai UTF-8. [SensorProvider](iot_mobile_app/lib/providers/sensor_provider.dart) mengubah nilai JSON numerik menjadi `double`, memetakan `WARN` ke `WARNING`, dan memberi tahu widget saat pemuatan selesai. |
| 5 | Kedua klien membaca status dari BFF. React menampilkan `isOn` dan `brightness`. Flutter menampilkan `isOn` pada switch baca-saja karena kontrak praktikum menggunakan GET. |

## Struktur layer

```text
src/
  sensor/
    domain/
      sensor.entity.ts
    infrastructure/
      sensor.controller.ts
    sensor.service.ts
    sensor.module.ts
  light-control/
    domain/
      light-status.entity.ts
    application/
      light-control.service.ts
    infrastructure/
      light-control.controller.ts
    light-control.module.ts
```

Entity menggunakan TypeScript murni. Service sensor berfungsi sebagai application layer sesuai struktur bagian D. Service melakukan transformasi BFF, controller meneruskan permintaan HTTP ke service, dan module menghubungkan dependensinya. Tugas lampu menggunakan folder `application` tersendiri sesuai instruksi tambahan modul.

## Endpoint dan contoh respons

Semua endpoint menggunakan metode GET dan dapat dibuka di browser, Postman, atau Insomnia.

| Endpoint                   | Kebutuhan                            |
| -------------------------- | ------------------------------------ |
| `/sensor/mobile/dashboard` | Daftar ringkasan sensor untuk mobile |
| `/sensor/web/analytics`    | Daftar detail sensor untuk web       |
| `/light-control/mobile`    | Status lampu untuk mobile            |
| `/light-control/web`       | Status dan kecerahan lampu untuk web |

### Sensor mobile (contoh satu item)

```json
[{ "id": "S1", "v": 28.5, "u": "°C", "st": "OK", "batt": "GOOD" }]
```

### Sensor web (contoh satu item)

```json
[
  {
    "id": "S1",
    "deviceName": "DHT22-V2",
    "reading": { "current": 28.5, "unit": "°C", "isOptimal": true },
    "status": { "battery": "85%", "lastSeen": "2026-10-19T00:00:00.000Z" }
  }
]
```

`lastSeen` di atas hanya contoh format ISO; nilainya mengikuti waktu inisialisasi service.

### Lampu mobile

```json
{ "isOn": true }
```

### Lampu web

```json
{ "isOn": true, "brightness": 75 }
```

## Verifikasi praktikum

```powershell
npm.cmd run build
npm.cmd test -- --runInBand
npm.cmd run test:e2e -- --runInBand
npm.cmd run lint
```

Pengujian backend memeriksa kontrak keempat endpoint, kesesuaian data sensor lintas klien, timestamp ISO, batas normal domain 10–30, dan baterai kritis di bawah 20. Jalankan `npm.cmd run test:pwa` di `ui-system` serta `flutter analyze` dan `flutter test` di `iot_mobile_app` untuk memeriksa klien.

Saat kedua dashboard dibuka, terminal NestJS mencatat metode, rute, status HTTP, dan waktu respons untuk permintaan web serta mobile. Pembacaan pertama di React dan Flutter harus sama-sama menunjukkan 28,5 °C. Lampu harus tampil ON di kedua aplikasi dengan kecerahan 75% di React.

Bukti pengujian menggunakan React dan Flutter Web di Edge. Keempat endpoint mengembalikan HTTP 200 saat aplikasi dibuka dan setelah tombol refresh ditekan. [Tangkapan layar kedua dashboard](output/modul-6/dashboard-web-mobile.png) · [Cuplikan log NestJS](output/modul-6/terminal-nestjs.png) · [Log teks](output/modul-6/terminal-nestjs.txt)
