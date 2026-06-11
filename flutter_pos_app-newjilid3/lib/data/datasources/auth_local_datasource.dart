import 'package:flutter_pos_app/data/models/receipt_branding.dart';
import 'package:flutter_pos_app/data/models/response/auth_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for authentication + lightweight device-scoped settings.
///
/// Two backing stores:
///   * `FlutterSecureStorage` — backed by Android Keystore (EncryptedSharedPreferences)
///     and iOS Keychain. Holds the Sanctum bearer token (auth_data).
///   * `SharedPreferences` — for non-credential values (printer MAC, payment
///     gateway token enable/disable flag, the obfuscated payment token).
///
/// Why the payment token isn't in secure storage: the operator explicitly
/// chose to keep it in plain prefs with an obfuscated key name + an opt-in
/// toggle, trading a layer of at-rest encryption for simpler ops. If that
/// trade-off changes, move `_kPaymentToken` to `_secure.write` here only —
/// no callsite changes needed.
class AuthLocalDatasource {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kAuthData = 'auth_data';
  // Renamed from `server_key` so a casual prefs dump doesn't yell "midtrans".
  static const _kPaymentToken = 'pt_v1';
  static const _kPaymentEnabled = 'pt_v1_on';
  static const _kPrinter = 'printer';
  static const _kPaperSize = 'printer_paper_size'; // '58' | '80'

  // Tax / PB1 — disimpan sebagai integer percent 0-100 (mis. 10 = 10%).
  // Default 0 = tax tidak diaplikasikan ke order.
  static const _kTaxPercent = 'tax_percent';

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

  Future<void> saveAuthData(AuthResponseModel authResponseModel) async {
    await _secure.write(key: _kAuthData, value: authResponseModel.toJson());
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

  Future<bool> isAuth() async {
    final raw = await _readAuthRaw();
    return raw != null;
  }

  /// Reads the auth blob from secure storage, with a one-time migration
  /// from the legacy `SharedPreferences['auth_data']` location.
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

  Future<void> saveMidtransServerKey(String serverKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaymentToken, serverKey);
    await prefs.remove('server_key');
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

  /// Opt-in toggle. Defaults to `false` so QRIS stays hidden until the
  /// cashier explicitly enables it on the payment-settings page.
  Future<bool> isMidtransEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPaymentEnabled) ?? false;
  }

  // ── Printer ────────────────────────────────────────────────────────────

  Future<void> savePrinter(String printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrinter, printer);
  }

  Future<String> getPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrinter) ?? '';
  }

  /// Persisted thermal paper width. Defaults to `'58'` for first-run installs.
  Future<String> getPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPaperSize) ?? '58';
  }

  Future<void> savePaperSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaperSize, size);
  }

  // ── Receipt branding ───────────────────────────────────────────────────

  /// First-run defaults match the legacy hardcoded struk identity. They
  /// only apply until the user opens "Pengaturan Struk" once and presses
  /// Simpan — after that, whatever they saved (including empty fields)
  /// is authoritative.
  static const ReceiptBranding _defaultBranding = ReceiptBranding(
    storeName: 'BEBEK GORENG CaK SLAMET',
    addressLine1: '',
    addressLine2: '',
    email: '',
    phone: '',
    footerLine1: 'Enak, Gurih, Nagih!',
    footerLine2: 'Terima kasih atas kunjungan Anda',
  );

  Future<ReceiptBranding> getReceiptBranding() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_kRcStoreName)) {
      return _defaultBranding;
    }
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

  // ── Tax (PB1) ─────────────────────────────────────────────────────────

  /// Cached value untuk hindari re-read SharedPreferences setiap rebuild
  /// order_page. Refresh saat aplikasi start + setiap kali tax diubah di
  /// Receipt Settings page.
  static int _cachedTaxPercent = 0;
  static bool _taxLoaded = false;

  /// Tax percentage 0-100 (mis. 10 = 10% PB1). Cached setelah first read.
  Future<int> getTaxPercent() async {
    if (_taxLoaded) return _cachedTaxPercent;
    final prefs = await SharedPreferences.getInstance();
    _cachedTaxPercent = prefs.getInt(_kTaxPercent) ?? 0;
    _taxLoaded = true;
    return _cachedTaxPercent;
  }

  /// Sync cache untuk dipakai di UI yang tidak bisa await (rebuild).
  /// Panggil [getTaxPercent] sekali saat app start untuk warmup cache.
  int getTaxPercentSync() => _cachedTaxPercent;

  Future<void> setTaxPercent(int percent) async {
    final clamped = percent.clamp(0, 100);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTaxPercent, clamped);
    _cachedTaxPercent = clamped;
    _taxLoaded = true;
  }
}
