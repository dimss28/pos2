# 00 — Overview: Apa yang akan kita bangun

> **Step orientasi.** Belum ada kode di sini. Bahas materi ini ke peserta sebagai pengantar sebelum mulai step 01.

---

## Goal step ini

Peserta paham:
1. **Apa yang dibangun**: aplikasi POS (Point-of-Sale) untuk UMKM, mobile-first Android, offline-first.
2. **Tech stack**: Flutter + BLoC + SQLite + Laravel BE.
3. **Peta fitur**: 14 halaman utama, 13+ bloc, 8 datasource.
4. **Arsitektur**: layer-first (`core/data/presentation`) + feature-first di dalam `presentation/`.
5. **Data flow**: source-of-truth per domain (lokal vs remote), kapan sync jalan.

---

## Konsep yang diajarkan

### 1. Apa itu POS Batch 11

Aplikasi kasir untuk warung/cafe/retail kecil dengan kebutuhan:

- **Kasir cepat**: scan/tap produk → checkout → cetak struk → done dalam <30 detik
- **Offline-first**: transaksi tetap jalan tanpa internet, di-sync ke Laravel saat online
- **Shift discipline**: ada buka kasir (opening float) dan tutup kasir (variance kas fisik vs expected)
- **Multi metode bayar**: Cash, QRIS (Midtrans), Transfer
- **Cetak struk**: Bluetooth thermal printer (`print_bluetooth_thermal`)
- **Diskon/promo**: voucher code & auto promo

### 2. Tech stack

| Layer | Pilihan | Alasan |
|---|---|---|
| Framework | Flutter 3.41+, Dart 3.11+ | Cross-platform, ekosistem matang |
| State management | `flutter_bloc` + Freezed unions | Eksplisit, testable, immutable state |
| Database lokal | `sqflite` (SQLite) | Single-file, query SQL standar, offline-friendly |
| Secure storage | `flutter_secure_storage` | Untuk auth token & server key QRIS |
| HTTP client | `package:http` (bukan Dio) | Simple, cukup untuk kebutuhan |
| QR generator | `qr_flutter` | Native rendering |
| QR scanner | `mobile_scanner` | Maintained, performant |
| Printer | `print_bluetooth_thermal` + `esc_pos_utils_plus` | ESC/POS Bluetooth thermal |
| PDF | `pdf` + `open_filex` | Generate struk/laporan |
| Fonts | `google_fonts` (Quicksand) | Friendly, legible di layar HP |
| Charts | `fl_chart` | Trend penjualan |
| Connectivity | `connectivity_plus` | Auto-sync saat online |

### 3. Peta fitur (14 halaman utama)

```
SplashPage (auth gate)
  └─ LoginPage
      └─ DashboardPage (bottom nav)
          ├─ HomePage (katalog produk + scanner)
          ├─ OrderPage (keranjang + bayar)
          │   ├─ OpenBillSheet → DraftOrderPage
          │   ├─ DiscountSheet (promo)
          │   ├─ PaymentConfirmSheet (cash)
          │   ├─ PaymentQRISSheet (QRIS)
          │   └─ PaymentSuccessSheet
          ├─ HistoryPage → TransactionDetailPage → RefundSheet
          └─ SettingPage
              ├─ ManageProductPage → AddProductPage → ProductDetailSheet
              ├─ ManagePrinterPage
              ├─ SaveServerKeyPage (QRIS)
              ├─ SyncDataPage
              ├─ ReceiptSettingsPage
              ├─ PrivacyPolicyPage
              ├─ Report → ReportPage
              ├─ Manage Promo → ManagePromoPage → AddEditPromoPage
              └─ Tutup Kasir → TutupKasirPage → CloseKasirSuccessSheet

(di luar dashboard:)
BukaKasirPage  # Setelah login, kalau belum ada open shift
```

### 4. Arsitektur folder

```
lib/
├── main.dart                     # MultiBlocProvider + MaterialApp + auth gate
├── core/
│   ├── assets/                   # flutter_gen output (jangan diedit manual)
│   ├── bloc/                     # AppBlocObserver
│   ├── components/               # ~35 widget atom (AppButton, AppTextField, dll)
│   ├── constants/                # AppColors (legacy), Variables (env)
│   ├── extensions/               # int/string/date/context extensions
│   ├── services/                 # PrinterService
│   └── theme/                    # AppTheme, AppPalette, AppSpacing, AppRadius, AppTypography
├── data/
│   ├── dataoutputs/              # cwb_print.dart (ESC/POS formatter)
│   ├── datasources/              # remote + local sources (~10 file)
│   └── models/
│       ├── request/              # XxxRequestModel
│       └── response/             # XxxResponseModel
└── presentation/<feature>/
    ├── pages/                    # full-page widgets (1 Scaffold per page)
    ├── widgets/                  # feature-scoped widgets
    ├── models/                   # UI-only data classes (Freezed)
    └── bloc/<topic>/
        ├── <topic>_bloc.dart
        ├── <topic>_event.dart   (part of)
        ├── <topic>_state.dart   (part of)
        └── <topic>_bloc.freezed.dart  (generated)
```

Feature folders di `presentation/`:
`auth`, `home`, `order`, `draft_order`, `history`, `setting`, `cash_session`, `promo`, `refund`, `connectivity`, `dev`.

### 5. Data flow — source of truth per domain

