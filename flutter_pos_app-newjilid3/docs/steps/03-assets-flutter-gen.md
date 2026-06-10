# 03 — Assets + flutter_gen

## Goal

Folder `assets/` siap dengan SVG icons + logo, dan `flutter_gen` di-generate jadi class `Assets` supaya kita bisa akses path lewat `Assets.icons.qrCode.path` (type-safe, autocomplete) daripada string literal `'assets/icons/qr_code.svg'`.

## Prerequisite

- Step 02 selesai.
- `flutter_gen_runner` sudah ada di `dev_dependencies` (dari step 01).

## Konsep yang diajarkan

- **Assets di Flutter**: harus didaftarkan di `pubspec.yaml` section `flutter.assets:` — kalau tidak, runtime exception `Unable to load asset`.
- **`flutter_gen`**: generator yang baca `pubspec.yaml` dan bikin file Dart yang berisi referensi tipe-aman ke semua asset.
- **SVG vs PNG**: SVG bisa di-tint pakai `colorFilter`, ringan, scalable. PNG dipakai kalau ada foto/raster art.
- **`flutter_svg` integration di flutter_gen**: menghasilkan widget builder `Assets.icons.X.svg(width: 24, height: 24, colorFilter: ColorFilter.mode(p.primary, BlendMode.srcIn))`.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app` sudah punya struktur folder dan `flutter_gen` di pubspec. Saya mau setup assets dan generate referensi tipe-aman.

Tugas:

1. **Buat folder asset & isi placeholder**.
   Pastikan folder `assets/icons/`, `assets/images/`, `assets/logo/` ada di root project.
   Generate ke `assets/icons/` 17 file SVG monoline placeholder 24x24, strokeWidth 2, viewBox 0 0 24 24. Tiap SVG harus simple (lingkaran/rectangle/path dasar) sesuai nama — nanti bisa di-replace dengan icon asli:
   - all_categories.svg (grid 2x2)
   - cash.svg (dompet)
   - dashboard.svg (4 kotak)
   - debit.svg (kartu)
   - delete.svg (trash)
   - done.svg (checkmark dalam lingkaran)
   - drink.svg (gelas)
   - food.svg (piring + sendok)
   - history.svg (jam dengan panah)
   - home.svg (rumah)
   - image.svg (frame foto)
   - orders.svg (clipboard)
   - payments.svg (kartu kredit)
   - print.svg (printer)
   - qr_code.svg (4 kotak QR)
   - snack.svg (donat)

   Generate ke `assets/logo/mylogo.png`: placeholder text instruction — minta user replace dengan logo asli (cantumkan: "Recommend 512x512 PNG transparent BG").
   Generate ke `assets/images/.gitkeep`.

2. **Verifikasi `pubspec.yaml` punya section yang benar**:
   ```yaml
   flutter_gen:
     output: lib/core/assets/
     integrations:
       flutter_svg: true
   flutter:
     uses-material-design: true
     assets:
       - assets/images/
       - assets/icons/
       - assets/logo/
   ```
   Kalau belum, suruh saya update.

3. **Generate file referensi**:
   Beri perintah:
   ```
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   Setelah itu, file `lib/core/assets/assets.gen.dart` akan ter-generate otomatis.

4. **Tambah ke `.gitignore`** (kalau belum):
   - Tetap commit `assets.gen.dart` (jangan ignore) — supaya CI / fresh clone tidak perlu run build_runner dulu sebelum analyze.
   - Tapi ignore `*.g.dart` dan `*.freezed.dart` (file generated lain dari Freezed). Update `.gitignore`:
     ```
     # generated dart files
     **/*.freezed.dart
     **/*.g.dart
     # tapi keep assets.gen.dart
     !lib/core/assets/assets.gen.dart
     ```

5. **Tunjukkan contoh pakai di widget**:
   ```dart
   // SVG dengan tint pakai palette
   import 'package:flutter_pos_app/core/assets/assets.gen.dart';
   import 'package:flutter_pos_app/core/theme/app_palette.dart';
   import 'package:flutter_svg/flutter_svg.dart';

   final p = context.palette;
   Assets.icons.qrCode.svg(
     width: 24, height: 24,
     colorFilter: ColorFilter.mode(p.primary, BlendMode.srcIn),
   );

   // PNG logo
   Image.asset(Assets.logo.mylogo.path, height: 80);
   ```

6. **Catatan tentang Material Icons**:
   Beri tahu saya bahwa untuk icon umum (search, settings, home, dll) kita pakai `Icons.X_outlined` dari Material. SVG di `assets/icons/` hanya untuk yang specific brand/domain (mis. `qr_code` overlay, `drink`/`food` kategori).
````

---

## Verifikasi

1. `flutter pub get` clean.
2. `flutter pub run build_runner build --delete-conflicting-outputs` selesai tanpa error.
3. File `lib/core/assets/assets.gen.dart` muncul, berisi class `Assets`, `$AssetsIconsGen`, `$AssetsLogoGen`, dll.
4. Tambahkan ke `main.dart` placeholder:
   ```dart
   body: Center(
     child: Assets.icons.qrCode.svg(width: 64, height: 64),
   ),
   ```
   Run → SVG QR placeholder tampil.

## Talking points

1. **Kenapa generate, bukan tulis manual?**
   Drift typo: kalau salah ketik `'assets/icons/qrr_code.svg'`, error baru muncul saat runtime. Generated `Assets.icons.qrCode.path` di-cek compile-time. Tambah icon baru? Run build_runner lagi → otomatis terupdate.

2. **`colorFilter: ColorFilter.mode(color, BlendMode.srcIn)`**:
   Ini cara tint SVG monoline (yang fill-nya hitam) jadi warna apapun. `srcIn` = "keep alpha source, replace color". Kalau SVG-mu udah ada warna (multi-color), tint ini bisa nge-flatten — pakai dengan hati-hati.

3. **Kapan PNG, kapan SVG?**
   - SVG: icon, logo simple (geometri), illustration outline. Bisa di-tint.
   - PNG: foto, logo brand kompleks (gradient/realistic), splash image.
   - Tidak ada SVG dengan animasi di Flutter native — pakai Lottie kalau perlu motion.

4. **Mengapa `assets.gen.dart` di-commit?**
   Supaya pull → langsung `flutter run` jalan tanpa build_runner step. Tapi tetap update kalau tambah asset. Untuk Freezed (`*.freezed.dart`) kita biasanya ignore karena jumlahnya banyak dan rentan konflik di git.

5. **`build_runner watch`**:
   Saat development intensive (tambah Freezed event/state), pakai `flutter pub run build_runner watch --delete-conflicting-outputs` di terminal lain — auto-regenerate on save.

## Commit suggestion

```bash
git add assets/ lib/core/assets/ .gitignore pubspec.yaml
git commit -m "Step 03: assets folder + flutter_gen output"
```

---

➡️ Lanjut ke [Step 04 — Core Extensions](./04-core-extensions.md)
