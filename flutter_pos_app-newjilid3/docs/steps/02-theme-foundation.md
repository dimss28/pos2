# 02 — Theme Foundation (Palette, Spacing, Radius, Typography, AppTheme)

## Goal

Sistem desain (design tokens) fondasi: 3 palette warna, grid spacing 4pt, scale radius, typography Quicksand. Tema bisa di-akses dari semua widget via `Theme.of(context).extension<AppPalette>()` atau extension shortcut `context.palette`.

## Prerequisite

- Step 01 selesai (folder `lib/core/theme/` sudah ada).

## Konsep yang diajarkan

- **Design token**: konstanta visual (warna, ukuran, radius, font) yang dipusatkan supaya konsisten + mudah diganti.
- **`ThemeData` Material 3 + `ColorScheme.fromSeed`**: cara Flutter modern bridging warna brand ke widget bawaan.
- **`ThemeExtension`**: cara nambah token semantik yang gak tersedia di `ColorScheme` (mis. `success`, `warning`, `onSurfaceVar`) tanpa keluar dari sistem theme.
- **`extension` (Dart language feature)**: sugar untuk akses singkat (`context.palette` daripada `Theme.of(context).extension<AppPalette>()!`).
- **`GoogleFonts.quicksand`**: load font on-demand dengan cache.

---

## Prompt siap kirim ke AI

````
Saya pakai project Flutter `flutter_pos_app` dengan struktur folder layer-first. Sekarang saya mau setup design system foundation.

Generate 5 file di `lib/core/theme/`:

═══════════════════════════════════════════════
FILE 1: lib/core/theme/app_spacing.dart
═══════════════════════════════════════════════
Class `AppSpacing` dengan private constructor, berisi konstanta double untuk grid 4pt:
- xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24, xxxl = 32, huge = 40, mega = 48

═══════════════════════════════════════════════
FILE 2: lib/core/theme/app_radius.dart
═══════════════════════════════════════════════
Class `AppRadius` dengan private constructor, berisi:
- Konstanta double: xs=6, sm=10, md=14, lg=20, xl=28, pill=999
- Konstanta `BorderRadius` ready-pakai (gunakan `const BorderRadius.all(Radius.circular(N))`):
  xsAll, smAll, mdAll, lgAll, xlAll, pillAll

═══════════════════════════════════════════════
FILE 3: lib/core/theme/app_typography.dart
═══════════════════════════════════════════════
Class `AppTypography` dengan private constructor. Pakai `google_fonts` (`GoogleFonts.quicksand(...)`).

Helper privat `_t({double size, FontWeight weight, double lh, double letterSpacing = 0})` yang return `TextStyle` dengan `height: lh / size`.

Static final `TextStyle`:
| Token     | size | weight | lh | letterSpacing |
|-----------|------|--------|----|---------------|
| displayL  | 32   | w700   | 40 | -0.5          |
| displayM  | 26   | w700   | 32 | -0.3          |
| titleL    | 22   | w700   | 28 | -0.2          |
| titleM    | 18   | w600   | 24 | 0             |
| titleS    | 15   | w600   | 20 | 0             |
| bodyL     | 16   | w500   | 24 | 0             |
| bodyM     | 14   | w500   | 20 | 0             |
| bodyS     | 12   | w500   | 16 | 0             |
| labelL    | 14   | w600   | 18 | 0.1           |
| labelM    | 12   | w600   | 16 | 0.3           |
| priceL    | 22   | w700   | 26 | -0.2          |
| priceM    | 17   | w700   | 22 | 0             |

Juga: static method `textTheme(Color onSurface) → TextTheme` yang map style di atas ke Material `TextTheme` (displayLarge, displayMedium, headlineLarge, headlineMedium, headlineSmall, titleLarge, titleMedium, titleSmall, bodyLarge, bodyMedium, bodySmall, labelLarge, labelMedium, labelSmall) dengan `.copyWith(color: onSurface)`.

═══════════════════════════════════════════════
FILE 4: lib/core/theme/app_palette.dart
═══════════════════════════════════════════════
`@immutable class AppPalette extends ThemeExtension<AppPalette>`.

Field `final Color` (semua `required`):
- `name` (String), `primary, primaryDark, onPrimary, primaryContainer, onPrimaryContainer`
- `secondary`
- `surface, surfaceVariant, surfaceDim`
- `outline, outlineSoft`
- `onSurface, onSurfaceVar`
- `success, successContainer`
- `warning, warningContainer`
- `error, errorContainer`

Tiga `static const AppPalette` preset (semua `const` agar bisa dipakai di tempat lain):

