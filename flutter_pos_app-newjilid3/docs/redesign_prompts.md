# Prompt Redesign — flutter_pos_app

Kumpulan prompt siap pakai untuk redesign UI semua halaman aplikasi POS ini menggunakan Claude (claude.ai / Claude Code). Susunannya:

1. **Master Context Prompt** — paste sekali di awal sesi sebagai system/context
2. **Design System Prompt** — minta Claude bangun foundation (color, typography, component) sebelum redesign per-page
3. **Per-Page Prompts** — 14 prompt khusus untuk tiap halaman
4. **Tips pemakaian**

> **Catatan**: di setiap prompt sudah disisipkan output format (Flutter widget code + Material 3) supaya hasilnya langsung pakai. Sesuaikan jika kamu ingin output Figma spec / wireframe / hanya deskripsi.

---

## 1) Master Context Prompt

Paste ini sekali di awal sesi Claude. Selanjutnya cukup paste prompt per-page.

```
Saya sedang redesign aplikasi Flutter Point-of-Sale (POS) bernama "flutter_pos_app".

Konteks produk:
- Aplikasi kasir untuk UMKM (warung, cafe, retail kecil)
- Target user: kasir & owner toko (umur 20-45, mobile-first)
- Dipakai di tablet & smartphone Android (utamanya), iOS sekunder
- Offline-first: transaksi tetap jalan tanpa internet, sync ke server Laravel saat online
- Bahasa UI: Indonesia

Tech stack:
- Flutter 3.41.9, Dart 3.11.5
- State management: flutter_bloc
- Theme: Material 3 (useMaterial3: true)
- Font: Google Fonts "Quicksand"
- Primary color saat ini: lihat lib/core/constants/colors.dart (AppColors.primary)
- Plugin penting: print_bluetooth_thermal (cetak struk), mobile_scanner (scan QR), pdf, midtrans (QRIS)

Tujuan redesign:
- Modern, bersih, fokus ke kecepatan input kasir
- Hierarki visual jelas: harga & tombol checkout harus paling menonjol
- Touch target minimum 48dp (kasir sering pakai 1 tangan sambil pegang barang)
- Konsisten antar halaman (component reusable)
- Aksesibel: kontras tinggi, font legible bahkan di layar kecil/glare

Format output yang saya inginkan:
1. Deskripsi singkat keputusan desain (layout, hierarki, alasan UX)
2. Kode Flutter widget lengkap (StatelessWidget/StatefulWidget) yang siap di-drop ke project
3. Pakai Material 3, ThemeData yang sudah ada, dan font Quicksand via google_fonts
4. Komentari bagian yang butuh data dari BLoC (placeholder)
5. Jika butuh widget baru/reusable, pisahkan sebagai widget terpisah

Saya akan kirim daftar halaman satu per satu. Tunggu instruksi saya untuk page mana yang akan kita kerjakan dulu.
```

---

## 2) Design System Prompt (kerjakan SEBELUM per-page)

```
Sebelum redesign per-halaman, bantu saya susun design system foundation untuk app POS ini. Output yang saya butuhkan:

1. **Color palette** (light & dark mode)
   - Primary, secondary, tertiary
   - Surface, background, on-surface
   - Success (hijau untuk completed order), warning (kuning untuk pending), error (merah untuk failed payment)
   - Sertakan hex code & alasan singkat

2. **Typography scale** menggunakan Google Fonts Quicksand
   - Display, headline, title, body, label (Material 3 type scale)
   - Tentukan weight (400/500/600/700) per role
   - Berikan sebagai `TextTheme` Flutter

3. **Spacing system** (4pt grid: 4, 8, 12, 16, 24, 32, 48)

4. **Component library** — buatkan Flutter widget untuk:
   - PrimaryButton, SecondaryButton, IconButton (dengan loading state)
   - PriceTag (format Rupiah, ukuran besar)
   - ProductCard (gambar, nama, harga, stock badge)
   - SearchInput dengan QR scan icon
   - EmptyState (icon, judul, deskripsi, optional CTA)
   - LoadingState (skeleton/shimmer)

5. **Output**: satu file `lib/core/theme/app_theme.dart` + folder `lib/core/components/` dengan widget di atas.

Pakai Material 3, gunakan ColorScheme.fromSeed() dengan seed warna primary yang kamu pilih, dan sertakan dark mode.
```

