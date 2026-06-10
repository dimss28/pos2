# 14 — ThemeBloc + AppBlocObserver (BLoC pertama dengan Freezed)

## Goal

`ThemeBloc` pertama kita: persist palette choice ('caramel'/'espresso'/'matcha') di SharedPreferences, emit ke `MaterialApp`. Plus `AppBlocObserver` untuk log semua event/transition di debug.

## Prerequisite

- Step 13 selesai.
- Package `flutter_bloc`, `freezed_annotation` (dependency), `freezed` (dev_dependency), `build_runner` (dev_dep) sudah di pubspec.

## Konsep yang diajarkan

- **BLoC** = Business Logic Component. Class yang convert **Event** (user action) jadi **State** (UI status).
- **Freezed unions** untuk event & state — type-safe, exhaustive matching.
- **`part of` files**: bloc + event + state + freezed dalam 1 import scope.
- **`build_runner`** — code generator yang baca `@freezed` annotation dan emit `*.freezed.dart`.
- **`BlocObserver`** — global listener untuk debug semua bloc.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Setup `flutter_bloc + freezed`.

Tugas:

═══════════════════════════════════════════════
STEP 1: Pastikan dependencies
═══════════════════════════════════════════════
Cek `pubspec.yaml`:
- dependencies:
  - `flutter_bloc: ^8.1.3`
  - `freezed_annotation: ^3.0.0`
- dev_dependencies:
  - `build_runner: ^2.4.7`
  - `freezed: ^3.0.0`

═══════════════════════════════════════════════
FILE 1: lib/core/bloc/app_bloc_observer.dart
═══════════════════════════════════════════════
```dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs setiap bloc event / transition / error di debug mode.
/// Registrasi sekali di `main()`:
///   if (kDebugMode) Bloc.observer = AppBlocObserver();
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      developer.log('event: $event', name: bloc.runtimeType.toString());
    }
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc,
      Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      developer.log(
        '${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}',
        name: bloc.runtimeType.toString(),
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    developer.log('error', name: bloc.runtimeType.toString(),
        error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
```

═══════════════════════════════════════════════
FILE 2-4: ThemeBloc dengan part files
═══════════════════════════════════════════════
Buat 3 file di `lib/presentation/setting/bloc/theme/`:

**theme_bloc.dart**:
```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_palette.dart';

part 'theme_bloc.freezed.dart';
part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _prefsKey = 'palette';

  ThemeBloc() : super(const ThemeState(paletteKey: 'caramel')) {
    on<_Loaded>(_onLoaded);
    on<_Changed>(_onChanged);
  }

  Future<void> _onLoaded(_Loaded event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_prefsKey) ?? 'caramel';
    emit(ThemeState(paletteKey: key));
  }

  Future<void> _onChanged(_Changed event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, event.paletteKey);
    emit(ThemeState(paletteKey: event.paletteKey));
  }
}
```

**theme_event.dart**:
```dart
part of 'theme_bloc.dart';

@freezed
class ThemeEvent with _$ThemeEvent {
  const factory ThemeEvent.loaded() = _Loaded;
  const factory ThemeEvent.changed(String paletteKey) = _Changed;
}
```

**theme_state.dart**:
```dart
part of 'theme_bloc.dart';

@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState({
    required String paletteKey,  // 'caramel' | 'espresso' | 'matcha'
  }) = _ThemeState;
}
```

═══════════════════════════════════════════════
STEP 3: Generate freezed
═══════════════════════════════════════════════
Beri perintah:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Atau watch mode (rekomendasi saat ngajar):
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

File `theme_bloc.freezed.dart` akan generate otomatis dengan: `_$ThemeEvent`, `_Loaded`, `_Changed`, factory implementations, dan `_$ThemeState`, `_ThemeState`.

═══════════════════════════════════════════════
STEP 4: .gitignore
═══════════════════════════════════════════════
Pastikan di `.gitignore`:
```
**/*.freezed.dart
**/*.g.dart
!lib/core/assets/assets.gen.dart
```
````

---

## Verifikasi

Edit `main.dart` placeholder:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'presentation/setting/bloc/theme/theme_bloc.dart';

void main() {
  if (kDebugMode) Bloc.observer = AppBlocObserver();
  runApp(
    BlocProvider(
      create: (_) => ThemeBloc()..add(const ThemeEvent.loaded()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final palette = AppPalette.byKey(themeState.paletteKey);
          return MaterialApp(
            theme: AppTheme.fromPalette(palette),
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Active: ${themeState.paletteKey}'),
                    ElevatedButton(
                      onPressed: () => context.read<ThemeBloc>()
                          .add(const ThemeEvent.changed('matcha')),
                      child: const Text('Switch to Matcha'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
```

Run → tap "Switch to Matcha" → seluruh app re-render hijau. Restart app → masih Matcha (persisted).

Cek terminal: developer.log akan print:
```
[ThemeBloc] event: ThemeEvent.loaded()
[ThemeBloc] _ThemeState → _ThemeState
[ThemeBloc] event: ThemeEvent.changed('matcha')
```

## Talking points

1. **BLoC mental model**:
   - Event = "saya mau X" (intent dari UI).
   - State = "ini status terkini" (snapshot data).
   - Bloc = converter: event in → async work → state out.
   - UI hanya baca state, hanya kirim event. Tidak boleh call repository langsung.

2. **Kenapa Freezed?**
   - Manual: bikin Event class hierarchy + override `==`/`hashCode` + handle subclass exhaustively = boilerplate banyak.
   - Freezed bikin semua itu otomatis + `.when()/.maybeWhen()` pattern matching.
   - `_Loaded`, `_Changed` adalah subclass yang auto-generated.

3. **`part of` mechanic**:
   - `theme_event.dart` & `theme_state.dart` cuma "potongan" dari `theme_bloc.dart`.
   - Library scope sama → bisa akses private classes.
   - 1 import dari luar (`import 'theme_bloc.dart'`) cukup untuk akses Event, State, Bloc.

4. **`build_runner watch`**:
   - `build`: generate sekali, exit.
   - `watch`: monitor file change, re-generate otomatis.
   - Saat ngajar: bukan watch di terminal lain. Tambah field di Freezed → simpan → file `.freezed.dart` update otomatis.

5. **`BlocObserver` sebagai debug tool**:
   - Set global di `main()`, semua bloc transition di-log.
   - Pakai `developer.log(name: ...)` (bukan `print`) supaya muncul terformat di DevTools.
   - Production: skip observer dengan `if (kDebugMode)`.

6. **State persistence**:
   - Bloc state HILANG kalau app dimatikan.
   - Yang persist (mis. palette) harus simpan di SharedPreferences/Secure Storage manual.
   - Pattern: `_onLoaded` baca dari prefs, `_onChanged` write ke prefs + emit.

7. **`..add(const ThemeEvent.loaded())` di provider**:
   `..` adalah cascade. Bikin instance lalu langsung kirim event init. Tanpa ini, palette gak ke-restore saat app start.

## Commit suggestion

```bash
git add lib/core/bloc/ lib/presentation/setting/bloc/theme/ pubspec.yaml .gitignore
git commit -m "Step 14: ThemeBloc + AppBlocObserver (first bloc with Freezed)"
```

---

➡️ Lanjut ke [Step 15 — main.dart + MultiBlocProvider](./15-main-multi-bloc-provider.md)
