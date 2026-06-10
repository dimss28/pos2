# 18 — DashboardPage (Bottom Nav Shell) + LogoutBloc + DeleteAccountBloc

## Goal

`DashboardPage` sebagai shell utama setelah login: 4 tab (Home/Order/Riwayat/Setting) dengan badge live dari `CheckoutBloc` (cart) & `SyncBloc` (pending). Tambahan: `LogoutBloc` dan `DeleteAccountBloc` (POST/DELETE ke BE, Play Store compliance).

Page Home/Order/History/Setting akan stub di step ini (kita ganti satu per satu di Phase berikut).

## Prerequisite

- Step 17 selesai.

## Konsep yang diajarkan

- **`IndexedStack`** — keep state semua tab (tidak unmount saat switch).
- **`InheritedWidget`** untuk share callback (`DashboardScope.switchTo`) ke child pages tanpa props drilling.
- **Nested `BlocBuilder`** untuk gabungkan dua bloc state ke 1 widget.
- **`pushAndRemoveUntil`** sebagai logout flow.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `LoginPage` & splash + auth datasource ready.

Generate 9 file.

═══════════════════════════════════════════════
FILE 1-3: LogoutBloc (Freezed unions)
═══════════════════════════════════════════════
Di `lib/presentation/home/bloc/logout/`:

**logout_bloc.dart**:
```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pos_app/data/datasources/auth_remote_datasource.dart';

part 'logout_bloc.freezed.dart';
part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDatasource _authRemoteDatasource;
  LogoutBloc(this._authRemoteDatasource) : super(const _Initial()) {
    on<_Logout>((event, emit) async {
      emit(const LogoutState.loading());
      final result = await _authRemoteDatasource.logout();
      result.fold(
        (l) => emit(LogoutState.error(l)),
        (r) => emit(const LogoutState.success()),
      );
    });
  }
}
```

**logout_event.dart** (`part of`):
```dart
@freezed
class LogoutEvent with _$LogoutEvent {
  const factory LogoutEvent.started() = _Started;
  const factory LogoutEvent.logout() = _Logout;
}
```

**logout_state.dart** (`part of`):
```dart
@freezed
class LogoutState with _$LogoutState {
  const factory LogoutState.initial() = _Initial;
  const factory LogoutState.loading() = _Loading;
  const factory LogoutState.success() = _Success;
  const factory LogoutState.error(String message) = _Error;
}
```

═══════════════════════════════════════════════
FILE 4-6: DeleteAccountBloc
═══════════════════════════════════════════════
Di `lib/presentation/auth/bloc/delete_account/`:

**delete_account_bloc.dart**:
```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';
part 'delete_account_bloc.freezed.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final AuthRemoteDatasource _remote;

  DeleteAccountBloc(this._remote) : super(const DeleteAccountState.initial()) {
    on<_Submit>((event, emit) async {
      emit(const DeleteAccountState.loading());
      final result = await _remote.deleteAccount();
      result.fold(
        (l) => emit(DeleteAccountState.error(l)),
        (_) => emit(const DeleteAccountState.success()),
      );
    });
  }
}
```

**delete_account_event.dart** (`part of`):
```dart
@freezed
class DeleteAccountEvent with _$DeleteAccountEvent {
  const factory DeleteAccountEvent.submit() = _Submit;
}
```

**delete_account_state.dart** (`part of`):
```dart
@freezed
class DeleteAccountState with _$DeleteAccountState {
  const factory DeleteAccountState.initial() = _Initial;
  const factory DeleteAccountState.loading() = _Loading;
  const factory DeleteAccountState.success() = _Success;
  const factory DeleteAccountState.error(String message) = _Error;
}
```

═══════════════════════════════════════════════
FILE 7-8: Stub Home, Order, History, Setting pages
═══════════════════════════════════════════════
Generate 4 stub di:
- `lib/presentation/home/pages/home_page.dart` (`class HomePage` Scaffold dengan `AppAppBar(title: 'Home')` + Text 'TODO step 20').
- `lib/presentation/order/pages/order_page.dart` (`class OrderPage`).
- `lib/presentation/history/pages/history_page.dart` (`class HistoryPage`).
- `lib/presentation/setting/pages/setting_page.dart` (`class SettingPage`).

Setting stub harus punya tombol "Logout" yang trigger `LogoutBloc.add(logout())` + listener → setelah success `removeAuthData()` lalu `pushAndRemoveUntil(LoginPage(), (_) => false)`.

