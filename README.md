# Modular System - Modul 2

Implementasi Clean Layering dan Backend for Frontend (BFF) menggunakan NestJS, mulai dari bagian D serta tugas Smart Home Controller.

## Menjalankan proyek

```powershell
npm.cmd install
npm.cmd run start:dev
```

Buka endpoint pada `http://localhost:3000`. Di PowerShell, gunakan `npm.cmd` jika `npm` terhalang execution policy. Di Command Prompt atau terminal lain yang mendukungnya, gunakan `npm` seperti biasa.

Data sensor dan lampu masih berupa simulasi di memory. Timestamp sensor dibuat saat service diinisialisasi, bukan pembacaan IoT secara langsung.

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
| `/sensor/mobile/dashboard` | Ringkasan sensor untuk mobile        |
| `/sensor/web/analytics`    | Detail sensor untuk dashboard web    |
| `/light-control/mobile`    | Status lampu untuk mobile            |
| `/light-control/web`       | Status dan kecerahan lampu untuk web |

### Sensor mobile

```json
{ "v": 28.5, "u": "°C", "st": "OK", "batt": "GOOD" }
```

### Sensor web

```json
{
  "id": "S001",
  "deviceName": "DHT22-V2",
  "reading": { "current": 28.5, "unit": "°C", "isOptimal": true },
  "status": { "battery": "85%", "lastSeen": "2026-10-19T00:00:00.000Z" }
}
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

Pengujian otomatis memeriksa batas suhu normal (10 sampai 40, inklusif), baterai kritis (di bawah 20), kontrak JSON seluruh endpoint, timestamp ISO, serta perubahan aturan domain yang tercermin pada respons mobile dan web.

Untuk simulasi manual:

1. Ubah suhu mock pada `src/sensor/sensor.service.ts` menjadi 45. Endpoint mobile harus menghasilkan `st: "WARN"`, sedangkan web menghasilkan `reading.isOptimal: false`.
2. Kembalikan suhu ke 28.5. Ubah batas atas `isNormal()` pada entity menjadi 25, lalu akses kembali kedua endpoint tanpa mengubah service atau controller. Hasilnya juga harus `WARN` dan `false`. Batas 25 dipilih supaya suhu contoh 28.5 melewati batas; perubahan ke 30 seperti contoh modul tetap menghasilkan status normal.
3. Kembalikan batas ke 40 setelah simulasi. Baterai mock di bawah 20 menghasilkan `batt: "LOW"` pada mobile.
4. Untuk tugas lampu, ambil screenshot struktur folder di VS Code dan respons JSON `/light-control/mobile` serta `/light-control/web` di Postman/Insomnia sebagai bukti pengumpulan.
