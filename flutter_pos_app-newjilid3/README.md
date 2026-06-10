# flutter_pos_app

Aplikasi **Point of Sale (POS)** berbasis Flutter dengan arsitektur offline-first dan sinkronisasi ke backend Laravel. Mendukung manajemen produk, kasir, cetak struk via Bluetooth thermal printer, pembayaran QRIS (Midtrans), scan barcode/QR, serta laporan penjualan.

## Tech Stack

- **Flutter** 3.41.9 (stable) — Dart SDK `>=3.2.0 <4.0.0`
- **State Management**: `flutter_bloc` ^8.1.3
- **Local Storage**: `sqflite` ^2.3.0, `shared_preferences` ^2.2.2
- **HTTP**: `http` ^1.1.2
- **Codegen**: `freezed` ^2.4.6, `build_runner` ^2.4.7, `flutter_gen_runner` ^5.3.2
- **Printing**: `print_bluetooth_thermal` ^1.1.6, `esc_pos_utils_plus` ^2.0.3, `pdf` ^3.11.1
- **Scanner**: `mobile_scanner` ^5.2.1
- **Lainnya**: `google_fonts` ^7.0.0, `image_picker` ^1.0.5, `permission_handler` ^11.3.1, `cached_network_image` ^3.3.0

Konfigurasi Android: `compileSdk` 35, `targetSdk` 35, `minSdk` mengikuti `flutter.minSdkVersion`.

## Fitur

- **Auth** — login & logout via API
- **Dashboard & Home** — daftar produk, kategori, keranjang/checkout
- **Order** — checkout tunai & QRIS (Midtrans), draft order (simpan transaksi sementara di SQLite)
- **History** — riwayat transaksi
- **Scan QR/Barcode** — tambah produk ke keranjang lewat kamera
- **Setting**
  - Manajemen produk (`add_product`, `manage_product`)
  - Manajemen printer Bluetooth thermal (`manage_printer`)
  - Sinkronisasi data offline ↔ server (`sync_data`)
  - Simpan server key (`save_server_key`)
  - Laporan: summary, product sales, close cashier (export PDF)
- **Cetak struk** thermal printer & **invoice PDF**

## Struktur Project

```
lib/
├── main.dart                  # entry point, MultiBlocProvider, routing
├── core/                      # konstanta, ekstensi, assets, helper
├── data/
│   ├── datasources/           # remote (HTTP) & local (SQLite/SharedPrefs)
│   ├── dataoutputs/           # output helpers (printer, pdf)
│   └── models/                # request/response models
└── presentation/
    ├── auth/                  # login
    ├── home/                  # dashboard, home, scanner
    ├── order/                 # checkout, qris (Midtrans)
    ├── draft_order/           # draft transaksi offline
    ├── history/               # riwayat transaksi
    └── setting/               # produk, printer, sync, laporan
```

## Backend

Backend Laravel untuk app ini berada di:
`/Users/bahri/development/FIC11Jilid2/laravel-pos-backend-prejilid2`

Sesuaikan base URL API di `lib/data/datasources/` saat development.

## Setup

```bash
# install dependencies
flutter pub get

# generate kode (freezed, flutter_gen, dll)
dart run build_runner build --delete-conflicting-outputs

# jalankan di device terhubung
flutter run
```

## Build

```bash
# Android (debug)
flutter build apk --debug

# Android (release)
flutter build apk --release

# iOS (release, butuh signing)
flutter build ios --release
```

Output APK: `build/app/outputs/flutter-apk/`.

## Permissions

Aplikasi membutuhkan izin runtime untuk:
- Kamera (scan QR/barcode)
- Bluetooth (thermal printer)
- Penyimpanan (simpan/share PDF laporan)
- Lokasi (beberapa device butuh ini untuk discovery Bluetooth)

## Catatan

- Project memakai pola **BLoC** dengan `freezed` untuk event/state.
- Data produk disimpan lokal (SQLite) supaya transaksi tetap jalan tanpa internet, lalu disinkronkan ke server via menu **Sync Data**.
- Pembayaran QRIS terintegrasi dengan **Midtrans** — set server key via menu **Save Server Key**.
