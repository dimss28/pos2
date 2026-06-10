# 01 — Setup Project + Dependencies + Folder Structure

## Goal

Project Flutter baru bernama `flutter_pos_app`, semua dependency utama sudah terpasang, dan struktur folder `lib/` sudah dibuat sesuai arsitektur layer-first + feature-first.

## Prerequisite

- Flutter 3.41+ terinstall
- Sudah membaca [`00-overview.md`](./00-overview.md)

## Konsep yang diajarkan

- **`flutter create`** — generate project Flutter standar.
- **`pubspec.yaml`** — file manifest project Flutter (mirip `package.json` di Node atau `composer.json` di PHP).
- **Dependency vs dev_dependency**: yang dipakai runtime app vs yang cuma untuk development (lint, build_runner, tests).
- **`dependency_overrides`**: pin versi child dependency yang konflik (akan dipakai untuk `url_launcher_android` dan `webview_flutter_android`).
- **Struktur folder layer-first**: `core/` untuk cross-cutting, `data/` untuk model & datasource, `presentation/` untuk feature.
- **Konvensi naming**: `snake_case` file, `PascalCase` class, suffix `Page`/`Bloc`/`Datasource`/`ResponseModel`/`RequestModel`.

---

## Prompt siap kirim ke AI

```
Saya mau bangun aplikasi Flutter POS (Point-of-Sale) dari nol bernama `flutter_pos_app`.

Tugas kamu:

1. Beri saya perintah `flutter create` lengkap dengan organization id `com.fic.flutter_pos_app` dan platform Android + iOS saja (skip web/desktop/linux/macos/windows).

2. Generate file `pubspec.yaml` lengkap dengan:
   - `name: flutter_pos_app`
   - `version: 1.0.0+1`
   - `environment: sdk: '>=3.2.0 <4.0.0'`
   - Dependencies berikut (cantumkan komentar singkat per package, pakai versi terbaru yang kompatibel):
     - `flutter_bloc: ^8.1.3` — state management
     - `freezed_annotation: ^3.0.0` — annotation buat Freezed unions
     - `dartz: ^0.10.1` — Either<L,R> untuk error handling
     - `http: ^1.1.2` — REST client
     - `shared_preferences: ^2.2.2` — key-value store
     - `flutter_secure_storage: ^9.2.4` — secure storage untuk token & QRIS server key
     - `sqflite: ^2.3.0` — SQLite lokal
     - `intl: ^0.19.0` — currency & date format ID
     - `google_fonts: ^7.0.0` — font Quicksand
     - `flutter_svg: ^2.0.9` — render SVG asset
     - `cached_network_image: ^3.3.0` — image cache (foto produk dari BE)
     - `image_picker: ^1.0.5` — ambil foto dari galeri/kamera
     - `image: ^4.2.0` — manipulasi image (compress sebelum upload)
     - `mobile_scanner: ^5.2.1` — scan QR/barcode produk
     - `qr_flutter: ^4.1.0` — render QR untuk QRIS
     - `print_bluetooth_thermal: ^1.1.6` — cetak struk Bluetooth thermal
     - `esc_pos_utils_plus: ^2.0.3` — generator ESC/POS commands
     - `widgets_to_image: ^1.0.0` — capture widget jadi image untuk dicetak/print
     - `pdf: ^3.11.1` — generate PDF (laporan + struk fallback)
     - `open_filex: ^4.7.0` — buka file PDF di app eksternal
     - `permission_handler: ^11.3.1` — permission runtime (Bluetooth, camera, storage)
     - `url_launcher: ^6.2.6` — buka URL eksternal (privacy policy)
     - `webview_flutter: ^4.7.0` — embed webview (Midtrans return URL)
     - `connectivity_plus: ^6.0.5` — deteksi online/offline
     - `fl_chart: ^0.69.0` — chart trend penjualan di Report
     - `horizontal_data_table: ^4.3.1` — table report yang scrollable horizontal
     - `badges: ^3.1.2` — number badge di icon
     - `cupertino_icons: ^1.0.2` — default

   - dev_dependencies:
     - `flutter_lints: ^4.0.0`
     - `bloc_test: ^9.1.5`
     - `mocktail: ^1.0.4`
     - `build_runner: ^2.4.7`
     - `freezed: ^3.0.0`
     - `flutter_gen_runner: ^5.3.2`

   - `dependency_overrides` (pin karena KGP/AGP conflict — wajib jangan dihilangkan):
     - `url_launcher_android: 6.3.14`
     - `webview_flutter_android: 4.4.0`

   - section `flutter_gen`:
     ```yaml
     flutter_gen:
       output: lib/core/assets/
       integrations:
         flutter_svg: true
     ```

   - section `flutter`:
     - `uses-material-design: true`
     - `assets:`
       - `assets/images/`
       - `assets/icons/`
       - `assets/logo/`

3. Buatkan struktur folder `lib/` lengkap (kosongan dengan `.gitkeep` di setiap leaf folder):

   ```
   lib/
   ├── core/
   │   ├── assets/             # flutter_gen output (auto-generated)
   │   ├── bloc/               # AppBlocObserver
   │   ├── components/         # widget atom
   │   ├── constants/          # AppColors legacy + Variables (env)
   │   ├── extensions/         # int/string/date/context
   │   ├── services/           # PrinterService
   │   └── theme/              # AppTheme, AppPalette, dll
   ├── data/
   │   ├── dataoutputs/        # cwb_print.dart (ESC/POS formatter)
   │   ├── datasources/        # remote + local
   │   └── models/
   │       ├── request/
   │       └── response/
   └── presentation/
       ├── auth/{pages,bloc}/
       ├── cash_session/{pages,widgets,bloc}/
       ├── connectivity/bloc/
       ├── dev/                # component gallery
       ├── draft_order/{pages,widgets,bloc}/
       ├── history/{pages,widgets,models,bloc}/
       ├── home/{pages,bloc,models}/
       ├── order/{pages,widgets,bloc,models}/
       ├── promo/{pages,widgets,bloc,models}/
       ├── refund/{widgets,bloc}/
       └── setting/{pages,widgets,bloc,models}/
   ```

4. Buatkan folder `assets/` di root project: `assets/images/`, `assets/icons/`, `assets/logo/` (semua dengan `.gitkeep`).

5. Replace `lib/main.dart` default dengan placeholder minimal yang cuma render `MaterialApp(home: Scaffold(body: Center(child: Text('POS Batch 11'))))` — supaya `flutter run` jalan.

6. Hapus folder `test/widget_test.dart` default karena kita akan ganti dengan test sendiri nanti.

Setelah generate, beri saya:
- Command `flutter pub get` untuk verifikasi semua dependency ter-resolve
- Command `flutter run` untuk test build
- Catatan kalau ada warning saat `pub get` (terutama soal `dependency_overrides`)
```

