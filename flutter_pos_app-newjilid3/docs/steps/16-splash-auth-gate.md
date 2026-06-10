# 16 — SplashPage (Auth Gate)

## Goal

`SplashPage` minimal yang: cek auth → redirect ke `LoginPage` atau `DashboardPage`. Versi minimal di step ini (tanpa SyncBloc / CashSessionBloc gating); kita upgrade di step 33 saat CashSessionBloc ada.

## Prerequisite

- Step 15 selesai. `AuthLocalDatasource` ada.
- `LoginPage` dan `DashboardPage` belum ada — kita akan stub keduanya.

## Konsep yang diajarkan

- **Auth gate pattern** — splash sebagai router pre-auth.
- **`WidgetsBinding.instance.addPostFrameCallback`** — eksekusi setelah frame pertama (supaya context ready untuk Navigator).
- **`Navigator.pushReplacement`** — replace splash dengan target (user tidak bisa back ke splash).
- **`if (!mounted) return`** — guard sebelum setState/Navigator pasca async.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `AuthLocalDatasource().isAuth()` sudah ada. `MaterialApp.home` di `main.dart` masih placeholder.

Generate 3 file (2 stub + 1 splash).

═══════════════════════════════════════════════
FILE 1 (stub): lib/presentation/auth/pages/login_page.dart
═══════════════════════════════════════════════
```dart
import 'package:flutter/material.dart';
import '../../../core/components/app_app_bar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppAppBar(title: 'Login (stub)'),
      body: Center(child: Text('TODO: step 17 — login form')),
    );
  }
}
```

═══════════════════════════════════════════════
FILE 2 (stub): lib/presentation/home/pages/dashboard_page.dart
═══════════════════════════════════════════════
```dart
import 'package:flutter/material.dart';
import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_bottom_nav.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Dashboard (stub)'),
      body: const Center(child: Text('TODO: step 18 — bottom nav shell')),
      bottomNavigationBar: AppBottomNav.standard(
        activeIndex: 0,
        onTap: (_) {},
      ),
    );
  }
}
```

═══════════════════════════════════════════════
FILE 3: lib/presentation/auth/pages/splash_page.dart
═══════════════════════════════════════════════
```dart
import 'package:flutter/material.dart';

import '../../../core/components/brand_mark.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../home/pages/dashboard_page.dart';
import 'login_page.dart';

/// Auth gate + brand splash. Cek token → push ke Dashboard atau Login.
///
/// Versi minimal: belum gate ke SyncBloc / CashSessionBloc — itu di step 33.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final isAuth = await AuthLocalDatasource().isAuth();
    if (!mounted || _routed) return;
    _routed = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isAuth ? const DashboardPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 96),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'POS Cafe',
              style: AppTypography.titleL.copyWith(color: p.onSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'by Jago Flutter',
              style: AppTypography.labelM
                  .copyWith(color: p.primary, letterSpacing: 1.5),
            ),
            const SizedBox(height: AppSpacing.huge),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: p.primary,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

═══════════════════════════════════════════════
STEP 4: Update `main.dart`
═══════════════════════════════════════════════
Ganti `home: Scaffold(...)` placeholder dengan:
```dart
import 'presentation/auth/pages/splash_page.dart';
// ...
home: const SplashPage(),
```
````

---

## Verifikasi

`flutter run` (state belum login):
1. Splash render brand mark + tagline + spinner ~1 detik.
2. Otomatis pindah ke `LoginPage` stub.

Coba simulasi sudah login (sementara untuk testing):
```dart
// Di splash _start(), comment AuthLocalDatasource cek, hardcode:
if (!mounted) return; _routed = true;
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (_) => const DashboardPage()),
);
```
Restart → langsung ke Dashboard stub.

## Talking points

1. **Splash sebagai router**:
   - Awalnya splash = layar "loading branding". Sekarang umumnya = mini router yang cek conditions (auth, version, force update) sebelum decide ke mana.
   - Render brand splash punya 2 fungsi: (a) cover async work, (b) brand recall.

2. **`addPostFrameCallback`**:
   - Dipanggil setelah build pertama selesai.
   - Kenapa? Di `initState`, `context` belum punya `Navigator` (route belum mount). Push akan crash.
   - Pattern: schedule async work setelah frame ready.

3. **`if (!mounted) return`**:
   - Setelah `await`, widget bisa sudah unmount (user tap back, atau pop programmatic).
   - Tanpa guard → `setState() called after dispose()` exception.
   - Selalu pakai ini di state class pasca await.

4. **`_routed` flag**:
   - Defensive — kalau `_start()` ke-trigger 2x (jarang tapi mungkin), gak push ganda.

5. **`Navigator.pushReplacement` vs `pushAndRemoveUntil`**:
   - `pushReplacement` = replace top route. Cukup untuk splash → login (stack: [login]).
   - `pushAndRemoveUntil(predicate: (_) => false)` = buang semua. Pakai untuk logout supaya user gak bisa back ke dashboard.

6. **Kenapa splash bukan widget biasa di main.dart?**
   Bisa juga. Tapi `SplashPage` jadi entity sendiri memudahkan reusable + testable. Plus, kalau ada animasi splash, butuh stateful widget.

7. **Upgrade di step 33**:
   Step ini minimal — splash hanya check `isAuth`. Step 33 nanti kita upgrade jadi gating tambahan: tunggu `SyncBloc.bootstrap` selesai + cek `CashSessionBloc.loaded` (apakah ada shift open) → route ke `BukaKasirPage` atau `DashboardPage`.

## Commit suggestion

```bash
git add lib/presentation/auth/pages/ lib/presentation/home/pages/dashboard_page.dart lib/main.dart
git commit -m "Step 16: SplashPage auth gate + Login/Dashboard stubs"
```

---

➡️ Lanjut ke [Step 17 — LoginBloc + LoginPage](./17-login-bloc-page.md)