**caramel** (default):
- name: 'Caramel Latte'
- primary: 0xFFB8743D, primaryDark: 0xFF8A5527, onPrimary: 0xFFFFFFFF
- primaryContainer: 0xFFF8E6D0, onPrimaryContainer: 0xFF4A2810
- secondary: 0xFF1F1812
- surface: 0xFFFBF6EE, surfaceVariant: 0xFFEFE4D2, surfaceDim: 0xFFDECDB2
- outline: 0xFFC9B59A, outlineSoft: 0xFFEBDFCB
- onSurface: 0xFF241B12, onSurfaceVar: 0xFF6E5E48
- success: 0xFF5A7A3A, successContainer: 0xFFE3EFD0
- warning: 0xFFB87A1E, warningContainer: 0xFFF8E6C2
- error: 0xFFA8392E, errorContainer: 0xFFF5D7D3

**espresso**:
- name: 'Espresso'
- primary: 0xFF5C3A21, primaryDark: 0xFF3E2613, onPrimary: 0xFFFFFFFF
- primaryContainer: 0xFFF1E4D4, onPrimaryContainer: 0xFF3E2613
- secondary: 0xFF2A1F14
- surface: 0xFFFAF5EE, surfaceVariant: 0xFFECE0D0, surfaceDim: 0xFFD9CAB6
- outline: 0xFFC8B89E, outlineSoft: 0xFFE8DCC8
- onSurface: 0xFF2A1F14, onSurfaceVar: 0xFF6B5C4A
- (success/warning/error: sama dengan caramel)

**matcha**:
- name: 'Matcha'
- primary: 0xFF6B8E3D, primaryDark: 0xFF4F6B2A, onPrimary: 0xFFFFFFFF
- primaryContainer: 0xFFE4ECCD, onPrimaryContainer: 0xFF2A3815
- secondary: 0xFF1B2014
- surface: 0xFFF8FAF0, surfaceVariant: 0xFFE8ECD8, surfaceDim: 0xFFD2D9BD
- outline: 0xFFBAC3A0, outlineSoft: 0xFFE2E8CF
- onSurface: 0xFF1C2114, onSurfaceVar: 0xFF5E6650
- successContainer: 0xFFE4ECCD (override beda dari caramel)
- (warning/error: sama)

Static method:
- `static AppPalette byKey(String? key)` → switch: 'espresso' → espresso, 'matcha' → matcha, default → caramel.
- `static String keyOf(AppPalette p)` → invers: cek `identical(p, espresso) || p.name == espresso.name` → 'espresso', dst, default 'caramel'.

Override `copyWith(...)` dengan semua field opsional → return AppPalette baru.
Override `lerp(ThemeExtension<AppPalette>? other, double t)` — kalau `other` bukan `AppPalette` return `this`, else build palette baru dengan `Color.lerp(this.X, other.X, t)!` untuk semua color field; untuk `name`: pakai `t < 0.5 ? name : other.name`.

Di bawah class, definisikan `extension AppPaletteContext on BuildContext`:
```dart
AppPalette get palette =>
    Theme.of(this).extension<AppPalette>() ?? AppPalette.caramel;
```

═══════════════════════════════════════════════
FILE 5: lib/core/theme/app_theme.dart
═══════════════════════════════════════════════
Class `AppTheme` dengan private constructor `AppTheme._()`.

Static method `ThemeData fromPalette(AppPalette p)`:

1. `final colorScheme = ColorScheme.fromSeed(seedColor: p.primary, brightness: Brightness.light)` — lalu override:
   primary, onPrimary, primaryContainer, onPrimaryContainer,
   surface, onSurface, surfaceContainerHighest (→ p.surfaceVariant),
   outline (→ p.outline), outlineVariant (→ p.outlineSoft),
   error (→ p.error), onError (→ Colors.white), errorContainer.

2. `final textTheme = AppTypography.textTheme(p.onSurface);`

