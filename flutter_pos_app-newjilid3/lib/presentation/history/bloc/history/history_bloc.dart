import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/data/datasources/order_remote_datasource.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_event.dart';
part 'history_state.dart';
part 'history_bloc.freezed.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ProductLocalDatasource _local;
  final OrderRemoteDatasource _remote;

  HistoryBloc({
    ProductLocalDatasource? local,
    OrderRemoteDatasource? remote,
  })  : _local = local ?? ProductLocalDatasource.instance,
        _remote = remote ?? OrderRemoteDatasource(),
        super(const HistoryState.initial()) {
    on<_Fetch>(_onFetch);
    on<_Refresh>(_onRefresh);
    on<_FilterByRange>(_onFilter);
  }

  Future<void> _onFetch(_Fetch event, Emitter<HistoryState> emit) async {
    emit(const HistoryState.loading());
    try {
      final merged = await _loadMerged();
      final filtered = applyFilter(
        merged,
        HistoryDateRange.all,
        null,
        null,
      );
      emit(HistoryState.success(all: merged, filtered: filtered));
    } catch (e) {
      emit(HistoryState.error(e.toString()));
    }
  }

  Future<void> _onRefresh(_Refresh event, Emitter<HistoryState> emit) async {
    // Preserve the active filter so pull-to-refresh doesn't reset the user's
    // chosen range. If we don't have a prior success state, fall back to fetch.
    final prev = state;
    if (prev is! _Success) {
      add(const HistoryEvent.fetch());
      return;
    }
    try {
      final merged = await _loadMerged();
      final filtered = applyFilter(
        merged,
        prev.range,
        prev.customFrom,
        prev.customTo,
      );
      emit(HistoryState.success(
        all: merged,
        filtered: filtered,
        range: prev.range,
        customFrom: prev.customFrom,
        customTo: prev.customTo,
      ));
    } catch (_) {
      // Refresh failure: keep showing the prior data rather than wiping it.
    }
  }

  /// Pull from BE first (so multi-device orders show up); fall back to local
  /// only on failure. When BE succeeds, the server list is authoritative for
  /// already-synced rows — locally pending (un-synced) rows are appended.
  Future<List<OrderModel>> _loadMerged() async {
    final localOrders = await _local.getAllOrder();
    final remoteRes = await _remote.list().catchError(
      (_) => left<String, List<OrderModel>>('network'),
    );
    return remoteRes.fold(
      (_) => localOrders, // offline / failure → local-only
      (remote) => _mergeRemoteAndLocal(remote, localOrders),
    );
  }

  /// Server is source of truth for synced rows. Local rows that aren't yet
  /// synced (`isSync == false`) get appended so the user can still see them
  /// even before the next push.
  static List<OrderModel> _mergeRemoteAndLocal(
    List<OrderModel> remote,
    List<OrderModel> local,
  ) {
    final pendingLocal = local.where((o) => !o.isSync).toList();
    return [...remote, ...pendingLocal];
  }

  void _onFilter(_FilterByRange event, Emitter<HistoryState> emit) {
    final current = state.maybeWhen(
      success: (all, _, __, ___, ____) => all,
      orElse: () => <OrderModel>[],
    );
    final filtered =
        applyFilter(current, event.range, event.from, event.to);
    emit(HistoryState.success(
      all: current,
      filtered: filtered,
      range: event.range,
      customFrom: event.from,
      customTo: event.to,
    ));
  }

  // ─── pure helpers (also exported for tests) ────────────────────────────

  /// Filter [orders] by the given [range]. Pure function — pass [now] to
  /// override `DateTime.now()` for deterministic tests.
  static List<OrderModel> applyFilter(
    List<OrderModel> orders,
    HistoryDateRange range,
    DateTime? from,
    DateTime? to, {
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    DateTime? start;
    DateTime? end;
    switch (range) {
      case HistoryDateRange.all:
        return orders;
      case HistoryDateRange.today:
        start = DateTime(n.year, n.month, n.day);
        end = start.add(const Duration(days: 1));
      case HistoryDateRange.week:
        // ISO week: Monday → Sunday.
        final mondayOffset = n.weekday - 1;
        start = DateTime(n.year, n.month, n.day)
            .subtract(Duration(days: mondayOffset));
        end = start.add(const Duration(days: 7));
      case HistoryDateRange.month:
        start = DateTime(n.year, n.month, 1);
        end = DateTime(n.year, n.month + 1, 1);
      case HistoryDateRange.custom:
        start = from;
        end = to?.add(const Duration(days: 1));
    }
    return orders.where((o) {
      final ts = DateTime.tryParse(o.transactionTime);
      if (ts == null) return false;
      if (start != null && ts.isBefore(start)) return false;
      if (end != null && !ts.isBefore(end)) return false;
      return true;
    }).toList();
  }

  /// Group [orders] by calendar date. Returns map keyed by `DateTime` at
  /// midnight, values sorted descending by transaction time within each group.
  /// Caller decides ordering of keys (typically newest day first).
  static Map<DateTime, List<OrderModel>> groupByDay(List<OrderModel> orders) {
    final map = <DateTime, List<OrderModel>>{};
    for (final o in orders) {
      final ts = DateTime.tryParse(o.transactionTime);
      if (ts == null) continue;
      final day = DateTime(ts.year, ts.month, ts.day);
      map.putIfAbsent(day, () => []).add(o);
    }
    for (final list in map.values) {
      list.sort((a, b) =>
          b.transactionTime.compareTo(a.transactionTime));
    }
    return map;
  }

  /// Sum of [totalPrice] across [orders] (typed convenience).
  static int sumRevenue(List<OrderModel> orders) =>
      orders.fold<int>(0, (s, o) => s + o.totalPrice);
}