---

## Verifikasi

1. Jalankan `flutter pub get` — pastikan tidak ada error.
2. Jalankan `flutter run` di emulator/HP — pastikan tampil "POS Batch 11" di tengah layar.
3. `tree lib -L 3` atau buka di IDE — pastikan struktur folder cocok dengan spec.

## Talking points (untuk diajar)

1. **Kenapa `dependency_overrides` pakai versi spesifik (bukan caret)?**
   Karena `url_launcher_android` 6.3.15+ pakai Kotlin DSL `compilerOptions` yang butuh bump KGP. Pin ke 6.3.14 supaya build tetap jalan di KGP 2.0.0 / AGP 8.2. Ini contoh **dependency hell** yang sering kejadian di Flutter Android — kasih tahu peserta cara baca error build Android dan debug-nya.

2. **Kenapa folder dipisah `core/data/presentation`?**
   Layer-first memisahkan **what** (data) dari **how I show it** (presentation). `core/` adalah "infrastruktur" yang dipakai siapa saja. Ini bukan Clean Architecture full (kita skip Repository layer untuk simplicity), tapi prinsipnya sama.

3. **Kenapa banyak banget dependency?**
   Tunjuk satu per satu — peserta perlu tahu fungsi tiap library. Ini juga aksi nyata cara baca `pubspec.yaml`: gak semua project butuh semuanya, tapi POS punya banyak hardware interface (printer, scanner, camera) jadi memang berat.

4. **Versi caret (`^8.1.3`)** artinya "kompatibel dengan 8.x.y dimana 8.1.3 atau lebih baru". Pakai caret default; pin (tanpa caret) hanya kalau ada konflik.

5. **`flutter_gen_runner`** akan kita pakai di step 03 — auto-generate konstanta untuk asset (mis. `Assets.icons.qrCode.path`) supaya gak typo path string.

## Commit suggestion

```bash
git init
git add .
git commit -m "Step 01: scaffold project + dependencies + folder structure"
```

---

➡️ Lanjut ke [Step 02 — Theme Foundation](./02-theme-foundation.md)