3. Return `ThemeData(...)` dengan:
   - `useMaterial3: true`, `brightness: Brightness.light`
   - `colorScheme`, `scaffoldBackgroundColor: p.surface`, `canvasColor: p.surface`, `dividerColor: p.outlineSoft`
   - `textTheme`
   - `extensions: <ThemeExtension<dynamic>>[p]`
   - `appBarTheme`: bg `p.surface`, fg `p.onSurface`, elevation 0, scrolledUnderElevation 0, centerTitle false, title style `AppTypography.titleL.copyWith(color: p.onSurface)`, iconTheme `p.onSurface`.
   - `bottomSheetTheme`: bg/surfaceTint/modal bg `p.surface`, modalBarrierColor `Colors.black.withValues(alpha: 0.45)`, shape rounded top corners `AppRadius.xl`.
   - `cardTheme` (CardThemeData): color/surfaceTint `Colors.white`, elevation 0, margin zero, shape rounded `AppRadius.mdAll` dengan `BorderSide(color: p.outlineSoft)`.
   - `inputDecorationTheme`: filled false, padding `EdgeInsets.symmetric(h:16, v:16)`, hintStyle `bodyM.copyWith(color: p.onSurfaceVar)`, labelStyle `titleS.copyWith(color: p.onSurface)`, **semua border (border/enabledBorder/focusedBorder/errorBorder/focusedErrorBorder/disabledBorder) = `InputBorder.none`**. (AppTextField akan provide outer container sendiri.)
   - `elevatedButtonTheme`: bg `p.primary`, fg `p.onPrimary`, elevation 0, `minimumSize: Size.fromHeight(56)`, shape rounded `AppRadius.mdAll`, textStyle `labelL.copyWith(fontSize: 16)`.
   - `outlinedButtonTheme`: fg `p.onSurface`, side `BorderSide(color: p.outline, width: 1.5)`, sama minSize/shape/text.
   - `textButtonTheme`: fg `p.primary`, textStyle `labelL`.
   - `progressIndicatorTheme`: color `p.primary`.
   - `switchTheme`: thumb white/onPrimary tergantung selected, track surfaceDim/primary, trackOutlineColor transparent.
   - `snackBarTheme`: bg `p.onSurface`, content text `bodyM.copyWith(color: p.surface)`, behavior floating, shape rounded `AppRadius.smAll`.
   - `dividerTheme`: color `p.outlineSoft`, space 1, thickness 1.

Beri komentar singkat di atas class untuk jelaskan kenapa pakai `ColorScheme.fromSeed` + `ThemeExtension`.
````

---

## Verifikasi

Belum bisa di-run yang berarti (belum di-wire ke `MaterialApp`), tapi minimal:

1. `flutter analyze` — pastikan zero error/warning di 5 file ini.
2. Buat test cepat di `lib/main.dart` placeholder:
   ```dart
   theme: AppTheme.fromPalette(AppPalette.caramel),
   home: Scaffold(
     appBar: AppBar(title: const Text('Theme test')),
     body: Builder(builder: (ctx) {
       final p = ctx.palette;
       return Container(color: p.primaryContainer, height: 100);
     }),
   ),
   ```
   Run → AppBar harus pakai font Quicksand bold, body harus warna pastel caramel.

## Talking points

1. **Kenapa pakai `ThemeExtension`, bukan top-level constants?**
   Karena saat user ganti palette (Settings → Espresso), kita mau seluruh tree re-render dengan palette baru. `ThemeExtension` ikut `MaterialApp.theme` rebuild — kalau pakai top-level const, harus restart app.

2. **Kenapa `ColorScheme.fromSeed` + override?**
   `fromSeed` generate semua warna (`surfaceTint`, `inverseSurface`, dll) dari satu seed — enak untuk widget bawaan. Tapi kita override 10+ field yang kita kontrol manual supaya brand-nya pas. Sisa field generated dipakai oleh widget yang gak kita sentuh (mis. `SnackBar.action`).

3. **Kenapa 3 palette?**
   Sebagai diferensiasi visual untuk pemilik usaha — kafe (caramel), kedai kopi premium (espresso), juice/health bar (matcha). Demo skill design system: design tokens membuat re-theming jadi 1 hari, bukan 1 minggu.

4. **Kenapa `BorderRadius.all(Radius.circular(N))` const, bukan `BorderRadius.circular(N)`?**
   `BorderRadius.circular` adalah constructor, bukan const. Kita pakai `const BorderRadius.all(Radius.circular(N))` supaya bisa dipakai di `const Container(decoration: ...)` (zero-allocation).

5. **`height: lh / size`** di Quicksand:
   Properti `height` di Flutter adalah multiplier line-height relatif terhadap font-size, bukan absolute. Jadi `lh: 24, size: 16` → `height: 1.5`.

6. **Demo perbedaan palette**: jalankan app, ganti `AppPalette.caramel` → `AppPalette.matcha` → reload → tunjukkan semua tombol/appbar otomatis ganti warna. Ini kekuatan design system.

## Commit suggestion

```bash
git add lib/core/theme/
git commit -m "Step 02: design tokens (palette, spacing, radius, typography, theme)"
```

---

➡️ Lanjut ke [Step 03 — Assets + flutter_gen](./03-assets-flutter-gen.md)
