# 21 — ScannerPage (mobile_scanner + Camera Permission)

## Goal

`ScannerPage` full-screen: kamera + overlay (vignette + corner brackets + scan line animated), permission handling (graceful denied state + buka pengaturan), torch toggle, switch kamera. On detect → `ProductBloc.searchProduct(code)` + pop.

## Prerequisite

- Step 20 selesai.
- Package `mobile_scanner: ^5.2.1`, `permission_handler: ^11.3.1`. Atom `ScannerOverlay` (step 09).

## Konsep yang diajarkan

- **Runtime permission Android** — `Permission.camera.request()`.
- **Lifecycle observer** (`WidgetsBindingObserver.didChangeAppLifecycleState`) — pause/resume kamera saat app background.
- **`StreamSubscription`** — listen ke `_controller.barcodes`, cancel di dispose.
- **`ValueListenableBuilder`** untuk torch state.
- **Android manifest**: butuh `<uses-permission android:name="android.permission.CAMERA"/>`.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada: `ScannerOverlay` widget (step 09), `ProductBloc` (step 19), `feedback.dart`. Package `mobile_scanner`, `permission_handler` di pubspec.

═══════════════════════════════════════════════
STEP 1: Android permission
═══════════════════════════════════════════════
Edit `android/app/src/main/AndroidManifest.xml`, tambah di dalam `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

Untuk Android 13+ (target SDK 33+), tambahkan di `<application>`:
```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="barcode"/>
```

═══════════════════════════════════════════════
STEP 2: iOS permission
═══════════════════════════════════════════════
Edit `ios/Runner/Info.plist`, tambah:
```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan akses kamera untuk scan barcode produk.</string>
```

═══════════════════════════════════════════════
FILE: lib/presentation/home/pages/scanner_page.dart
═══════════════════════════════════════════════
`ScannerPage extends StatefulWidget`. State `with WidgetsBindingObserver`.

Field:
- `_controller = MobileScannerController(autoStart: false, torchEnabled: false, useNewCameraSelector: true)`.
- `StreamSubscription<BarcodeCapture>? _sub`.
- `bool _processed = false` (guard supaya tidak proses 2x kode yang sama).
- `bool _permissionDenied = false`.

Lifecycle:
- `initState`: `WidgetsBinding.instance.addObserver(this); unawaited(_bootstrap());`
- `dispose`: removeObserver, cancel sub, super.dispose, lalu await `_controller.dispose()`.

`_bootstrap()`:
1. `final status = await Permission.camera.request();`
2. Kalau `!mounted` return.
3. Kalau bukan granted → setState `_permissionDenied = true`; return.
4. `_sub = _controller.barcodes.listen(_onBarcode); unawaited(_controller.start());`

`_onBarcode(BarcodeCapture capture)`:
- Kalau `_processed || !mounted` return.
- `code = capture.barcodes.firstOrNull?.displayValue`.
- Kalau null/empty return.
- `_processed = true; unawaited(_controller.stop());`
- `context.read<ProductBloc>().add(ProductEvent.searchProduct(code));`
- `AppSnackbar.info(context, 'Ditemukan: $code');`
- `Navigator.maybePop(context);`

`didChangeAppLifecycleState`:
- Kalau `!_controller.value.isInitialized` return.
- `resumed`: re-listen + start.
- `inactive`: cancel sub + stop controller.
- Lainnya (detached/hidden/paused): no-op.

Build (kalau `_permissionDenied` → `_PermissionDeniedView`):
- `Scaffold(bg const Color(0xFF0E0A06))` (dark coffee).
- Stack:
  - `MobileScanner(controller: _controller)`.
  - `Positioned.fill(child: ScannerOverlay())`.
  - Top action row (SafeArea > Padding 12/8/12/0 > Row):
    - `_RoundDarkButton(close, onTap: maybePop)`.
    - Spacer, Text 'Scan Produk' (titleM, white), Spacer.
    - `ValueListenableBuilder(_controller, builder: state) → _RoundDarkButton(state.torchState==on ? flash_on : flash_off_outlined, onTap: toggleTorch)`.
  - Positioned(top:100, left:0, right:0, Center > Text 'Arahkan kamera ke barcode atau QR' bodyM white).
  - Positioned(bottom:0, left:0, right:0, SafeArea(top:false) > Container padding 16/24/16/16 gradient transparent→#E60E0A06):
    - Column.min:
      - Pill 'Mencari kode...' (Container bg black@0.45, radius pill, Row: dot 8×8 green success + spacing 8 + Text labelM white).
      - SpaceHeight 16.
      - Row: Expanded `_BottomAction(label: 'Balik kamera', icon: cameraswitch_outlined, onTap: switchCamera)`. SpaceWidth 12. Expanded `_BottomAction(label: 'Input manual', icon: keyboard_outlined, highlighted: true, onTap: maybePop)`.

`_PermissionDeniedView`:
- Scaffold dark bg.
- Column: tombol close kiri, Spacer, Icon no_photography_outlined 56px white@0.7, SpaceHeight 16, Title 'Akses kamera ditolak' titleM white center, SpaceHeight 8, Text 'Untuk memindai... Izinkan akses kamera di pengaturan perangkat.' bodyM white@0.7 center, SpaceHeight 24, `_BottomAction(label: 'Buka Pengaturan', icon: settings_outlined, highlighted: true, onTap: openAppSettings)` (openAppSettings dari permission_handler), SpaceHeight 12, `_BottomAction(label: 'Input manual', icon: keyboard, onTap: maybePop)`, Spacer.

`_RoundDarkButton`:
- StatelessWidget: icon + onTap. Container 40×40, bg black@0.45, shape circle, Icon white 20px. Wrap InkResponse(onTap, radius:24).

`_BottomAction`:
- StatelessWidget: label, icon, onTap, highlighted=false. Container 52h, padding h:14, bg `highlighted ? p.primary : white@0.18`, radius mdAll. Row.center: Icon 18 fg, SpaceWidth 8, Text labelL.copyWith(fg, w700).

═══════════════════════════════════════════════
STEP 3: HomePage wire scanner button
═══════════════════════════════════════════════
Di `home_page.dart` (step 20), pastikan tombol scan di `_SearchAndScan` push `ScannerPage`:
```dart
onTap: () => Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const ScannerPage()),
),
```
````

---

## Verifikasi

1. Run app → HomePage → tap icon QR di search bar.
2. Pertama kali: minta permission kamera. Tap "Allow" → kamera + overlay tampil.
3. Tap "Deny" → tampil `_PermissionDeniedView` dengan tombol "Buka Pengaturan".
4. Scan QR sembarang → snackbar "Ditemukan: <code>" → kembali ke HomePage dengan search filter applied.
5. Tap flash icon → torch on/off.
6. App ke background → kamera mati. Kembali ke app → kamera nyala lagi.

## Talking points

1. **`permission_handler` vs implicit request**:
   `mobile_scanner` minta permission sendiri saat start. Tapi kalau user deny, tampil black screen tanpa pesan. Kita explicit minta dulu → kalau denied, tampilkan UX bermakna ("Buka Pengaturan").

2. **`WidgetsBindingObserver`**:
   Tanpa ini, kamera tetap nyala saat app background → battery drain + privacy concern. Pattern wajib untuk apps dengan camera/microphone.

3. **`StreamSubscription` cancel di dispose**:
   `mobile_scanner` emit barcode lewat `Stream`. Subscriber bisa "hidup" lebih lama dari widget kalau tidak cancel → memory leak + callback ke unmounted state.

4. **`_processed` guard**:
   Camera fire `onBarcode` setiap frame. Tanpa guard, 1 QR scan bisa trigger callback puluhan kali → multiple navigation pop crash.

5. **`firstOrNull` Dart 3**:
   `capture.barcodes.firstOrNull` return null kalau list empty. Sebelum Dart 3 harus `.isEmpty ? null : .first`.

6. **`ValueListenableBuilder` untuk torch**:
   `_controller` adalah `ValueNotifier`. Pakai `ValueListenableBuilder` untuk rebuild widget yang depend on torch state, tanpa setState di widget besar.

7. **Android manifest barcode dependency**:
   `<meta-data ... DEPENDENCIES value="barcode"/>` membuat ML Kit barcode model didownload saat install (bukan lazy). Tanpa ini, scan pertama bisa delay 1-3 detik download model.

## Commit suggestion

```bash
git add lib/presentation/home/pages/scanner_page.dart android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist
git commit -m "Step 21: ScannerPage with permission + lifecycle + torch + overlay"
```

---

➡️ Lanjut ke [Step 22 — CheckoutBloc](./22-checkout-bloc.md)
