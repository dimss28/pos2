# Pages Audit — flutter_pos_app

Dokumentasi lengkap setiap `*_page.dart` di `lib/`: fitur, status pemakaian, dan dependensi penting.

**Hasil ringkas**: 14 page ditemukan, **14 aktif dipakai**, **0 unused**. Codebase bersih dari dead page.

Audit dilakukan pada commit `583362b` di branch `newjilid3` (basis dari `fulljilid2`), Flutter 3.41.9.

---

## Daftar Halaman Aktif

### 1. `lib/presentation/auth/pages/login_page.dart`

- **Class**: `LoginPage`
- **Fitur**: Halaman login user. Form email & password, otentikasi via API (`AuthRemoteDatasource`), simpan token via `AuthLocalDatasource`, lanjut ke `DashboardPage` saat sukses.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `lib/main.dart:11` — initial route saat user belum login
  - `lib/presentation/setting/pages/setting_page.dart` — redirect setelah logout
- **BLoC / Datasource**: `LoginBloc`, `AuthRemoteDatasource`, `AuthLocalDatasource`

---

### 2. `lib/presentation/home/pages/dashboard_page.dart`

- **Class**: `DashboardPage`
- **Fitur**: Root screen setelah login. Mengandung bottom navigation dengan 4 tab utama: **Home**, **Order**, **History**, **Setting**.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `lib/main.dart:17` — initial route saat user sudah login
  - `login_page.dart` — redirect setelah login sukses
  - `home_page.dart`, `order_page.dart`, `history_page.dart`, `draft_order_page.dart`, `manage_product_page.dart`, `setting_page.dart`, `payment_success_dialog.dart` — back-navigation
- **BLoC / Datasource**: konsumen multi-BLoC dari `MultiBlocProvider` di `main.dart`

---

### 3. `lib/presentation/home/pages/home_page.dart`

- **Class**: `HomePage`
- **Fitur**: Daftar produk dengan filter kategori dan search bar. Search bar punya tombol scan QR yang membuka `ScannerPage`. Mengelola koneksi `PrintBluetoothThermal` saat init. Bisa buka `DraftOrderPage` via icon note.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `dashboard_page.dart` — tab 0 bottom nav
- **BLoC / Datasource**: `ProductBloc`, `CategoryBloc`
- **Plugin penting**: `print_bluetooth_thermal`

---

### 4. `lib/presentation/home/pages/scanner_page.dart`

- **Class**: `ScannerPage`
- **Fitur**: Scan QR/barcode produk menggunakan kamera. Hasil scan dikirim ke `ProductBloc.searchProduct`. Menangani lifecycle kamera (pause/resume saat app background).
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `lib/core/components/search_input.dart:39` — tombol scan di search bar
- **BLoC / Datasource**: `ProductBloc`
- **Plugin penting**: `mobile_scanner`, butuh permission kamera

---

### 5. `lib/presentation/order/pages/order_page.dart`

- **Class**: `OrderPage`
- **Fitur**: Detail order/keranjang. Menampilkan item, hitung subtotal, pajak, total. Mendukung pilihan metode pembayaran (Cash / QRIS / Transfer), simpan draft, dan cetak struk via Bluetooth printer.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `dashboard_page.dart` — tab 1 bottom nav
  - `lib/presentation/draft_order/wedgets/draft_order_card.dart:75` — resume draft order
- **BLoC / Datasource**: `CheckoutBloc`, `OrderBloc`, `AuthLocalDatasource`
- **Plugin penting**: `print_bluetooth_thermal` (via `CwbPrint.instance`)

---

### 6. `lib/presentation/draft_order/pages/draft_order_page.dart`

- **Class**: `DraftOrderPage`
- **Fitur**: Daftar order draft (transaksi tertunda) yang tersimpan di SQLite. Bisa lanjut pembayaran ke `OrderPage` atau kembali ke `DashboardPage`.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `home_page.dart:81` — tombol note icon di app bar
- **BLoC / Datasource**: `DraftOrderBloc`, `ProductLocalDatasource`

---

### 7. `lib/presentation/history/pages/history_page.dart`

- **Class**: `HistoryPage`
- **Fitur**: Riwayat transaksi selesai. List transaksi yang sudah ter-checkout, fetch via `HistoryBloc` saat init.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `dashboard_page.dart` — tab 2 bottom nav
- **BLoC / Datasource**: `HistoryBloc`

---

### 8. `lib/presentation/setting/pages/setting_page.dart`

- **Class**: `SettingPage`
- **Fitur**: Hub setting/konfigurasi. Menu: **Manage Product**, **Manage Printer**, **Save QRIS Server Key**, **Sync Data**, **Report**, **Close Cashier**, dan **Logout**.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `dashboard_page.dart` — tab 3 bottom nav
- **BLoC / Datasource**: `LogoutBloc`, `CloseCashierBloc`, `SyncOrderBloc`, `AuthLocalDatasource`

