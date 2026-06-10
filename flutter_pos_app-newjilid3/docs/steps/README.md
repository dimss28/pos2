# Bangun POS Batch 11 dari Nol — Panduan Mengajar

Dokumentasi step-by-step untuk membangun **Flutter POS App** dari project kosong sampai siap rilis Play Store. Tiap step adalah file Markdown terpisah berisi:

1. **Goal** — apa yang dihasilkan di step ini
2. **Konsep yang diajarkan** — poin teori untuk peserta
3. **Prompt siap kirim ke AI** — copy-paste langsung ke Claude/ChatGPT/Cursor untuk generate kode
4. **Verifikasi** — cara cek hasil sudah benar
5. **Talking points** — bahan ngajar saat membahas hasilnya

> **Audience**: Pemula Flutter (sudah paham Dart dasar, baru pertama belajar Flutter + BLoC + SQLite). Tiap step dijelaskan eksplisit.

---

## Cara pakai dokumen ini saat mengajar

1. Buka file step (mis. `01-setup-project.md`).
2. Bahas dulu bagian **Konsep yang diajarkan** ke peserta (5–10 menit).
3. Tunjukkan **Prompt siap kirim ke AI** — paste ke Claude Code / Cursor.
4. AI generate kode → bahas hasilnya bareng peserta menggunakan **Talking points**.
5. Jalankan **Verifikasi** bareng-bareng (run app, cek state, dll).
6. Lanjut ke step berikutnya.

Tiap step sengaja **incremental** — app tetap bisa di-run di akhir tiap step (kecuali step yang eksplisit ditandai "WIP intermediate").

---

## Urutan Step

### Fase 0 — Orientasi

| # | File | Topik |
|---|---|---|
| 00 | [`00-overview.md`](./00-overview.md) | Arsitektur tinggi, tech stack, peta fitur, dan SQLite schema final |

### Fase 1 — Fondasi (Setup, Theme, Extensions)

| # | File | Topik |
|---|---|---|
| 01 | [`01-setup-project.md`](./01-setup-project.md) | `flutter create`, struktur folder, `pubspec.yaml`, dependency list |
| 02 | [`02-theme-foundation.md`](./02-theme-foundation.md) | `AppPalette` (3 palette), `AppSpacing`, `AppRadius`, `AppTypography`, `AppTheme` |
| 03 | [`03-assets-flutter-gen.md`](./03-assets-flutter-gen.md) | Asset folder (`assets/icons`, `assets/images`, `assets/logo`), `flutter_gen` |
| 04 | [`04-core-extensions.md`](./04-core-extensions.md) | `int.currencyFormatRp`, `String.toIntegerFromText`, `DateTime.toFormattedTime`, `context.push`/`pop`, `context.palette` |

### Fase 2 — Komponen Atom

| # | File | Topik |
|---|---|---|
| 05 | [`05-atoms-button-textfield-chip.md`](./05-atoms-button-textfield-chip.md) | `AppButton`, `AppTextField`, `AppMoneyTextField`, `AppChip` |
| 06 | [`06-atoms-layout.md`](./06-atoms-layout.md) | `AppAppBar`, `AppBottomNav`, `AppCard`, `AppListGroup`, `AppStickyFooter`, `AppSectionLabel`, `SpaceHeight`/`SpaceWidth` |
| 07 | [`07-atoms-feedback.md`](./07-atoms-feedback.md) | `AppEmptyState`, `AppBanner`, `AppStatusPill`, `AppBadge`, `AppNumberedStep`, `feedback.dart` (`AppSnackbar`/`AppConfirm`/`AppLoadingDialog`) |
| 08 | [`08-atoms-form.md`](./08-atoms-form.md) | `AppStepper`, `AppStepperField`, `AppSwitchTile`, `AppSegmentedToggle`, `AppIconButton`, `AppKeyValueRow`, `AppBottomSheet` |
| 09 | [`09-atoms-domain.md`](./09-atoms-domain.md) | `ProductImg`, `Avatar`, `MethodBadge`, `BrandMark`, `QrView`, `TrendChart`, `ScannerOverlay` |

### Fase 3 — Layer Data (Models, Datasources, SQLite)

| # | File | Topik |
|---|---|---|
| 10 | [`10-models-request-response.md`](./10-models-request-response.md) | `AuthResponseModel`, `ProductResponseModel`, `CategoryResponseModel`, `OrderRequestModel`, request/response pattern handwritten `fromMap`/`toMap` |
| 11 | [`11-remote-datasources.md`](./11-remote-datasources.md) | `AuthRemoteDatasource`, `ProductRemoteDatasource`, pola `Future<Either<String, T>>` dengan `dartz`, base URL via `--dart-define` |
| 12 | [`12-sqlite-local-datasource.md`](./12-sqlite-local-datasource.md) | `ProductLocalDatasource` singleton, schema 6 tabel, version 7, `_onUpgrade` migration switch |
| 13 | [`13-auth-local-datasource.md`](./13-auth-local-datasource.md) | `AuthLocalDatasource` + `flutter_secure_storage`, `saveAuthData`, `isAuth`, `getAuthData`, `removeAuthData` |

