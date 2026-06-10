# 45 — Play Store Prep: ReceiptSettings, Privacy Policy, ProGuard, Release Signing, Permission Rationale

## Goal

Polish akhir untuk siap rilis Play Store:
1. `ReceiptSettingsPage` (kustomisasi branding struk + logo).
2. `PrivacyPolicyPage` (in-app + link web).
3. In-app delete account (sudah ada step 36 — pastikan flow lengkap).
4. ProGuard/R8 rules untuk minify.
5. Release signing setup.
6. Permission rationale untuk kamera, storage, bluetooth, lokasi.

## Prerequisite

- Step 44 selesai.

## Konsep yang diajarkan

- **Privacy Policy** wajib Play Store untuk app yang collect user data.
- **In-app delete account** wajib sejak 2024.
- **ProGuard/R8** strip dead code + obfuscate.
- **Upload key vs signing key** (Play App Signing recommendation).

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app` siap pre-rilis. Generate 6 file/config.

═══════════════════════════════════════════════
FILE 1: lib/presentation/setting/pages/receipt_settings_page.dart
═══════════════════════════════════════════════
StatefulWidget form untuk `ReceiptBranding`:
- TextField: storeName, addressLine1, addressLine2, email, phone, footerLine1, footerLine2.
- Logo: tap → image_picker (galeri) → resize ke max 256px width pakai `package:image` → base64 encode → preview.
- AppButton Simpan → AuthLocalDatasource().saveReceiptBranding(branding).

═══════════════════════════════════════════════
FILE 2: lib/presentation/setting/pages/privacy_policy_page.dart
═══════════════════════════════════════════════
```dart
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(title: 'Privacy Policy'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Privacy Policy POS Cafe', style: AppTypography.titleL.copyWith(color: p.onSurface)),
        const SpaceHeight(8),
        Text('Terakhir diperbarui: ${DateTime.now().year}', style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar)),
        const SpaceHeight(16),
        // Section: Data yang dikumpulkan
        Text('1. Data yang Kami Kumpulkan', style: AppTypography.titleM),
        const SpaceHeight(8),
        Text('Aplikasi POS Cafe mengumpulkan data berikut untuk operasional kasir:\n\n'
            '• Identitas akun: email, nama, peran kasir\n'
            '• Data transaksi: order, item, total, metode pembayaran\n'
            '• Data perangkat: alamat MAC printer (lokal saja)\n'
            '• Catatan: konfigurasi opsional (QRIS server key, branding struk)\n'
            '\nKami TIDAK mengakses kontak, foto pribadi, lokasi presisi, atau '
            'aktivitas browser Anda.', style: AppTypography.bodyM),
        const SpaceHeight(16),
        Text('2. Penyimpanan', style: AppTypography.titleM),
        const SpaceHeight(8),
        Text('• Token autentikasi disimpan terenkripsi di Android Keystore.\n'
            '• Server key QRIS disimpan di SharedPreferences perangkat (tidak '
            'pernah dikirim ke server kami).\n'
            '• Order history disimpan di SQLite lokal + diunggah ke backend Anda.', style: AppTypography.bodyM),
        const SpaceHeight(16),
        Text('3. Hapus Akun', style: AppTypography.titleM),
        const SpaceHeight(8),
        Text('Anda dapat menghapus akun kapan saja via Setting → Hapus Akun. '
            'Aksi ini permanen dan menghapus semua data Anda dari server.', style: AppTypography.bodyM),
        const SpaceHeight(16),
        Text('4. Kontak', style: AppTypography.titleM),
        const SpaceHeight(8),
        InkWell(
          onTap: () => launchUrl(Uri.parse('mailto:privacy@yourdomain.com')),
          child: Text('privacy@yourdomain.com',
            style: AppTypography.bodyM.copyWith(color: p.primary, decoration: TextDecoration.underline)),
        ),
        const SpaceHeight(24),
        AppButton.outline(
          label: 'Versi Lengkap (Web)', leadingIcon: Icons.open_in_new,
          onPressed: () => launchUrl(Uri.parse('https://yourdomain.com/privacy')),
        ),
      ]),
    );
  }
}
```

═══════════════════════════════════════════════
FILE 3: android/app/proguard-rules.pro
═══════════════════════════════════════════════
```
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Bluetooth printer
-keep class com.aqupd.print_bluetooth_thermal.** { *; }

# MobileScanner / MLKit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.mlkit.**

# PDF
-keep class com.tom_roush.** { *; }
```

═══════════════════════════════════════════════
FILE 4: android/app/build.gradle (release config)
═══════════════════════════════════════════════
Update `android { defaultConfig { ... } buildTypes { release { ... } } }`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            }
        }
    }
    buildTypes {
        release {
            signingConfig keystorePropertiesFile.exists()
                ? signingConfigs.release : signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                          'proguard-rules.pro'
        }
    }
}
```

