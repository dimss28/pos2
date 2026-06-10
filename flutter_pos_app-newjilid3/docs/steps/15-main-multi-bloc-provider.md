# 15 — `main.dart` + MultiBlocProvider + MaterialApp

## Goal

Wire `main.dart` final: init `WidgetsFlutterBinding`, init locale 'id' untuk DateFormat, register `Bloc.observer`, MultiBlocProvider berisi semua blok app (sebagian masih placeholder, akan kita isi step berikutnya), dan `BlocBuilder<ThemeBloc>` di MaterialApp.

## Prerequisite

- Step 14 (ThemeBloc + BlocObserver) selesai.

## Konsep yang diajarkan

- **`WidgetsFlutterBinding.ensureInitialized()`** — harus dipanggil sebelum async work di `main()`.
- **`MultiBlocProvider`** — wrap aplikasi dengan banyak BlocProvider sekaligus.
- **Scope provider**: bloc disediakan di root → available di seluruh tree.
- **`BlocListener` vs `BlocBuilder`**:
  - Builder = subscribe state untuk rebuild widget.
  - Listener = subscribe state untuk side effect (navigation, snackbar). Tidak rebuild.
- **`initializeDateFormatting('id', null)`** — load locale untuk `intl` package.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada ThemeBloc, AppPalette, AppTheme. Beberapa bloc lain BELUM dibuat — kita akan stub mereka di provider list dengan TODO supaya `main.dart` final terbentuk, lalu tambahkan implementasi di step-step berikut.

Generate file lengkap `lib/main.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'presentation/setting/bloc/theme/theme_bloc.dart';

// TODO Step 17: ganti SplashPage placeholder dengan SplashPage asli.
// TODO Step 18: import semua bloc lain (LoginBloc, ProductBloc, CartBloc, dll).

Future<void> main() async {
  // 1) Wajib sebelum await apapun di main().
  WidgetsFlutterBinding.ensureInitialized();

  // 2) Init locale 'id' supaya DateFormat 'd MMMM yyyy' (Indonesia) jalan.
  //    Tanpa ini, DateFormat('d MMMM', 'id') akan throw LocaleDataException.
  await initializeDateFormatting('id', null);

  // 3) Register global BlocObserver di debug build saja.
  if (kDebugMode) Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme bloc — fire `loaded` saat construct untuk restore palette dari prefs.
        BlocProvider(
          create: (_) => ThemeBloc()..add(const ThemeEvent.loaded()),
        ),

        // TODO step 17: BlocProvider(create: (_) => LoginBloc(AuthRemoteDatasource())),
        // TODO step 18: BlocProvider(create: (_) => LogoutBloc(...)),
        //              BlocProvider(create: (_) => DeleteAccountBloc(...)),
        // TODO step 19: BlocProvider(create: (_) => ProductBloc(ProductRemoteDatasource())),
        //              BlocProvider(create: (_) => CategoryBloc(ProductRemoteDatasource())),
        // TODO step 22: BlocProvider(create: (_) => CheckoutBloc()),
        // TODO step 26: BlocProvider(create: (_) => OrderBloc()),
        // TODO step 28: BlocProvider(create: (_) => QrisBloc(MidtransRemoteDatasource())),
        // TODO step 29: BlocProvider(create: (_) => DraftOrderBloc(ProductLocalDatasource.instance)),
        // TODO step 30: BlocProvider(create: (_) => HistoryBloc()),
        // TODO step 33: BlocProvider(create: (_) => CashSessionBloc()),
        // TODO step 40: BlocProvider(create: (_) => SyncBloc()..add(const SyncEvent.refreshSnapshot())),
        // TODO step 41: BlocProvider(create: (_) => PromoBloc()..add(const PromoEvent.loadFromCache())),
        // TODO step 43: BlocProvider(create: (_) => SummaryBloc(...)),
        //              BlocProvider(create: (_) => ProductSalesBloc(...)),
        //              BlocProvider(create: (_) => CloseCashierBloc(...)),
        // TODO step 44: BlocProvider(create: (_) => ConnectivityBloc()..add(const ConnectivityEvent.started())),
      ],
      // TODO step 44: bungkus BlocBuilder berikut dengan
      // BlocListener<ConnectivityBloc, ConnectivityState> yang trigger
      // SyncBloc.pushOrders + SyncBloc.pullPromos saat connectivity `restored`.
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final palette = AppPalette.byKey(themeState.paletteKey);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'POS Batch 11',
            theme: AppTheme.fromPalette(palette),
            // TODO step 16: home: const SplashPage(),
            home: Scaffold(
              appBar: AppBar(title: const Text('POS — bootstrap')),
              body: Center(
                child: Text('Palette aktif: ${themeState.paletteKey}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

Catatan untuk peserta:
- Tiap step berikut akan **uncomment satu TODO** sesuai bloc yang lagi dibuat. Pastikan import-nya juga ditambah.
- Provider akan tumbuh jadi 19+ blok. Tetap satu file `main.dart` (jangan dipecah jadi `_providers.dart` dll) — lebih mudah dibaca/scan.
````

---

## Verifikasi

`flutter run` → splash custom kita belum ada (step 17), jadi tampil Scaffold sederhana dengan text "Palette aktif: caramel".

Cek terminal:
```
[ThemeBloc] event: ThemeEvent.loaded()
[ThemeBloc] _ThemeState → _ThemeState
```

## Talking points

1. **`WidgetsFlutterBinding.ensureInitialized()`**:
   Sebelum await SharedPreferences/path_provider/dll, harus binding ready. Tanpa ini error "ServicesBinding hasn't been initialized." Wajib dipanggil **sebelum** await pertama.

2. **`initializeDateFormatting('id', null)`**:
   Locale 'id' bahasa Indonesia. Setelah ini, `DateFormat('d MMMM yyyy', 'id').format(now)` jalan: "7 Juni 2026". Tanpa ini: `LocaleDataException`.

3. **Konvensi single `main.dart` besar**:
   Provider list bisa panjang (19+). Tetap di 1 file karena: (a) mudah audit semua dependency app, (b) tidak ada keuntungan technical kalau dipecah.

4. **`BlocBuilder` vs `BlocConsumer`**:
   - `BlocBuilder` = builder only (rebuild widget).
   - `BlocListener` = listener only (side effect).
   - `BlocConsumer` = keduanya. Pakai kalau butuh dua-duanya di 1 widget.

5. **Ordering provider penting?**
   Provider di bawah bisa baca provider di atas (via context). Kalau Bloc B butuh Bloc A, A harus di atas B. Untuk POS app kita, ordering longgar karena tidak ada bloc-to-bloc dependency di provider creation.

6. **Bloc lifecycle**:
   - Provider create → Bloc constructor → ready.
   - Provider unmount → Bloc.close() → resources released.
   - `MultiBlocProvider` di root MyApp = bloc hidup sepanjang app. Untuk bloc transient (form), pakai BlocProvider lokal di Page.

7. **`MaterialApp.home` vs `routes`**:
   `home` = root widget pertama. `routes` = named routes map. Kita pakai imperative `Navigator.push` (Navigator 1.0), jadi `home` cukup.

## Commit suggestion

```bash
git add lib/main.dart
git commit -m "Step 15: main.dart wiring (binding, locale, observer, provider, theme)"
```

---

➡️ Lanjut ke [Step 16 — SplashPage Auth Gate](./16-splash-auth-gate.md)
