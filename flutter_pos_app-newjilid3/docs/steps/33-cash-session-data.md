# 33 — Cash Session: Data + Bloc

## Goal

`CashSessionModel` + `CashSessionLocalDatasource` (mirror cache) + `CashSessionRemoteDatasource` (BE-first) + `CashSessionBloc` (state: noSession/open/error). State machine: loaded → noSession(lastClosed?) atau open(current).

## Prerequisite

- Step 32 selesai.
- Tabel `cash_sessions` di SQLite v2+ (sudah ada di step 12).

## Konsep yang diajarkan

- **Remote-first dengan local mirror**: BE = source of truth, local = cache untuk offline read.
- **State `noSession(lastClosed?)`** carry last closed → BukaKasirPage bisa tampil recap.
- **`_mirrorLocal` non-fatal** — local failure tidak break remote success.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. SQLite tabel `cash_sessions` sudah ada (step 12).

Generate 4 file.

═══════════════════════════════════════════════
FILE 1: lib/data/models/response/cash_session_model.dart
═══════════════════════════════════════════════
`CashSessionModel` (handwritten DTO):
- Field: `id?, userId, userName, shiftLabel, openingFloat, openingNote?, openedAt, cashIn=0, cashOut=0, physicalCount?, expectedCash?, variance?, closingNote?, closedAt?, isSync=0`.
- Getters: `isOpen => closedAt == null`, `isBalanced => variance != null && variance == 0`.
- fromMap/toMap akomodasi:
  - BE `CashSessionResource` (user_name eager, ISO timestamps, expected_cash).
  - Local SQLite row (no expected_cash legacy, ISO timestamps).
- toMap output snake_case + skip null id.
- copyWith semua field optional.

═══════════════════════════════════════════════
FILE 2: lib/data/datasources/cash_session_local_datasource.dart
═══════════════════════════════════════════════
Singleton mirip ProductLocalDatasource — tapi share `database` getter dengan ProductLocalDatasource.instance (1 DB file).

Methods:
- `upsertFromRemote(CashSessionModel s)`: INSERT OR REPLACE (kalau ada id), kalau null insert baru.
- `getLastClosed() → CashSessionModel?`: query `WHERE closed_at IS NOT NULL ORDER BY closed_at DESC LIMIT 1`.
- `getCurrent() → CashSessionModel?`: query `WHERE closed_at IS NULL ORDER BY opened_at DESC LIMIT 1`.
- `cashRevenueOf(int sessionId) → int`: query `SELECT SUM(nominal) FROM orders WHERE cash_session_id=? AND payment_method='cash' AND status='paid'`.

═══════════════════════════════════════════════
FILE 3: lib/data/datasources/cash_session_remote_datasource.dart
═══════════════════════════════════════════════
```dart
class CashSessionRemoteDatasource {
  /// GET /api/cash-sessions/current → null kalau no open.
  Future<Either<String, CashSessionModel?>> getCurrent() async {
    final auth = await AuthLocalDatasource().getAuthData();
    final res = await http.get(
      Uri.parse('${Variables.baseUrl}/api/cash-sessions/current'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['data'] == null) return right(null);
      return right(CashSessionModel.fromMap(body['data']));
    }
    if (res.statusCode == 404) return right(null);  // no current
    return left(res.body);
  }

  /// POST /api/cash-sessions {shift_label, opening_float, opening_note}.
  Future<Either<String, CashSessionModel>> open({
    required String shiftLabel, required int openingFloat, String? openingNote,
  }) async { /* similar */ }

  /// POST /api/cash-sessions/{id}/close {physical_count, cash_in, cash_out, closing_note}.
  Future<Either<String, CashSessionModel>> close({
    required int sessionId, required int physicalCount,
    int cashIn = 0, int cashOut = 0, String? closingNote,
  }) async { /* similar */ }
}
```

═══════════════════════════════════════════════
FILE 4-6: CashSessionBloc + event + state
═══════════════════════════════════════════════
**cash_session_event.dart**:
```dart
@freezed
class CashSessionEvent with _$CashSessionEvent {
  const factory CashSessionEvent.loaded() = _Loaded;
  const factory CashSessionEvent.open({
    required String shiftLabel,
    required int openingFloat,
    String? note,
  }) = _Open;
  const factory CashSessionEvent.close({
    required int physicalCount,
    int cashIn,
    int cashOut,
    String? note,
  }) = _Close;
  const factory CashSessionEvent.reset() = _Reset;
}
```

**cash_session_state.dart**:
```dart
@freezed
class CashSessionState with _$CashSessionState {
  const factory CashSessionState.initial() = _Initial;
  const factory CashSessionState.loading() = _Loading;
  const factory CashSessionState.noSession([CashSessionModel? lastClosed]) = _NoSession;
  const factory CashSessionState.open(CashSessionModel current) = _Active;
  const factory CashSessionState.error(String message) = _Error;
}
```

