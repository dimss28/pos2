import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/cash_session_remote_datasource.dart';

part 'cash_session_summary_bloc.freezed.dart';
part 'cash_session_summary_event.dart';
part 'cash_session_summary_state.dart';

/// Page-scoped bloc for the Tutup Kasir flow. Owns the fetch of
/// `GET /api/cash-sessions/{id}/summary`, which carries:
///   - order_count, items_sold, gross_revenue
///   - cash_revenue
///   - by_method: { 'Tunai': {count, amount}, 'QRIS': {...}, ... }
///   - expected_cash (= opening + cashIn − cashOut + cashRevenue,
///     computed by the BE so the client cannot fudge it)
///
/// Provide via `BlocProvider(create: ...)` inside [TutupKasirPage] so the
/// instance dies with the route.
class CashSessionSummaryBloc
    extends Bloc<CashSessionSummaryEvent, CashSessionSummaryState> {
  final CashSessionRemoteDatasource _remote;

  CashSessionSummaryBloc({CashSessionRemoteDatasource? remote})
      : _remote = remote ?? CashSessionRemoteDatasource(),
        super(const CashSessionSummaryState.initial()) {
    on<_Load>(_onLoad);
    on<_Refresh>(_onRefresh);
  }

  Future<void> _onLoad(
      _Load event, Emitter<CashSessionSummaryState> emit) async {
    emit(const CashSessionSummaryState.loading());
    await _fetch(event.sessionId, emit);
  }

  Future<void> _onRefresh(
      _Refresh event, Emitter<CashSessionSummaryState> emit) async {
    final id = state.maybeWhen(
      loaded: (sid, _) => sid,
      orElse: () => null,
    );
    if (id == null) return;
    emit(const CashSessionSummaryState.loading());
    await _fetch(id, emit);
  }

  Future<void> _fetch(
      int sessionId, Emitter<CashSessionSummaryState> emit) async {
    final result = await _remote.summary(sessionId);
    result.fold(
      (msg) => emit(CashSessionSummaryState.error(msg)),
      (data) => emit(CashSessionSummaryState.loaded(sessionId, data)),
    );
  }
}