═══════════════════════════════════════════════
FILE 5: android/key.properties.example
═══════════════════════════════════════════════
```
storeFile=../keystore/poscafe-release.jks
storePassword=
keyAlias=poscafe
keyPassword=
```

Plus `android/keystore/.gitkeep` dan update `.gitignore`:
```
android/key.properties
android/keystore/*.jks
android/keystore/*.keystore
```

═══════════════════════════════════════════════
FILE 6: docs/SIGNING.md
═══════════════════════════════════════════════
Dokumentasi: cara generate keystore, setup key.properties, build release. Termasuk warning: "jangan upload .jks ke git, simpan password di password manager, lost keystore = lost ability to update app on Play".

═══════════════════════════════════════════════
STEP 7: AndroidManifest permission rationale
═══════════════════════════════════════════════
Pastikan AndroidManifest.xml ada permission lengkap dengan rationale Indonesia di Play Console listing:
- CAMERA → "Untuk scan barcode produk."
- READ_MEDIA_IMAGES (Android 13+) → "Untuk pilih foto produk."
- BLUETOOTH_CONNECT/SCAN → "Untuk pairing & cetak ke printer thermal Bluetooth."
- INTERNET → "Untuk sinkronisasi data dengan server."
- ACCESS_NETWORK_STATE → "Untuk deteksi koneksi."

═══════════════════════════════════════════════
STEP 8: Build release
═══════════════════════════════════════════════
```bash
flutter build appbundle --release --dart-define=BASE_URL=https://prod.api.example.com
```

Output: `build/app/outputs/bundle/release/app-release.aab` → upload ke Play Console.
````

---

## Verifikasi

1. Setting → Pengaturan Struk → ubah branding → cetak ulang struk → header sesuai.
2. Setting → Privacy Policy → halaman tampil dengan section lengkap.
3. Hapus Akun flow end-to-end → akun hilang dari BE + local cleared.
4. `flutter build appbundle --release` sukses.
5. Install release APK di HP fisik → semua fitur jalan (kamera, printer, login, transaksi).

## Talking points

1. **Play Store policy: Privacy Policy wajib**:
   App yang collect any user data (email, transaction) wajib Privacy Policy. URL listing + in-app. Tanpa ini, reject.

2. **In-app delete account (Mandate 2024)**:
   App dengan login wajib provide delete account in-app, bukan via "email kami". Step 36 sudah ada flow-nya.

3. **ProGuard/R8 strip**:
   `minifyEnabled true` di release. Hilangkan unused code → APK lebih kecil 30-50%. Tapi bisa break reflection-based code (Flutter plugins). Pakai `-keep` rules untuk pengecualian.

4. **Upload key vs Signing key**:
   - Play App Signing (default sejak 2021): kita kirim upload key, Google sign dengan their key. Lost upload key → reset via Play Console (mudah).
   - Tanpa Play App Signing: kita kirim signing key langsung. Lost → ga bisa update app (catastrophic).
   - **Selalu pakai Play App Signing**.

5. **Keystore safety**:
   - Backup `.jks` + 2 password di password manager.
   - Tidak commit ke git.
   - Tidak share via chat.

6. **`--dart-define=BASE_URL=...` di release**:
   Override variable env. Sandbox/staging/prod pakai endpoint berbeda tanpa rebuild code.

## Commit suggestion

```bash
git add lib/presentation/setting/pages/receipt_settings_page.dart lib/presentation/setting/pages/privacy_policy_page.dart android/app/proguard-rules.pro android/app/build.gradle android/key.properties.example .gitignore docs/SIGNING.md
git commit -m "Step 45: Play Store prep — receipt settings, privacy policy, ProGuard, release signing"
```

---

🎉 **Selesai!** Aplikasi POS Batch 11 lengkap, siap rilis Play Store.

Smoke test akhir:
- [ ] Login → BukaKasir → buka shift.
- [ ] HomePage: scan/add produk → cart.
- [ ] OrderPage: apply promo voucher → bayar cash → cetak struk.
- [ ] OrderPage: bayar QRIS → polling success → cetak.
- [ ] HistoryPage: filter range → buka detail → refund.
- [ ] TutupKasir: variance 0 → close → logout.
- [ ] Re-login → langsung BukaKasir lagi.
- [ ] Sinkronisasi: matikan wifi → bikin order → nyalakan wifi → auto sync.
- [ ] Setting → ganti palette → seluruh app re-color.
- [ ] Setting → Hapus akun → kembali ke login, akun hilang dari BE.

---

➡️ Kembali ke [README](./README.md)
