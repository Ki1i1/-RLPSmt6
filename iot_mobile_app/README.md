# SensorNodes Controller - Modul 5

Aplikasi Flutter untuk melanjutkan **4. Implementasi Kode Secara Rinci** dan latihan kendali lampu pada Modul 5. Proyek ini terpisah dari backend NestJS dan frontend React/PWA `ui-system`.

## Menjalankan aplikasi

Dari folder utama repository:

```powershell
cd iot_mobile_app
flutter pub get
flutter run -d edge
```

Untuk Chrome gunakan `flutter run -d chrome`, atau Windows desktop gunakan `flutter run -d windows`. Proyek dibuat dan diuji dengan Flutter 3.47.7 / Dart 3.13.5; dependency Provider dikunci melalui `pubspec.lock`.

Untuk Android:

```powershell
flutter emulators
flutter emulators --launch flutter_emulator
flutter devices
flutter run -d emulator-5554
```

Ganti nama emulator dan ID perangkat sesuai hasil perintah. Emulator juga dapat dibuka melalui Android Studio. Untuk perangkat fisik, aktifkan USB debugging dan gunakan ID perangkat tersebut. Target iOS disediakan, tetapi build dan menjalankannya memerlukan macOS + Xcode.

Jika Flutter tidak ditemukan di terminal Windows ini, gunakan path SDK, misalnya `C:\flutter\bin\flutter.bat pub get`.

## Implementasi modul

| Bagian | Berkas / hasil |
| --- | --- |
| 4A - Inisialisasi dan dependency | Proyek Flutter `iot_mobile_app`, dependency `provider` |
| 4B - Shared theme | `lib/shared/theme.dart`: `AppColors` dan `AppTheme.lightTheme` |
| 4C - Application layer | `lib/providers/sensor_provider.dart`: `Sensor`, `SensorProvider`, `updateTemperature()` dan notifikasi |
| 4D - Reusable StatusCard | `lib/widgets/status_card.dart`: nilai, unit, badge, warna, integrity status, semantics |
| 4E - Main entry dan dashboard | `lib/main.dart`: `ChangeNotifierProvider`, `context.watch`, callback dengan `context.read`, `ListView` |
| 7 - Kendali lampu pintar | `_isLightOn`, `toggleLight()` dan `lib/widgets/control_card.dart` di bawah daftar sensor |

Token warna mengikuti konfigurasi web yang sudah Anda ubah di `ui-system/tailwind.config.js`: primary `#10f742`, warning `#f59e0b`, danger `#ef4444`, background `#f8fafc`. Contoh PDF memakai primary biru; implementasi ini mempertahankan identitas warna proyek Anda. Ubah `AppColors.primary` jika ingin menggantinya.

## Alur simulasi

Data awal: **S1 Ambient Temp 24.5°C (OK)** dan **S2 Core Heat 30.2°C (WARNING)**. Status S2 disesuaikan dengan ambang batas; contoh PDF memberi status OK meskipun nilainya sudah di atas 30°C.

| Suhu | State | Tampilan |
| --- | --- | --- |
| ≤ 30°C | `OK` | Hijau / Normal |
| > 30°C sampai 40°C | `WARNING` | Kuning / Peringatan |
| > 40°C | `DANGER` | Merah / Kritis |

1. Tekan **SIMULASI OVERHEAT (S1)**. S1 menjadi 45.0°C, merah, dan berstatus Kritis.
2. Tekan **Simulasi peringatan (35°C)**. S1 menjadi 35.0°C dan kuning.
3. Nyalakan/matikan switch **Kendali lampu**. Label berubah ON/OFF dan ikon menguning saat ON.
4. Tekan **Reset simulasi** untuk mengembalikan kedua sensor dan mematikan lampu.

Semua perubahan melalui Provider. Daftar sensor dan model sensor tidak dapat dimutasi langsung oleh widget. Suhu NaN/infinity ditolak, ID yang tidak ditemukan diabaikan, dan pembaruan tanpa perubahan nilai tidak memicu render ulang.

Data serta status lampu hanya disimpan di memori aplikasi dan kembali ke kondisi awal setelah restart. Kendali lampu merupakan simulasi, belum terhubung ke perangkat IoT/API BFF. Batas peringatan mengikuti Modul 5 dan tidak mengubah aturan domain backend Modul 2.

## Verifikasi

```powershell
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

Tes Provider memeriksa batas 30/40, isolasi sensor, input tidak valid, notifikasi, snapshot, toggle dan reset. Tes widget memeriksa tampilan awal, perubahan nilai/warna, switch lampu, reset, alias WARN, fallback status asing, serta layout 320 piksel pada skala teks 1x dan 2x.

Hasil build web berada di `build/web/`; hasil APK debug berada di `build/app/outputs/flutter-apk/app-debug.apk`. APK debug digunakan untuk pengujian lokal.

## Bukti praktikum

Bukti pengujian dan demonstrasi disimpan di [`../output/modul-5/`](../output/modul-5/): [laporan](../output/modul-5/HASIL-PENGUJIAN.md), [GIF demonstrasi](../output/modul-5/demonstrasi-modul-5.gif), dan [arsip source + bukti](../output/modul-5-mobile.zip). Analisis bersih, seluruh 15 tes lulus, serta build web dan APK debug berhasil. Android belum diuji pada emulator/perangkat fisik; target Windows dan iOS belum dibuild.

Berkas utama yang diminta modul adalah `lib/providers/sensor_provider.dart` dan `lib/main.dart`; sertakan pula folder `lib/widgets`, `lib/shared`, `pubspec.yaml`, dan `pubspec.lock` agar source dapat dijalankan.

Referensi: [Flutter simple state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple) dan [Provider](https://pub.dev/packages/provider).