---

### 9. `lib/presentation/setting/pages/manage_product_page.dart`

- **Class**: `ManageProductPage`
- **Fitur**: Kelola katalog produk. List semua produk, FAB untuk menambah produk baru ke `AddProductPage`.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `setting_page.dart:59`
- **BLoC / Datasource**: `ProductBloc`

---

### 10. `lib/presentation/setting/pages/add_product_page.dart`

- **Class**: `AddProductPage`
- **Fitur**: Form tambah produk: nama, harga, stok, kategori (dropdown), gambar (image picker), flag bestseller. Validasi dan submit via `ProductBloc`.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `manage_product_page.dart:68` — FAB
- **BLoC / Datasource**: `ProductBloc`, `CategoryBloc`
- **Plugin penting**: `image_picker`

---

### 11. `lib/presentation/setting/pages/manage_printer_page.dart`

- **Class**: `ManagePrinterPage`
- **Fitur**: Pairing & pemilihan Bluetooth thermal printer. Cari paired devices, connect, simpan preferensi printer ke local storage.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `setting_page.dart:69`
- **BLoC / Datasource**: `AuthLocalDatasource` (untuk simpan printer pilihan)
- **Plugin penting**: `print_bluetooth_thermal`, `esc_pos_utils_plus`, `permission_handler` (`bluetoothScan`, `bluetoothConnect`)

---

### 12. `lib/presentation/setting/pages/save_server_key_page.dart`

- **Class**: `SaveServerKeyPage`
- **Fitur**: Konfigurasi Midtrans **server key** untuk pembayaran QRIS. Load key tersimpan, edit, dan save ke local storage.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `setting_page.dart:86`
- **BLoC / Datasource**: `AuthLocalDatasource` (`getMitransServerKey`, `saveMidtransServerKey`)

---

### 13. `lib/presentation/setting/pages/sync_data_page.dart`

- **Class**: `SyncDataPage`
- **Fitur**: Sinkronisasi data antara server dan SQLite lokal. Sync produk, kategori, dan upload pending orders. Multiple BLoC listener mengelola sequence sync.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `setting_page.dart:99`
- **BLoC / Datasource**: `ProductBloc`, `SyncOrderBloc`, `CategoryBloc`, `ProductLocalDatasource`

---

### 14. `lib/presentation/setting/pages/report/report_page.dart`

- **Class**: `ReportPage`
- **Fitur**: Laporan penjualan. Summary revenue & item terjual + tabel detail product sales by date range. Generate **PDF invoice** untuk export/print.
- **Status**: ✅ Used
- **Direferensikan dari**:
  - `setting_page.dart:116`
- **BLoC / Datasource**: `SummaryBloc`, `ProductSalesBloc`, `ReportRemoteDatasource`
- **Plugin penting**: `pdf`, `horizontal_data_table`, `Invoice.generate()`, `HelperPdfService`

---

## Ringkasan

| Kategori | Jumlah |
|---|---|
| Total page ditemukan | 14 |
| ✅ Used | 14 |
| ❌ Unused | 0 |

### Pages by feature group

| Group | Pages |
|---|---|
| **Auth** | `LoginPage` |
| **Navigation root** | `DashboardPage` (bottom nav 4 tab) |
| **Home / Catalog** | `HomePage`, `ScannerPage` |
| **Order / Cart** | `OrderPage`, `DraftOrderPage` |
| **History** | `HistoryPage` |
| **Settings hub** | `SettingPage` |
| **Settings → Product** | `ManageProductPage`, `AddProductPage` |
| **Settings → Printer** | `ManagePrinterPage` |
| **Settings → Payment** | `SaveServerKeyPage` (Midtrans QRIS) |
| **Settings → Sync** | `SyncDataPage` |
| **Settings → Report** | `ReportPage` |

### Catatan & rekomendasi

- **Tidak ada dead page** — semua 14 page terhubung ke navigation graph.
- Walau page-nya semua aktif, masih ada **unused imports** di beberapa page (lihat `flutter analyze` — 88 warning). Bersihkan jika ingin merapikan codebase.
- Ada typo folder `lib/presentation/draft_order/wedgets/` (seharusnya `widgets`). Pertimbangkan rename — tapi hati-hati ada referensi di `draft_order_page.dart`.
- Beberapa BLoC (`bloc_*.dart`) memakai `import 'package:bloc/bloc.dart';` padahal `bloc` bukan direct dependency (hanya transitive lewat `flutter_bloc`). Tambahkan `bloc` ke `pubspec.yaml` atau ganti ke `package:flutter_bloc/flutter_bloc.dart` untuk menghilangkan warning `depend_on_referenced_packages`.