| Domain | Sumber utama | Cache lokal | Pola sync | Boleh offline? |
|---|---|---|---|---|
| Products | Backend `/api/products` | tabel `products` | Pull-replace via `SyncBloc.pullProducts` | ✅ |
| Categories | Backend `/api/list-categories` | tabel `categories` | Pull-replace via `SyncBloc.pullCategories` | ✅ |
| Promos | Backend `/api/promos` | tabel `promos` | Pull-replace via `SyncBloc.pullPromos` | ✅ |
| Orders | **Lokal dulu** | tabel `orders` (`is_sync` flag) | Push via `SyncBloc.pushOrders` | ✅ |
| Cash sessions | **Backend** | tabel `cash_sessions` (mirror) | Remote-first | ❌ butuh online |
| Reports | Backend only | — | On-demand fetch | ❌ |
| Auth token | Backend (login) | `flutter_secure_storage` | One-shot | N/A |
| Server key QRIS | User input lokal | `flutter_secure_storage` | Tidak pernah di-upload | ✅ |
| Printer MAC | User pairing lokal | `SharedPreferences['printer']` | Tidak pernah di-upload | ✅ |

**Aturan emas**: katalog (products/categories/promos) selalu dibaca dari local cache, jangan langsung hit remote dari widget. Orders selalu ditulis lokal dulu, baru di-push.

### 6. SQLite schema final (`pos13.db` v7)

7 tabel:

```sql
products(id, product_id, name, price, stock, image, category, category_id, is_best_seller, is_sync)
categories(id, category_id, name)
orders(id, nominal, payment_method, total_item, id_kasir, nama_kasir, transaction_time, is_sync,
       cash_session_id, promo_id, discount_amount,
       status, refunded_at, refund_reason, refund_note, refund_amount, refunded_by_user_id)
order_items(id, id_order, id_product, quantity, price, note)
draft_orders(id, total_item, nominal, transaction_time, table_number, table_label, draft_name, customer_name)
draft_order_items(id, id_draft_order, id_product, quantity, price)
cash_sessions(id, user_id, user_name, shift_label, opening_float, opening_note, opened_at,
              cash_in, cash_out, physical_count, expected_cash, variance,
              closing_note, closed_at, is_sync)
promos(id, name, type, value, code, applies_to, min_subtotal, starts_at, ends_at, active, is_sync)
```

**Migration policy**: bump DB version setiap ubah schema. Tulis `_onUpgrade(db, oldV, newV)` dengan `if (oldVersion < N)` cascading. Kita akan capai versi 7 di akhir step 12.

### 7. Tema visual

- Material 3 (`useMaterial3: true`)
- 3 palette: **Caramel Latte** (default), Espresso, Matcha — user pilih di Settings
- Font: **Quicksand** via `google_fonts`
- Spacing: 4pt grid
- Radius: `xs=6, sm=10, md=14, lg=20, xl=28, pill=999`
- Akses tema: `context.palette.primary` (extension), **bukan** `AppColors.primary`

---

## Talking points (untuk diajar)

1. **Kenapa offline-first?** UMKM sering punya wifi flaky. Kalau app crash saat checkout karena ga ada internet, kasir kehilangan transaksi → trust hilang.
2. **Kenapa BLoC, bukan setState?** Karena state app POS itu shared antar page (cart, shift aktif, sync queue). `setState` cuma cocok untuk local widget state.
3. **Kenapa SQLite, bukan Hive/Drift?** SQL standar, mudah debug pakai DB Browser, query reporting (group by tanggal/produk) jauh lebih simple dengan SQL.
4. **Kenapa Freezed cuma untuk bloc & UI model, bukan response DTO?** DTO sudah ada konvensi `fromMap`/`toMap` di project, dan kalau di-Freezed-kan jadi noise. Freezed nilainya tinggi untuk unions (event/state).
5. **Kenapa 45 step?** Kita pecah supaya tiap step bisa di-prompt ke AI, di-bahas, dan di-run dalam 15–30 menit. Total ~20–30 jam mengajar kalau dijalankan rapi.

---

## Persiapan sebelum mulai step 01

Pastikan setup berikut sudah ready di mesin peserta:

- [ ] Flutter SDK 3.41+ (`flutter --version`)
- [ ] Android Studio + Android SDK + emulator (atau HP fisik dengan USB debugging)
- [ ] VS Code atau Android Studio (editor)
- [ ] Backend Laravel running di `http://192.168.x.x:8000` (atau yang sudah disediakan instruktur)
- [ ] AI assistant terhubung (Claude Code / Cursor / Copilot Chat) untuk menerima prompt
- [ ] Git terinstall (peserta sebaiknya commit per step)

Cek dependency Android:
```bash
flutter doctor
# Harus semua ✓ kecuali iOS (boleh skip kalau gak punya Mac)
```

Demo singkat:
```bash
flutter create demo_pos
cd demo_pos
flutter run  # pastikan emulator/HP nyala dan app default jalan
```

---

## Estimasi waktu

| Fase | Step | Estimasi |
|---|---|---|
| Fondasi (1) | 01–04 | 2–3 jam |
| Atoms (2) | 05–09 | 4–6 jam |
| Data (3) | 10–13 | 3–4 jam |
| Auth + Shell (4) | 14–18 | 3–4 jam |
| Home + Katalog (5) | 19–21 | 2–3 jam |
| Cart + Payment (7–8) | 22–28 | 5–6 jam |
| Draft + History + Refund (9–10) | 29–32 | 3–4 jam |
| Cash Session (11) | 33–35 | 2–3 jam |
| Settings (12) | 36–40 | 4–5 jam |
| Promo (13) | 41–42 | 2 jam |
| Report + Polish (14–15) | 43–45 | 3 jam |
| **Total** | **45 step** | **~35 jam** |

Cocok untuk **bootcamp 5 hari (7 jam/hari)** atau **kursus 3 minggu (10–12 jam/minggu)**.

---

➡️ Lanjut ke [Step 01 — Setup Project](./01-setup-project.md)
