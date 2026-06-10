# 13 — Auth Local Datasource (Secure Storage + SharedPreferences)

## Goal

`AuthLocalDatasource` yang menyimpan: (a) auth token di `flutter_secure_storage` (Android Keystore), (b) printer MAC + paper size + QRIS server key + receipt branding di `SharedPreferences`. Plus model `ReceiptBranding`.

## Prerequisite

- Step 12 (model `User`/`AuthResponseModel`) selesai.
- Package `flutter_secure_storage`, `shared_preferences` sudah di pubspec.

## Konsep yang diajarkan

- **`flutter_secure_storage`** vs `SharedPreferences` — kapan pakai mana.
- **Android Keystore (`encryptedSharedPreferences: true`)** — encrypt at-rest.
- **Legacy migration** — read dari lokasi lama, tulis ke lokasi baru, hapus lama.
- **Why obfuscate key names** — QRIS server key disimpan dengan key `'pt_v1'` (payment_token v1) bukan `'midtrans_server_key'` supaya prefs dump tidak teriak "MIDTRANS".

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada model `AuthResponseModel` (step 10). Package `flutter_secure_storage`, `shared_preferences` sudah di-install.

Generate 2 file.

═══════════════════════════════════════════════
FILE 1: lib/data/models/receipt_branding.dart
═══════════════════════════════════════════════
`class ReceiptBranding`:
- Field semua final, defaultValue `''`:
  - `storeName, addressLine1, addressLine2, email, phone, footerLine1, footerLine2, logoBase64`.
- `const` constructor named params.
- `copyWith({...semua optional})` return baru.
- Getter `bool get hasLogo => logoBase64.isNotEmpty`.

Komen di atas class: dipakai untuk header & footer struk, di-load sekali per print job.

═══════════════════════════════════════════════
FILE 2: lib/data/datasources/auth_local_datasource.dart
═══════════════════════════════════════════════
```dart
import 'package:flutter_pos_app/data/models/receipt_branding.dart';
import 'package:flutter_pos_app/data/models/response/auth_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDatasource {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Key constants — gunakan nama kabur untuk payment token supaya prefs dump
  // tidak yelling "MIDTRANS".
  static const _kAuthData = 'auth_data';
  static const _kPaymentToken = 'pt_v1';
  static const _kPaymentEnabled = 'pt_v1_on';
  static const _kPrinter = 'printer';
  static const _kPaperSize = 'printer_paper_size'; // '58' | '80'

  // Receipt branding keys
  static const _kRcStoreName = 'receipt_store_name';
  static const _kRcAddr1 = 'receipt_addr_line1';
  static const _kRcAddr2 = 'receipt_addr_line2';
  static const _kRcEmail = 'receipt_email';
  static const _kRcPhone = 'receipt_phone';
  static const _kRcFooter1 = 'receipt_footer_line1';
  static const _kRcFooter2 = 'receipt_footer_line2';
  static const _kRcLogoB64 = 'receipt_logo_b64';

  // ── Auth ────────────────────────────────────────────────────────────────

  Future<void> saveAuthData(AuthResponseModel data) async {
    await _secure.write(key: _kAuthData, value: data.toJson());
    // Hapus dari prefs jika ada (legacy lokasi).
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthData);
  }

  Future<void> removeAuthData() async {
    await _secure.delete(key: _kAuthData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthData);
  }

  Future<AuthResponseModel> getAuthData() async {
    final raw = await _readAuthRaw();
    return AuthResponseModel.fromJson(raw!);
  }

  Future<bool> isAuth() async => (await _readAuthRaw()) != null;

  /// Baca dari secure; kalau tidak ada, migrate dari prefs (legacy install).
  Future<String?> _readAuthRaw() async {
    final fromSecure = await _secure.read(key: _kAuthData);
    if (fromSecure != null) return fromSecure;
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_kAuthData);
    if (legacy != null) {
      await _secure.write(key: _kAuthData, value: legacy);
      await prefs.remove(_kAuthData);
      return legacy;
    }
    return null;
  }

  // ── Payment gateway (QRIS / Midtrans) ──────────────────────────────────

  Future<void> saveMidtransServerKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaymentToken, key);
    await prefs.remove('server_key'); // legacy key
  }

  Future<String> getMitransServerKey() async {
    final prefs = await SharedPreferences.getInstance();
    final newer = prefs.getString(_kPaymentToken);
    if (newer != null) return newer;
    final legacy = prefs.getString('server_key');
    if (legacy != null) {
      await prefs.setString(_kPaymentToken, legacy);
      await prefs.remove('server_key');
      return legacy;
    }
    return '';
  }

  Future<void> setMidtransEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPaymentEnabled, enabled);
  }

  /// Default false → QRIS tab hidden sampai cashier explicit enable.
  Future<bool> isMidtransEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPaymentEnabled) ?? false;
  }

  // ── Printer ────────────────────────────────────────────────────────────

  Future<void> savePrinter(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrinter, mac);
  }

  Future<String> getPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrinter) ?? '';
  }

  Future<String> getPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPaperSize) ?? '58';
  }

  Future<void> savePaperSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaperSize, size);
  }

  // ── Receipt branding ───────────────────────────────────────────────────

  static const ReceiptBranding _defaultBranding = ReceiptBranding(
    storeName: 'Toko Saya',
    addressLine1: '',
    addressLine2: '',
    email: '',
    phone: '',
    footerLine1: 'Terima kasih',
    footerLine2: '',
  );

  Future<ReceiptBranding> getReceiptBranding() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_kRcStoreName)) return _defaultBranding;
    return ReceiptBranding(
      storeName: prefs.getString(_kRcStoreName) ?? '',
      addressLine1: prefs.getString(_kRcAddr1) ?? '',
      addressLine2: prefs.getString(_kRcAddr2) ?? '',
      email: prefs.getString(_kRcEmail) ?? '',
      phone: prefs.getString(_kRcPhone) ?? '',
      footerLine1: prefs.getString(_kRcFooter1) ?? '',
      footerLine2: prefs.getString(_kRcFooter2) ?? '',
      logoBase64: prefs.getString(_kRcLogoB64) ?? '',
    );
  }

  Future<void> saveReceiptBranding(ReceiptBranding b) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRcStoreName, b.storeName);
    await prefs.setString(_kRcAddr1, b.addressLine1);
    await prefs.setString(_kRcAddr2, b.addressLine2);
    await prefs.setString(_kRcEmail, b.email);
    await prefs.setString(_kRcPhone, b.phone);
    await prefs.setString(_kRcFooter1, b.footerLine1);
    await prefs.setString(_kRcFooter2, b.footerLine2);
    await prefs.setString(_kRcLogoB64, b.logoBase64);
  }
}
```