---

## 3) Per-Page Prompts

### 3.1 LoginPage

```
Redesign halaman LOGIN.

File: lib/presentation/auth/pages/login_page.dart

Fitur saat ini:
- Form: email + password
- Tombol Login (memicu LoginBloc)
- State: loading, error, success → navigasi ke DashboardPage

Yang saya inginkan:
- Layout: hero/illustration di atas (atau logo besar), form di tengah, branding di bawah
- Input: outlined TextField, validasi inline, icon prefix (email/lock)
- Password field dengan toggle show/hide
- Tombol login full-width, primary color, dengan loading spinner inline
- Snackbar/Banner untuk error login
- Responsive: di tablet form tidak full-width (max-width ~480dp, center)
- Optional: link "Lupa password?" (placeholder, no logic)

Outputkan kode lengkap halaman + widget reusable jika perlu.
```

### 3.2 DashboardPage (Bottom Navigation Shell)

```
Redesign DASHBOARD — shell dengan bottom navigation.

File: lib/presentation/home/pages/dashboard_page.dart

Tab saat ini: Home, Order, History, Setting

Yang saya inginkan:
- Material 3 NavigationBar (bukan BottomNavigationBar legacy)
- Icon outlined → filled saat aktif
- Label selalu tampil
- Tinggi 80dp, indikator pill di belakang icon aktif
- Background surface dengan elevasi tipis
- Status bar warna mengikuti tab aktif (atau tetap surface)
- Support gesture swipe antar tab (opsional, pakai PageView)

Outputkan kode lengkap StatefulWidget DashboardPage + NavigationDestination per tab.
```

### 3.3 HomePage (Product Catalog)

```
Redesign HOME — halaman utama katalog produk untuk kasir input order.

File: lib/presentation/home/pages/home_page.dart

Fitur saat ini:
- Search bar (dengan tombol QR scan → buka ScannerPage)
- Filter kategori horizontal scrollable
- Grid produk (gambar, nama, harga, stock)
- Tombol cart/note untuk lanjut ke DraftOrderPage
- BLoC: ProductBloc, CategoryBloc

Yang saya inginkan:
- Layout split: di tablet/landscape — grid produk kiri (2/3 lebar), cart preview kanan (1/3)
- Di phone/portrait — grid full, cart sebagai bottom sheet/FAB dengan counter badge
- Product card: image dengan aspect ratio 1:1, nama 2 baris max, harga bold besar, badge stock kalau low
- Category chip: scrollable horizontal, aktif = filled, lainnya = outlined
- Search bar sticky di atas + tombol scan QR di trailing icon
- Empty state untuk hasil filter/search yang kosong
- Loading: skeleton card 6 item

Outputkan kode lengkap + ProductCard sebagai widget terpisah.
```

### 3.4 ScannerPage (QR/Barcode Scanner)

```
Redesign SCANNER QR/barcode.

File: lib/presentation/home/pages/scanner_page.dart

Fitur saat ini:
- Buka kamera, scan barcode/QR
- Hasil dikirim ke ProductBloc.searchProduct
- Pakai mobile_scanner package

Yang saya inginkan:
- Full-screen camera preview
- Overlay gelap dengan "viewport" persegi di tengah (cutout transparan), border putih dengan 4 corner indicator
- Animasi garis scan bergerak vertikal di dalam viewport
- App bar transparan dengan close button (X) dan tombol flash toggle di kanan
- Tombol "Switch Camera" di bottom right
- Instruksi text di bawah viewport: "Arahkan kamera ke barcode produk"
- Saat hasil terbaca → vibrasi + toast/snackbar "Produk ditemukan: {nama}", lalu pop ke HomePage
- Handle permission denied: empty state dengan tombol "Buka Pengaturan"

Outputkan kode lengkap + ScannerOverlay widget terpisah.
```

