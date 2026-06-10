# 17 — LoginBloc + LoginPage

## Goal

`LoginBloc` (4-state Freezed union: initial/loading/success/error) + `LoginPage` (form email/password, show password toggle, lupa password link, validation, error snackbar).

## Prerequisite

- Step 16 (Splash + stub Login) selesai.

## Konsep yang diajarkan

- **4-state pattern** untuk async operation: initial → loading → success | error.
- **`BlocConsumer`** — builder + listener combo.
- **`Either.fold((l) => ..., (r) => ...)`** — handle error/success dari datasource.
- **`LayoutBuilder` + `IntrinsicHeight` + `Spacer`** — layout yang stick footer ke bottom kalau cukup ruang.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada: `AuthRemoteDatasource.login`, `AuthLocalDatasource.saveAuthData`, `AppButton`, `AppTextField`, `BrandMark`, `AppSnackbar`. Stub `LoginPage` ada di `lib/presentation/auth/pages/login_page.dart` — ganti dengan implementasi penuh.

Generate / replace 4 file.

═══════════════════════════════════════════════
FILE 1: lib/presentation/auth/bloc/login/login_bloc.dart
═══════════════════════════════════════════════
```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_pos_app/data/datasources/auth_remote_datasource.dart';
import '../../../../data/models/response/auth_response_model.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource authRemoteDatasource;

  LoginBloc(this.authRemoteDatasource) : super(const _Initial()) {
    on<_Login>((event, emit) async {
      emit(const _Loading());
      final response = await authRemoteDatasource.login(
        event.email,
        event.password,
      );
      response.fold(
        (err) => emit(_Error(err)),
        (data) => emit(_Success(data)),
      );
    });
  }
}
```

═══════════════════════════════════════════════
FILE 2: lib/presentation/auth/bloc/login/login_event.dart
═══════════════════════════════════════════════
```dart
part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.started() = _Started;
  const factory LoginEvent.login({
    required String email,
    required String password,
  }) = _Login;
}
```

═══════════════════════════════════════════════
FILE 3: lib/presentation/auth/bloc/login/login_state.dart
═══════════════════════════════════════════════
```dart
part of 'login_bloc.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.success(AuthResponseModel authResponseModel) = _Success;
  const factory LoginState.error(String message) = _Error;
}
```

═══════════════════════════════════════════════
FILE 4: lib/presentation/auth/pages/login_page.dart (replace stub)
═══════════════════════════════════════════════
`LoginPage extends StatefulWidget` dengan layout:
- `Scaffold(bg: p.surface)` > SafeArea > LayoutBuilder > SingleChildScrollView(padding 24/40/24/24) > ConstrainedBox(minHeight = constraints.maxHeight - 64) > IntrinsicHeight > Column.stretch:

  1. SpaceHeight `xxxl`.
  2. **`_BrandHeader`** (private widget):
     - Column: BrandMark size 76, SpaceHeight 14, Text 'BY JAGO FLUTTER' (`labelM.copyWith(p.primary, w700, letterSpacing 1.5)`).
  3. SpaceHeight 28.
  4. **`_TitleBlock`** (private widget):
     - Column: Text 'New POS Cafe' (`displayM.copyWith(p.onSurface, fontSize 28)`), SpaceHeight 6, Text 'Login to your account' (`bodyM, p.onSurfaceVar`).
  5. SpaceHeight 36.
  6. **Form** (`_buildForm(p)`):
     - AppTextField label 'Email', hint 'kasir@cafe.id', leading mail_outline, controller `_emailCtrl`, keyboardType emailAddress, errorText `_emailError`, onChanged → clear error.
     - SpaceHeight 18.
     - AppTextField label 'Password', hint 'Password', leading lock_outline, controller `_passwordCtrl`, obscure `!_passwordVisible`, errorText `_passwordError`, onChanged → clear error. Trailing: InkWell yang toggle `_passwordVisible`, child Icon visibility_outlined / visibility_off_outlined.
     - SpaceHeight 12.
     - Align(centerRight) > InkWell ('Lupa password?' → `AppSnackbar.info(context, 'Hubungi admin untuk reset password')`) — text `labelL.copyWith(p.primary)`.
  7. SpaceHeight 28.
  8. **Submit** (`_buildSubmit()`):
     - `BlocConsumer<LoginBloc, LoginState>`:
       - listener: state.maybeWhen:
         - success(auth): `await AuthLocalDatasource().saveAuthData(auth)`; `if (!context.mounted) return; Navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SplashPage()), (_) => false)` — kembali ke splash supaya gate jalan lagi.
         - error(msg): `AppSnackbar.error(context, msg)`.
       - builder: extract `loading` dari state; return `AppButton(label: 'Login', loading: loading, onPressed: loading ? null : _submit)`.
  9. `Spacer()` (kalau ada ruang sisa, dorong footer ke bawah).
  10. SpaceHeight `lg`.
  11. Text 'v1.0.0 · build 1' (`bodyS, p.onSurfaceVar, center`).