### Fase 4 — Auth & App Shell

| # | File | Topik |
|---|---|---|
| 14 | [`14-theme-bloc.md`](./14-theme-bloc.md) | `ThemeBloc` (palette switching) + Freezed unions, `AppBlocObserver` untuk debug |
| 15 | [`15-main-multi-bloc-provider.md`](./15-main-multi-bloc-provider.md) | `main.dart`: `WidgetsFlutterBinding`, `initializeDateFormatting`, `MultiBlocProvider`, `BlocBuilder<ThemeBloc>`, `MaterialApp` |
| 16 | [`16-splash-auth-gate.md`](./16-splash-auth-gate.md) | `SplashPage` — auth-gate ke `LoginPage` atau `DashboardPage` |
| 17 | [`17-login-bloc-page.md`](./17-login-bloc-page.md) | `LoginBloc` + `LoginPage` (form email/password, validation, error state) |
| 18 | [`18-dashboard-bottom-nav.md`](./18-dashboard-bottom-nav.md) | `DashboardPage` (bottom nav 4 tab: Home/Order/Riwayat/Setting) + `LogoutBloc` + `DeleteAccountBloc` |

### Fase 5 — Home & Katalog

| # | File | Topik |
|---|---|---|
| 19 | [`19-product-category-bloc.md`](./19-product-category-bloc.md) | `ProductBloc`, `CategoryBloc` (fetch dari local DB, fallback ke remote saat kosong) |
| 20 | [`20-home-page.md`](./20-home-page.md) | `HomePage` — grid produk, filter kategori, search bar, floating cart bar |
| 21 | [`21-scanner-page.md`](./21-scanner-page.md) | `ScannerPage` (`mobile_scanner`), `ScannerOverlay`, permission handling, lifecycle pause/resume |

### Fase 6 — Keranjang & Checkout

| # | File | Topik |
|---|---|---|
| 22 | [`22-checkout-bloc.md`](./22-checkout-bloc.md) | `CheckoutBloc` — `addItem`, `removeItem`, `clear`, `started`, `CheckoutSummary` model |
| 23 | [`23-order-page.md`](./23-order-page.md) | `OrderPage` — list item, `AppStepper` per row, total subtotal/diskon/total, sticky footer "Bayar" |
| 24 | [`24-open-bill-sheet.md`](./24-open-bill-sheet.md) | `OpenBillSheet` — bottom sheet simpan ke draft (nama customer + meja), `DraftOrderBloc.save` |

### Fase 7 — Pembayaran

| # | File | Topik |
|---|---|---|
| 25 | [`25-payment-confirm-cash.md`](./25-payment-confirm-cash.md) | `PaymentConfirmSheet` — input cash, quick chips (Pas/+5rb/+10rb/+20rb/+50rb), hitung kembalian live |
| 26 | [`26-order-bloc-save-local.md`](./26-order-bloc-save-local.md) | `OrderBloc` — `persistLocal(summary)`, simpan order ke SQLite, decrement stock, attach `cash_session_id` |
| 27 | [`27-payment-success-receipt.md`](./27-payment-success-receipt.md) | `PaymentSuccessSheet` + cetak struk Bluetooth (`PrinterService`, `CwbPrint`, ESC/POS), fallback PDF |
| 28 | [`28-payment-qris.md`](./28-payment-qris.md) | `QrisBloc` + `PaymentQRISSheet` — generate QR Midtrans, polling status, success → SuccessSheet |

### Fase 8 — Draft Order, History, Refund

| # | File | Topik |
|---|---|---|
| 29 | [`29-draft-order.md`](./29-draft-order.md) | `DraftOrderBloc` + `DraftOrderPage` (list, expand, hapus, lanjut bayar) |
| 30 | [`30-history-page.md`](./30-history-page.md) | `HistoryBloc` + `HistoryPage` (filter Hari ini/Minggu/Bulan/Custom, group by tanggal) |
| 31 | [`31-transaction-detail.md`](./31-transaction-detail.md) | `TransactionDetailPage` — full record, action Cetak Ulang / Share PDF / Refund |
| 32 | [`32-refund-flow.md`](./32-refund-flow.md) | `RefundBloc` + `RefundSheet` — alasan + catatan, update status order, restore stock, bump `cash_out` |