═══════════════════════════════════════════════
TAMBAHAN: konfigurasi Android
═══════════════════════════════════════════════
`flutter_secure_storage` butuh `minSdkVersion >= 18`. Beri tahu saya cek di `android/app/build.gradle` (atau `build.gradle.kts`):
```gradle
defaultConfig {
    minSdkVersion 21  // 21+ wajib, 18 minimum
}
```
````

---

## Verifikasi

```dart
Future<void> testAuthLocal() async {
  final auth = AuthLocalDatasource();
  await auth.saveAuthData(AuthResponseModel(
    user: User(id: 1, name: 'Test', email: 'a@b.c', phone: '08', roles: 'kasir'),
    token: 'fake-token-123',
  ));
  final isAuth = await auth.isAuth();
  debugPrint('isAuth: $isAuth'); // true
  final data = await auth.getAuthData();
  debugPrint('Token: ${data.token}'); // fake-token-123
  await auth.removeAuthData();
}
```

## Talking points

1. **`flutter_secure_storage` vs `SharedPreferences`**:
   - Secure storage encrypted at-rest (Android Keystore / iOS Keychain). Pakai untuk: token bearer, server key payment, credentials.
   - SharedPreferences plain XML. Pakai untuk: device preferences (printer MAC, theme, default paper size), data yang ok kalau bocor.
   - **Trade-off**: secure storage 100x lebih lambat baca/tulis. Jangan dipakai untuk data yang sering di-poll.

2. **`encryptedSharedPreferences: true`**:
   Android Keystore backed. Lebih cepat daripada default (file per key) dan handle migration automatic.

3. **`minSdkVersion 21`**:
   Flutter default sekarang 21 (Android 5.0+). Kalau pakai `flutter_secure_storage` versi terbaru, butuh 18 minimum. Pesan ke peserta: cek build.gradle setiap install package native plugin.

4. **Legacy migration pattern**:
   Saat pindah lokasi storage (mis. dari prefs ke secure), JANGAN langsung break user lama. Read-old → write-new → delete-old, 1x per launch. Setelah beberapa rilis (semua user sudah migrate), bersihkan kode legacy.

5. **Obfuscated key names** (`pt_v1` bukan `midtrans_server_key`):
   Defensive coding. Casual prefs dump (via adb backup atau via curiosity bug report) gak akan instantly reveal payment gateway. Trade-off: maintainer lain mungkin bingung — kasih komen di code yang jelas.

6. **`_defaultBranding`** vs nullable:
   User baru install belum set branding. Daripada UI render `null name → crash`, kita siapkan default. User open Receipt Settings → save → override.

7. **`isMidtransEnabled() ?? false`** default false:
   Opt-in toggle. Banyak kafe gak punya QRIS akun — sembunyi sampai eksplisit di-enable. Pattern Play Store-friendly: jangan expose fitur payment yang belum siap.

## Commit suggestion

```bash
git add lib/data/models/receipt_branding.dart lib/data/datasources/auth_local_datasource.dart
git commit -m "Step 13: auth local datasource (secure storage + prefs + receipt branding)"
```

---

➡️ Lanjut ke [Step 14 — ThemeBloc](./14-theme-bloc.md)