### 3.5 OrderPage (Cart / Checkout)

```
Redesign ORDER — halaman keranjang & checkout pembayaran.

File: lib/presentation/order/pages/order_page.dart

Fitur saat ini:
- List item order (nama, qty, harga, subtotal)
- Total: subtotal, pajak, grand total
- Pilihan metode pembayaran: Cash, QRIS, Transfer
- Tombol "Simpan Draft" dan "Bayar"
- Print struk via thermal printer setelah bayar
- BLoC: CheckoutBloc, OrderBloc

Yang saya inginkan:
- Section 1 (atas): Header dengan nama order/meja + tombol back
- Section 2: List item dalam Card group, swipe-to-delete, tombol +/- qty inline
- Section 3 (sticky di bawah): Summary card → subtotal, pajak, **Total besar bold**
- Section 4 (bottom sheet atau row): Payment method selector dengan icon + label (Cash icon dompet, QRIS icon QR, Transfer icon bank)
- Tombol "Bayar Sekarang" full-width primary color (warna berubah sesuai metode terpilih)
- Tombol secondary "Simpan Draft" di samping atau di app bar
- Dialog konfirmasi sebelum bayar (tampilkan ringkasan)
- Loading state saat proses pembayaran

Outputkan kode lengkap + OrderItemTile, PaymentMethodSelector sebagai widget terpisah.
```

### 3.6 DraftOrderPage

```
Redesign DRAFT ORDER — daftar order yang disimpan untuk diselesaikan nanti.

File: lib/presentation/draft_order/pages/draft_order_page.dart

Fitur saat ini:
- List draft order (nama, no meja, total)
- Tap → lanjut ke OrderPage untuk pembayaran
- Data dari SQLite lokal via DraftOrderBloc

Yang saya inginkan:
- AppBar dengan judul "Draft Order" + tombol back
- Search/filter (opsional) di atas
- Card per draft: nama order/meja, waktu dibuat (relatif: "5 menit lalu"), jumlah item, total bold
- Swipe action: kiri untuk hapus, kanan untuk lanjutkan
- Tombol primary "Lanjutkan Pembayaran" di card
- Empty state: ilustrasi + "Belum ada draft order" + tombol "Buat Order Baru" → kembali ke HomePage
- Pull-to-refresh

Outputkan kode lengkap + DraftOrderCard widget terpisah.
```

### 3.7 HistoryPage (Transaction History)

```
Redesign HISTORY — riwayat transaksi yang sudah selesai.

File: lib/presentation/history/pages/history_page.dart

Fitur saat ini:
- List transaksi selesai
- Fetch via HistoryBloc

Yang saya inginkan:
- AppBar dengan judul "Riwayat Transaksi"
- Filter chip horizontal: Hari Ini / Minggu Ini / Bulan Ini / Custom Range
- Section header per tanggal (sticky)
- Transaction card: no order, waktu, jumlah item, total bold, badge metode pembayaran (Cash/QRIS/Transfer dengan warna berbeda)
- Tap card → detail bottom sheet (item, total, struk preview, tombol "Cetak Ulang")
- Empty state: "Belum ada transaksi"
- Pull-to-refresh, infinite scroll/pagination

Outputkan kode lengkap + TransactionCard, FilterChips widget terpisah.
```

### 3.8 SettingPage

```
Redesign SETTING — hub menu konfigurasi.

File: lib/presentation/setting/pages/setting_page.dart

Menu saat ini:
- Manage Product
- Manage Printer
- Save QRIS Server Key
- Sync Data
- Report
- Close Cashier
- Logout

Yang saya inginkan:
- Header: profil cashier (avatar, nama, role) dari AuthLocalDatasource
- Group menu dalam section dengan label:
  - "Produk & Penjualan": Manage Product, Report, Close Cashier
  - "Perangkat & Pembayaran": Manage Printer, Save QRIS Server Key
  - "Data": Sync Data
  - "Akun": Logout (warna merah/destructive)
- Tile: leading icon (filled rounded), title, trailing chevron, optional subtitle/badge
- Versi app di bagian paling bawah (centered, abu-abu)
- Logout pakai konfirmasi dialog

Outputkan kode lengkap + SettingTile, SettingSection widget terpisah.
```