═══════════════════════════════════════════════
FILE 9: Replace lib/presentation/home/pages/dashboard_page.dart
═══════════════════════════════════════════════
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_bottom_nav.dart';
import '../../../core/theme/app_palette.dart';
import '../../history/pages/history_page.dart';
import '../../order/pages/order_page.dart';
import '../../setting/pages/setting_page.dart';
import 'home_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(), OrderPage(), HistoryPage(), SettingPage(),
  ];

  void _switchTo(int i) {
    if (i < 0 || i >= _pages.length) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DashboardScope(
      switchTo: _switchTo,
      child: Scaffold(
        backgroundColor: p.surface,
        body: IndexedStack(index: _index, children: _pages),
        // Cart/Sync badge dipasang nanti di step 22 & 40. Sementara hard 0:
        bottomNavigationBar: AppBottomNav.standard(
          activeIndex: _index,
          onTap: _switchTo,
          cartCount: 0,
          pendingSync: 0,
        ),
      ),
    );
  }
}

/// InheritedWidget supaya child page bisa pindah tab tanpa kirim callback
/// via constructor. Pakai: `DashboardScope.of(context)?.switchTo(1);`
class DashboardScope extends InheritedWidget {
  final void Function(int index) switchTo;
  const DashboardScope({
    super.key,
    required this.switchTo,
    required super.child,
  });
  static DashboardScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DashboardScope>();
  @override
  bool updateShouldNotify(DashboardScope oldWidget) =>
      switchTo != oldWidget.switchTo;
}
```

Komentari catatan: bottom nav badge cartCount & pendingSync akan dihubungkan ke `CheckoutBloc` dan `SyncBloc` di step 22 dan 40.

═══════════════════════════════════════════════
STEP 10: Update `main.dart`
═══════════════════════════════════════════════
Uncomment 2 BlocProvider di MultiBlocProvider:
```dart
BlocProvider(create: (_) => LogoutBloc(AuthRemoteDatasource())),
BlocProvider(create: (_) => DeleteAccountBloc(AuthRemoteDatasource())),
```

═══════════════════════════════════════════════
STEP 11: Generate freezed + run
═══════════════════════════════════════════════
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```
````

---

## Verifikasi

1. Login → masuk DashboardPage.
2. Tap tab Setting → tap Logout → spinner → kembali ke LoginPage. Token hilang dari storage.
3. Login ulang → masuk Dashboard. Tap Home/Order/Riwayat/Setting → tab berpindah, IndexedStack keep state (mis. scroll position).

## Talking points

1. **`IndexedStack`**:
   - Render semua child sekaligus, hanya 1 yang visible.
   - Pro: state kept (scroll, form, animation continue).
   - Con: kalau semua page heavy, all-of-them inflate di-memory.
   - Alternatif: `if (_index == 0) HomePage() else if ...` → unmount tab tak aktif, lose state.
   - Pilihan kita: IndexedStack — POS tab tidak terlalu berat dan UX keep-state penting.

2. **`InheritedWidget` `DashboardScope`**:
   - Pattern Flutter klasik untuk share data ke descendant tanpa props drilling.
   - `static of(context)` adalah konvensi (mirip Theme.of, MediaQuery.of).
   - `updateShouldNotify` cek apakah perubahan perlu rebuild subscriber. Karena `switchTo` adalah function constant, biasanya gak berubah.

3. **Mengapa bukan `BlocProvider<DashboardBloc>`?**
   Bisa, tapi overkill. Ini cuma tab switching local. Bloc untuk state global; InheritedWidget untuk callback wiring.

4. **Logout flow**:
   - Tap Logout → `LogoutBloc.add(logout())` → BE call.
   - Listener: success → `removeAuthData()` (clear local) → push & remove until LoginPage.
   - Mengapa hapus local SETELAH BE response? Kalau BE down, user gak bisa logout. Trade-off: logout HARUS bisa offline. Pilihan teaching: tampilkan trade-off → idealnya hapus local DULU, lalu best-effort BE call.

5. **DeleteAccount + 'HAPUS AKUN' confirmation**:
   - Backend butuh `{"confirmation":"HAPUS AKUN"}` (lihat datasource step 11).
   - Play Store compliance: in-app account deletion wajib untuk app yang punya login (since 2023).
   - UI prompt nanti di step 36 (SettingPage).

6. **Badge cart/sync = 0 sementara**:
   - Tidak ideal — peserta lihat badge stuck. Trade-off: step 22 (CheckoutBloc) baru wire. Sampai itu, badge dummy.
   - Saat ngajar: ingatkan ada TODO.

7. **`removeAuthData` dipanggil di mana?**
   Di setting page after LogoutBloc success listener. Sesuaikan dengan pola Login.

## Commit suggestion

```bash
git add lib/presentation/home/bloc/logout/ lib/presentation/auth/bloc/delete_account/ lib/presentation/home/pages/dashboard_page.dart lib/presentation/home/pages/home_page.dart lib/presentation/order/pages/order_page.dart lib/presentation/history/pages/history_page.dart lib/presentation/setting/pages/setting_page.dart lib/main.dart
git commit -m "Step 18: Dashboard shell + Logout/DeleteAccount blocs + 4 stub pages"
```

---

➡️ Lanjut ke [Step 19 — ProductBloc + CategoryBloc](./19-product-category-bloc.md)