### Fase 9 — Cash Session (Buka/Tutup Kasir)

| # | File | Topik |
|---|---|---|
| 33 | [`33-cash-session-data.md`](./33-cash-session-data.md) | `CashSessionLocalDatasource` + `CashSessionRemoteDatasource` + `CashSessionBloc` (open/close/currentLoaded) |
| 34 | [`34-buka-kasir.md`](./34-buka-kasir.md) | `BukaKasirPage` — pilih shift (Pagi/Siang/Malam), modal opening float, mulai shift |
| 35 | [`35-tutup-kasir.md`](./35-tutup-kasir.md) | `TutupKasirPage` — recap penjualan, hitung variance, checklist, `CloseKasirSuccessSheet` |

### Fase 10 — Settings & Management

| # | File | Topik |
|---|---|---|
| 36 | [`36-setting-page-hub.md`](./36-setting-page-hub.md) | `SettingPage` — grouped tiles, status live (printer/server key/last sync), pilih palette, logout, hapus akun, privacy policy |
| 37 | [`37-manage-product.md`](./37-manage-product.md) | `ManageProductPage` + `AddProductPage` + `ProductDetailSheet` (multipart upload image, edit, hapus, bestseller toggle) |
| 38 | [`38-manage-printer.md`](./38-manage-printer.md) | `ManagePrinterPage` + `PrinterService` (`print_bluetooth_thermal`), permission Bluetooth, pairing, status banner |
| 39 | [`39-server-key-qris.md`](./39-server-key-qris.md) | `SaveServerKeyPage` — env toggle (sandbox/production), masked input, simpan ke `flutter_secure_storage` |
| 40 | [`40-sync-data.md`](./40-sync-data.md) | `SyncBloc` + `SyncDataPage` — pull products/categories/promos, push pending orders, snapshot counts |

### Fase 11 — Promo

| # | File | Topik |
|---|---|---|
| 41 | [`41-promo-management.md`](./41-promo-management.md) | `PromoBloc` + `PromoRemoteDatasource` + `PromoLocalDatasource` + `ManagePromoPage` + `AddEditPromoPage` |
| 42 | [`42-discount-sheet.md`](./42-discount-sheet.md) | `DiscountSheet` — apply promo di OrderPage (voucher code, auto promo, manual discount), `AppliedDiscount` model |

### Fase 12 — Report & Polish

| # | File | Topik |
|---|---|---|
| 43 | [`43-report-page.md`](./43-report-page.md) | `ReportPage` — date range, 4 metric cards, `TrendChart`, product sales table, export PDF (`pdf` package) |
| 44 | [`44-connectivity-auto-sync.md`](./44-connectivity-auto-sync.md) | `ConnectivityBloc` (`connectivity_plus`), state `restored`, auto-trigger sync di `main.dart` listener |
| 45 | [`45-play-store-prep.md`](./45-play-store-prep.md) | `ReceiptSettingsPage`, `PrivacyPolicyPage`, in-app hapus akun, ProGuard/R8, release signing, permission rationale |

---

## Cheat sheet konvensi

- **State management**: `flutter_bloc` + Freezed unions. Tidak pakai Cubit/Provider/Riverpod.
- **Models**: request/response handwritten (`fromMap`/`toMap`); bloc state/event pakai Freezed.
- **Navigation**: Navigator 1.0 via `context.push(SomePage())` (lihat `build_context_ext.dart`).
- **Theme**: akses lewat `context.palette` (extension di `app_palette.dart`). Jangan pakai `AppColors.*` langsung.
- **Bahasa UI**: Bahasa Indonesia.
- **Currency**: `int.currencyFormatRp` extension. Jangan inline `NumberFormat`.

## Tips saat mengajar

- **Jangan generate 5 step sekaligus** — peserta akan kehilangan konteks. 1 step → run → bahas → next.
- **Library/plugin baru** (mis. `mobile_scanner`, `print_bluetooth_thermal`): pause sebentar di step itu, demo plugin di sandbox kecil sebelum integrate.
- **Hot reload tidak menangkap perubahan schema SQLite** — peserta sering bingung kenapa kolom baru tidak muncul. Selalu uninstall + reinstall app saat ganti schema (atau bump version + tulis `_onUpgrade`).
- **`build_runner`** untuk Freezed: ajarkan `flutter pub run build_runner watch --delete-conflicting-outputs` supaya jalan otomatis.
- **Backend Laravel**: peserta perlu API ready. Bisa pakai BE yang sudah ada (`/Users/bahri/development/FIC11Jilid2/laravel-pos-backend-prejilid2`) atau mock dengan tools seperti Postman/JSON Server kalau backend belum siap.