### 3.9 ManageProductPage

```
Redesign MANAGE PRODUCT — daftar & kelola produk.

File: lib/presentation/setting/pages/manage_product_page.dart

Fitur saat ini:
- List semua produk
- FAB → AddProductPage

Yang saya inginkan:
- Search bar di atas
- Filter kategori (chip)
- List/grid toggle (icon di app bar)
- Product card: thumbnail, nama, kategori, harga, stock badge (hijau ok / kuning low / merah habis)
- Tap card → edit (sementara navigasi ke AddProductPage dengan data terisi)
- Swipe atau long-press → menu (Edit, Delete, Duplicate)
- FAB extended: "Tambah Produk" dengan icon +
- Empty state untuk produk kosong

Outputkan kode lengkap + ProductManageTile widget terpisah.
```

### 3.10 AddProductPage

```
Redesign ADD PRODUCT — form tambah/edit produk.

File: lib/presentation/setting/pages/add_product_page.dart

Field saat ini:
- Nama produk
- Harga
- Stok
- Kategori (dropdown)
- Gambar (image picker)
- Flag bestseller

Yang saya inginkan:
- Section "Gambar Produk" di atas: image picker square besar dengan placeholder ikon kamera + label "Tap untuk pilih foto"
- Section "Informasi": nama (text), harga (text dengan prefix "Rp" + format ribuan), stok (number stepper +/-)
- Section "Kategori": dropdown atau bottom sheet picker
- Section "Tampilan": switch "Tandai sebagai Bestseller" dengan helper text
- Tombol bottom sticky: "Simpan Produk" full-width primary
- Validasi inline (helper text merah di bawah field)
- Loading state saat submit

Outputkan kode lengkap + ImagePickerField, NumberStepperField widget terpisah.
```

### 3.11 ManagePrinterPage

```
Redesign MANAGE PRINTER — pairing & pilih thermal printer.

File: lib/presentation/setting/pages/manage_printer_page.dart

Fitur saat ini:
- List paired Bluetooth devices
- Connect ke printer
- Simpan printer pilihan
- Pakai print_bluetooth_thermal + permission_handler

Yang saya inginkan:
- AppBar dengan tombol "Scan Ulang" (icon refresh)
- Status banner di atas: "Printer Tersambung: {nama}" hijau ATAU "Belum ada printer" abu-abu
- Section "Perangkat Tersedia": list device card (nama, MAC address, signal strength icon)
- Card device aktif: highlight + badge "Tersambung", tombol "Putuskan"
- Card device lain: tombol "Sambungkan"
- Tombol "Tes Cetak" (mengirim struk test) jika ada printer aktif
- Loading state saat scan/connect
- Handle permission denied dengan empty state CTA

Outputkan kode lengkap + PrinterDeviceCard widget terpisah.
```

### 3.12 SaveServerKeyPage (Midtrans QRIS)

```
Redesign SAVE SERVER KEY — konfigurasi server key Midtrans untuk QRIS.

File: lib/presentation/setting/pages/save_server_key_page.dart

Fitur saat ini:
- Load server key tersimpan
- Edit & save ke local storage

Yang saya inginkan:
- AppBar "Server Key QRIS"
- Info card di atas: penjelasan singkat "Server key dipakai untuk generate QRIS pembayaran via Midtrans. Dapatkan di dashboard Midtrans kamu."
- Input text area / TextField (monospace font karena ini token)
- Tombol show/hide (mata icon) karena ini sensitif
- Helper text: "Server key bersifat rahasia, jangan dibagikan"
- Tombol "Simpan" full-width primary
- Toast/snackbar sukses setelah save
- Link "Cara mendapat server key?" (opsional, buka URL)

Outputkan kode lengkap.
```

