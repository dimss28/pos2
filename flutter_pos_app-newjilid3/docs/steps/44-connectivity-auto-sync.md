# 44 — ConnectivityBloc + Auto-Sync saat Online Restored

## Goal

`ConnectivityBloc` listen `connectivity_plus` stream → emit 4 state (unknown/online/offline/restored). Di `main.dart`, `BlocListener<ConnectivityBloc>` trigger `SyncBloc.pushOrders + pullPromos` saat state `restored`.

## Prerequisite

- Step 43 selesai.
- Package `connectivity_plus: ^6.0.5`.

## Konsep yang diajarkan

- **`Stream` subscription** lifecycle di Bloc.
- **`restored` sebagai transition state** — distinct dari `online` (yang persist).
- **Decoupling**: ConnectivityBloc tidak depend SyncBloc; coupling di main.dart listener.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Package `connectivity_plus` sudah di pubspec.

Generate 4 file.

═══════════════════════════════════════════════
FILE 1-3: ConnectivityBloc + event + state
═══════════════════════════════════════════════
**connectivity_event.dart**:
```dart
@freezed
class ConnectivityEvent with _$ConnectivityEvent {
  const factory ConnectivityEvent.started() = _Started;
  const factory ConnectivityEvent.changed(List<ConnectivityResult> results) = _Changed;
}
```

**connectivity_state.dart**:
```dart
@freezed
class ConnectivityState with _$ConnectivityState {
  const factory ConnectivityState.unknown() = _Unknown;
  const factory ConnectivityState.online() = _Online;
  const factory ConnectivityState.offline() = _Offline;
  /// One-shot transition: was offline → now online. Emit ONE TIME per
  /// online recovery. Useful for triggering auto-sync.
  const factory ConnectivityState.restored() = _Restored;
}
```

**connectivity_bloc.dart**:
```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connectivity_bloc.freezed.dart';
part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _wasOffline = false;

  ConnectivityBloc({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const ConnectivityState.unknown()) {
    on<_Started>(_onStarted);
    on<_Changed>(_onChanged);
  }

  Future<void> _onStarted(_, Emitter<ConnectivityState> emit) async {
    final initial = await _connectivity.checkConnectivity();
    _applyResults(initial, emit);
    _sub = _connectivity.onConnectivityChanged.listen(
      (results) => add(ConnectivityEvent.changed(results)),
    );
  }

  Future<void> _onChanged(_Changed event, Emitter<ConnectivityState> emit) async {
    _applyResults(event.results, emit);
  }

  void _applyResults(List<ConnectivityResult> results, Emitter<ConnectivityState> emit) {
    // Online jika ada salah satu interface aktif.
    final online = results.any((r) =>
      r == ConnectivityResult.wifi || r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet || r == ConnectivityResult.vpn);

    if (!online) {
      _wasOffline = true;
      emit(const ConnectivityState.offline());
      return;
    }

    if (_wasOffline) {
      // Emit `restored` once, then `online`.
      emit(const ConnectivityState.restored());
      _wasOffline = false;
    }
    emit(const ConnectivityState.online());
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
```

═══════════════════════════════════════════════
STEP 4: Update main.dart
═══════════════════════════════════════════════
- Tambah BlocProvider:
  ```dart
  BlocProvider(create: (_) => ConnectivityBloc()..add(const ConnectivityEvent.started())),
  ```
- Wrap MaterialApp dengan BlocListener:
  ```dart
  child: BlocListener<ConnectivityBloc, ConnectivityState>(
    listenWhen: (prev, next) => next.maybeWhen(restored: () => true, orElse: () => false),
    listener: (context, _) {
      context.read<SyncBloc>().add(const SyncEvent.pushOrders());
      context.read<SyncBloc>().add(const SyncEvent.pullPromos());
    },
    child: BlocBuilder<ThemeBloc, ThemeState>(...),
  ),
  ```

═══════════════════════════════════════════════
STEP 5: Offline banner di app shell (optional)
═══════════════════════════════════════════════
Di DashboardPage atau wrapper, tambah BlocBuilder<ConnectivityBloc> untuk show banner kalau `offline()`:
```dart
state.maybeWhen(
  offline: () => AppBanner(kind: warning, title: 'Mode offline', body: 'Transaksi disimpan lokal, akan di-sync saat online.'),
  orElse: () => SizedBox.shrink(),
)
```
````

---

## Verifikasi

1. Run app online → state online.
2. Matikan wifi/data → banner offline muncul (kalau implement).
3. Bikin order → tersimpan lokal (is_sync=0), pending count naik.
4. Nyalakan wifi → restored → SyncBloc.pushOrders → orders sync → pending=0.
5. Cek developer.log: `[ConnectivityBloc] _Offline → _Restored → _Online`.

## Talking points

1. **`restored` sebagai one-shot**:
   Beda dari `online` (persistent). Dipakai untuk trigger one-time action (sync). Kalau pakai online → sync tiap polling check → boros bandwidth.

2. **`_wasOffline` flag**:
   Bloc tracking internal: 'pernah offline?' Reset setelah emit restored. Cold-boot online → langsung online, no restored.

3. **Decoupling ConnectivityBloc dari SyncBloc**:
   ConnectivityBloc tidak import SyncBloc. Coupling di main.dart listener. Bloc tetap testable in isolation.

4. **`listenWhen`** vs filter di listener:
   `listenWhen: (prev, next) => predicate` — Flutter skip listener call kalau false. Lebih efficient daripada `if` di dalam listener.

5. **`onConnectivityChanged` return List<ConnectivityResult>`** (sejak connectivity_plus v6):
   Multi-interface (wifi + vpn aktif sekaligus). Treat online jika salah satu aktif.

6. **`Connectivity` check ≠ internet check**:
   Wifi connected tapi gak ada internet (captive portal) → app think online tapi BE call fail. Untuk POS, acceptable: pengguna akan tahu kalau sync gagal.

## Commit suggestion

```bash
git add lib/presentation/connectivity/ lib/main.dart
git commit -m "Step 44: ConnectivityBloc + auto-sync on restored"
```

---

➡️ Lanjut ke [Step 45 — Play Store Prep](./45-play-store-prep.md)