**cash_session_bloc.dart**:
```dart
class CashSessionBloc extends Bloc<CashSessionEvent, CashSessionState> {
  final CashSessionRemoteDatasource _remote;
  final CashSessionLocalDatasource _local;

  CashSessionBloc({CashSessionRemoteDatasource? remote, CashSessionLocalDatasource? local})
      : _remote = remote ?? CashSessionRemoteDatasource(),
        _local = local ?? CashSessionLocalDatasource.instance,
        super(const CashSessionState.initial()) {
    on<_Loaded>(_onLoaded);
    on<_Open>(_onOpen);
    on<_Close>(_onClose);
    on<_Reset>((e, emit) => emit(const CashSessionState.initial()));
  }

  Future<void> _onLoaded(_, Emitter<CashSessionState> emit) async {
    emit(const CashSessionState.loading());
    final res = await _remote.getCurrent();
    await res.fold(
      (msg) async => emit(CashSessionState.error(msg)),
      (session) async {
        if (session != null) {
          await _mirrorLocal(session);
          emit(CashSessionState.open(session));
          return;
        }
        final last = await _local.getLastClosed();
        emit(CashSessionState.noSession(last));
      },
    );
  }

  Future<void> _onOpen(_Open event, Emitter<CashSessionState> emit) async {
    emit(const CashSessionState.loading());
    final res = await _remote.open(
      shiftLabel: event.shiftLabel, openingFloat: event.openingFloat,
      openingNote: event.note,
    );
    await res.fold(
      (msg) async => emit(CashSessionState.error(msg)),
      (s) async { await _mirrorLocal(s); emit(CashSessionState.open(s)); },
    );
  }

  Future<void> _onClose(_Close event, Emitter<CashSessionState> emit) async {
    final current = state.maybeWhen(open: (s) => s, orElse: () => null);
    if (current?.id == null) {
      emit(const CashSessionState.error('Tidak ada shift aktif'));
      return;
    }
    emit(const CashSessionState.loading());
    final res = await _remote.close(
      sessionId: current!.id!, physicalCount: event.physicalCount,
      cashIn: event.cashIn, cashOut: event.cashOut, closingNote: event.note,
    );
    await res.fold(
      (msg) async => emit(CashSessionState.error(msg)),
      (closed) async { await _mirrorLocal(closed); emit(CashSessionState.noSession(closed)); },
    );
  }

  Future<void> _mirrorLocal(CashSessionModel s) async {
    try { await _local.upsertFromRemote(s); } catch (_) {}  // non-fatal
  }
}
```

═══════════════════════════════════════════════
STEP 5: Upgrade SplashPage
═══════════════════════════════════════════════
Upgrade `splash_page.dart` (step 16): tunggu `CashSessionBloc.loaded` selesai → routing branch:
- `open(_)` → DashboardPage.
- `noSession(_)` → BukaKasirPage (step 34).
- `error(msg)` → snackbar + LoginPage.

═══════════════════════════════════════════════
STEP 6: Wiring
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => CashSessionBloc())`.
- OrderBloc.addPaymentMethod (step 26): isi `cashSessionId` dari `context.read<CashSessionBloc>().state.maybeWhen(open: (s) => s.id, orElse: () => null)`.
````

---

## Verifikasi

1. Run app → splash → `CashSessionBloc.loaded` → kalau ada open di BE → DashboardPage. Kalau noSession → BukaKasirPage (step 34).
2. Tutup app → reopen → state restored dari BE.

## Talking points

1. **Remote-first vs local-first**:
   Untuk shift, BE enforce "1 user 1 open session". Local-only akan bocor (kasir A buka di HP 1, kasir A buka lagi di HP 2 → 2 shift → reporting kacau). Remote = source of truth, local = read cache.

2. **`noSession(lastClosed?)`**:
   Carry last session untuk recap card di BukaKasirPage ("Shift sebelumnya tutup 08:00, total Rp X").

3. **`_mirrorLocal` non-fatal**:
   Local SQLite full disk → don't fail the user. Log dan lanjut.

4. **`cashRevenueOf` query**:
   Dipakai TutupKasirPage untuk hitung expected cash. Pure SQL aggregation lebih cepat dari load semua → filter di Dart.

5. **State `error(msg)`** vs `noSession`:
   Beda penting. Error = BE call gagal (network down, 500). noSession = BE OK tapi memang gak ada session. UX beda: error → retry, noSession → BukaKasir.

## Commit suggestion

```bash
git add lib/data/models/response/cash_session_model.dart lib/data/datasources/cash_session_local_datasource.dart lib/data/datasources/cash_session_remote_datasource.dart lib/presentation/cash_session/bloc/cash_session/ lib/presentation/auth/pages/splash_page.dart lib/main.dart
git commit -m "Step 33: CashSession data + bloc (remote-first, local mirror)"
```

---

➡️ Lanjut ke [Step 34 — BukaKasirPage](./34-buka-kasir.md)