### 3.13 SyncDataPage

```
Redesign SYNC DATA — sinkronisasi data antara server & local.

File: lib/presentation/setting/pages/sync_data_page.dart

Fitur saat ini:
- Sync produk, kategori, upload order pending
- BLoC: ProductBloc, SyncOrderBloc, CategoryBloc

Yang saya inginkan:
- Last sync info di atas: "Terakhir sinkron: 2 jam lalu" + status indicator (hijau/kuning)
- List section dengan progress per kategori:
  - Sync Produk: jumlah produk lokal vs server, status icon, tombol "Sync"
  - Sync Kategori: idem
  - Upload Order Pending: jumlah pending, tombol "Upload Sekarang"
- Tombol primary "Sync Semua" di bawah (sticky)
- Linear progress indicator saat sync berjalan
- Log/result list per item (sukses checkmark hijau, gagal X merah dengan reason)
- Empty state jika offline: "Tidak ada koneksi. Pastikan terhubung ke internet."

Outputkan kode lengkap + SyncRowTile widget terpisah.
```

### 3.14 ReportPage

```
Redesign REPORT — laporan penjualan & export PDF.

File: lib/presentation/setting/pages/report/report_page.dart

Fitur saat ini:
- Summary: total revenue, item terjual
- Tabel product sales (pakai horizontal_data_table)
- Filter date range
- Export PDF via Invoice + HelperPdfService
- BLoC: SummaryBloc, ProductSalesBloc

Yang saya inginkan:
- AppBar dengan tombol "Export PDF" (icon download) di trailing
- Date range picker di atas (chip: Hari Ini / 7 Hari / 30 Hari / Custom)
- Section "Ringkasan" — 2-column metric card grid:
  - Total Pendapatan (Rp), Total Transaksi, Item Terjual, Rata-rata per Order
  - Setiap card: label, value bold besar, trend indicator (panah naik/turun + %)
- Section "Penjualan per Produk" — tabel pakai DataTable atau horizontal_data_table (tetap)
  - Kolom: nama produk, qty terjual, total revenue
  - Sortable, scrollable horizontal
- Optional: chart bar/line sederhana untuk trend 7 hari
- Loading: skeleton metric card
- Empty state untuk range tanpa transaksi

Outputkan kode lengkap + MetricCard, DateRangePicker widget terpisah.
```

---

## 4) Tips Pemakaian

### Workflow rekomendasi

1. **Paste Master Context** di awal sesi Claude (sekali saja).
2. **Jalankan Design System Prompt** dulu — hasil ini jadi foundation semua page.
3. **Redesign page berurutan** dari yang paling sering dipakai user:
   - LoginPage → DashboardPage → HomePage → OrderPage → HistoryPage → SettingPage
   - Lalu sub-page setting satu-satu
4. **Konsisten gunakan reusable widget** yang dibuat dari Design System (PrimaryButton, ProductCard, etc.) — minta Claude refer ke widget tersebut, jangan bikin baru.

### Tweak prompt

- Tambah **"Ikuti reference dari [URL/screenshot]"** jika kamu punya inspirasi (misal Linear, Notion, Stripe).
- Tambah **"Pakai dark mode sebagai default"** jika perlu.
- Tambah **"Buat juga unit test untuk widget"** jika mau coverage.
- Ganti **"kode Flutter"** menjadi **"Figma spec dalam markdown"** kalau kamu mau wireframe dulu sebelum coding.

### Penting

- Sebelum apply, **review** apakah BLoC events/states masih kompatibel dengan UI baru. Kalau berubah, refactor BLoC di pass terpisah.
- Generate kode Claude **bukan pengganti testing manual** — jalankan di emulator/device setelah implementasi.
- Untuk halaman dengan plugin native (`mobile_scanner`, `print_bluetooth_thermal`), pastikan permission flow di-test di device fisik.
