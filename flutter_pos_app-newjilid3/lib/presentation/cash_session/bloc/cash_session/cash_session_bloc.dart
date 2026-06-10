import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/cash_session_local_datasource.dart';
import '../../../../data/datasources/cash_session_remote_datasource.dart';
import '../../../../data/models/response/cash_session_model.dart';

part 'cash_session_bloc.freezed.dart';
part 'cash_session_event.dart';
part 'cash_session_state.dart';

/// Owns the lifecycle of the cashier's shift: load → open → close.
///
/// **Remote-first** — backend is the source of truth (it enforces the
/// "one open session per user" invariant and rejects orders that have no
/// session). Every successful BE response is mirrored to the local
/// `cash_sessions` table so:
///   - the splash gate can hint a recap before the network call returns,
///   - offline orders (Phase 4 sync) can still carry a `cash_session_id`.
///
/// State machine:
/// - `initial` → fire [loaded] at app boot to hydrate.
/// - `loading` while talking to BE.
/// - `noSession(lastClosed?)` — surface BukaKasirPage.
/// - `open(session)` — DashboardPage uses [current.id] when saving orders.
/// - `error(message)` — surface to user via snackbar.
class CashSessionBloc extends Bloc<CashSessionEvent, CashSessionState> {
  final CashSessionRemoteDatasource _remote;
  final CashSessionLocalDatasource _local;

  CashSessionBloc({
    CashSessionRemoteDatasource? remote,
    CashSessionLocalDatasource? local,
  })  : _remote = remote ?? CashSessionRemoteDatasource(),
        _local = local ?? CashSessionLocalDatasource.instance,
        super(const CashSessionState.initial()) {
    on<_Loaded>(_onLoaded);
    on<_Open>(_onOpen);
    on<_Close>(_onClose);
    on<_Reset>(_onReset);
  }

  Future<void> _onLoaded(_Loaded event, Emitter<CashSessionState> emit) async {
    emit(const CashSessionState.loading());
    final result = await _remote.getCurrent();
    await result.fold(
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
    final result = await _remote.open(
      shiftLabel: event.shiftLabel,
      openingFloat: event.openingFloat,
      openingNote: event.note,
    );
    await result.fold(
      (msg) async => emit(CashSessionState.error(msg)),
      (session) async {
        await _mirrorLocal(session);
        emit(CashSessionState.open(session));
      },
    );
  }

  Future<void> _onClose(_Close event, Emitter<CashSessionState> emit) async {
    final current = state.maybeWhen(
      open: (s) => s,
      orElse: () => null,
    );
    if (current == null || current.id == null) {
      emit(const CashSessionState.error('Tidak ada shift yang aktif'));
      return;
    }
    emit(const CashSessionState.loading());
    final result = await _remote.close(
      sessionId: current.id!,
      physicalCount: event.physicalCount,
      cashIn: event.cashIn,
      cashOut: event.cashOut,
      closingNote: event.note,
    );
    await result.fold(
      (msg) async => emit(CashSessionState.error(msg)),
      (closed) async {
        await _mirrorLocal(closed);
        emit(CashSessionState.noSession(closed));
      },
    );
  }

  void _onReset(_Reset event, Emitter<CashSessionState> emit) {
    emit(const CashSessionState.initial());
  }

  /// Writes the BE row into the local SQLite cache, overwriting any existing
  /// copy. Keeps server-side id, so [cash_session_id] on saved orders
  /// matches the backend's primary key.
  Future<void> _mirrorLocal(CashSessionModel s) async {
    try {
      await _local.upsertFromRemote(s);
    } catch (_) {
      // Local cache failure should never break a successful remote call.
      // Errors here are non-fatal and will be retried on next sync.
    }
  }
}