`_submit()`:
- Set `_emailError = email.isEmpty ? 'Email wajib diisi' : null` dan `_passwordError = password.isEmpty ? 'Password wajib diisi' : null` via setState.
- Kalau ada error, return.
- `FocusScope.of(context).unfocus()` untuk close keyboard.
- `context.read<LoginBloc>().add(LoginEvent.login(email: ..., password: ...))`.

State class punya 2 `TextEditingController` (di dispose), bool `_passwordVisible = false`, `String? _emailError, _passwordError`.

═══════════════════════════════════════════════
STEP 5: Update `main.dart`
═══════════════════════════════════════════════
Uncomment di MultiBlocProvider:
```dart
BlocProvider(create: (_) => LoginBloc(AuthRemoteDatasource())),
```
Tambah import.

═══════════════════════════════════════════════
STEP 6: Generate freezed
═══════════════════════════════════════════════
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
````

---

## Verifikasi

1. Run app → splash → login.
2. Input email kosong → tap Login → field error "Email wajib diisi".
3. Input email & password salah → tap Login → snackbar merah dengan body response BE (raw).
4. Input valid → loading spinner di tombol → splash → dashboard.

## Talking points

1. **`BlocConsumer` vs separate Builder + Listener**:
   - Kombo lebih clean: 1 widget rebuild + react ke state change.
   - Trade-off: kalau bagian builder besar dan listener kecil, pisah jadi 2 lebih readable.

2. **Mengapa `LoginBloc.add(_Login)` dengan `LoginEvent.login(...)` factory?**
   Pattern Freezed: `_Login` adalah generated subclass (private). User panggil constructor factory `LoginEvent.login(...)`. Bloc handler match `on<_Login>(...)` ke subclass.

3. **`Either.fold((l) => ..., (r) => ...)`**:
   - `l` adalah Left value (error string).
   - `r` adalah Right value (AuthResponseModel).
   - Salah satu pasti dipanggil, tidak keduanya.

4. **`AuthLocalDatasource().saveAuthData(auth)` di listener, bukan di Bloc**:
   - Trade-off arsitektur: side effect di UI vs di Bloc.
   - Pilihan kita: persistence di UI listener (sederhana). Pilihan lain: trigger `_PersistTokenEvent` ke Bloc.
   - Mana benar? Sama validnya. Untuk teaching, sederhana menang.

5. **`pushAndRemoveUntil((_) => false)`**:
   Kosongkan stack sepenuhnya. User tidak bisa back ke LoginPage setelah berhasil. Kita push SplashPage karena dia yang re-check auth + decide next page.

6. **`LayoutBuilder + ConstrainedBox + IntrinsicHeight + Spacer`** pattern:
   - Mau stick footer ke bottom **kalau** ruang cukup, **tapi** scrollable kalau gak cukup (mis. landscape).
   - LayoutBuilder dapet `maxHeight`. ConstrainedBox set minHeight supaya Column bisa pakai Spacer. IntrinsicHeight resolve Spacer ke konten.

7. **Password visibility toggle**:
   - `obscure: !_passwordVisible` di AppTextField.
   - Icon switch berdasarkan state. UX standar.

## Commit suggestion

```bash
git add lib/presentation/auth/bloc/login/ lib/presentation/auth/pages/login_page.dart lib/main.dart
git commit -m "Step 17: LoginBloc + LoginPage with form validation and snackbar"
```

---

➡️ Lanjut ke [Step 18 — DashboardPage + Logout + Hapus Akun](./18-dashboard-bottom-nav.md)
