import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/datasources/order_remote_datasource.dart';
import '../../../../data/datasources/product_local_datasource.dart';
import '../../../../data/datasources/product_remote_datasource.dart';
import '../../../../data/datasources/promo_local_datasource.dart';
import '../../../../data/datasources/promo_remote_datasource.dart';
import '../../../../data/models/request/order_request_model.dart';

part 'sync_bloc.freezed.dart';
part 'sync_event.dart';
part 'sync_state.dart';

/// Orchestrates all server↔local sync.
///
/// **Triggers:**
/// - [bootstrap] — fired by SplashPage right after a successful auth gate.
///   Pulls products + categories so the cashier can run offline; pushes any
///   pending orders best-effort. Failure does not block routing (we fall
///   back to whatever is already cached locally).
/// - [pullProducts] / [pullCategories] / [pushOrders] — per-domain manual
///   trigger from the Sinkronisasi Data settings page.
/// - [syncAll] — the "Sinkronkan semua" CTA on the same page.
/// - [refreshSnapshot] — recompute counts from local DB without touching
///   the network (call after a new local order is saved).
///
/// **Source of truth:**
/// - Products / Categories: backend (pull replaces local table).
/// - Orders: local (push uploads `is_sync=0` rows, then marks them `is_sync=1`).
/// - Cash sessions: backend (handled by [CashSessionBloc] — not here).
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ProductRemoteDatasource _productRemote;
  final OrderRemoteDatasource _orderRemote;
  final ProductLocalDatasource _local;
  final PromoRemoteDatasource _promoRemote;
  final PromoLocalDatasource _promoLocal;

  static const _kLastSyncProducts = 'sync.last_at.products';
  static const _kLastSyncCategories = 'sync.last_at.categories';
  static const _kLastSyncOrders = 'sync.last_at.orders';
  static const _kLastSyncPromos = 'sync.last_at.promos';

  static const _domainProducts = 'products';
  static const _domainCategories = 'categories';
  static const _domainOrders = 'orders';
  static const _domainPromos = 'promos';

  SyncBloc({
    ProductRemoteDatasource? productRemote,
    OrderRemoteDatasource? orderRemote,
    ProductLocalDatasource? local,
    PromoRemoteDatasource? promoRemote,
    PromoLocalDatasource? promoLocal,
  })  : _productRemote = productRemote ?? ProductRemoteDatasource(),
        _orderRemote = orderRemote ?? OrderRemoteDatasource(),
        _local = local ?? ProductLocalDatasource.instance,
        _promoRemote = promoRemote ?? PromoRemoteDatasource(),
        _promoLocal = promoLocal ?? PromoLocalDatasource.instance,
        super(const SyncState.initial()) {
    on<_Bootstrap>(_onBootstrap);
    on<_SyncAll>(_onSyncAll);
    on<_PullProducts>(_onPullProducts);
    on<_PullCategories>(_onPullCategories);
    on<_PullPromos>(_onPullPromos);
    on<_PushOrders>(_onPushOrders);
    on<_RefreshSnapshot>(_onRefreshSnapshot);
  }

  // ─── snapshot helpers ─────────────────────────────────────────────────

  SyncSnapshot _currentSnapshot() =>
      state.maybeWhen(ready: (s) => s, orElse: () => const SyncSnapshot());

  void _emit(Emitter<SyncState> emit, SyncSnapshot s) {
    emit(SyncState.ready(s));
  }

  /// Recompute counts + last-sync timestamps from the local DB / SharedPrefs.
  /// Preserves [inProgress] and [errors] from the current state.
  Future<SyncSnapshot> _readSnapshotFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final productCount = (await _local.getAllProduct()).length;
    final categoryCount = (await _local.getAllCategories()).length;
    final promoCount = (await _promoLocal.getAll()).length;
    final pending = (await _local.getOrderByIsSync()).length;
    final cur = _currentSnapshot();
    return cur.copyWith(
      productCount: productCount,
      categoryCount: categoryCount,
      promoCount: promoCount,
      pendingOrderCount: pending,
      lastSyncProductsAt: _parseIso(prefs.getString(_kLastSyncProducts)),
      lastSyncCategoriesAt: _parseIso(prefs.getString(_kLastSyncCategories)),
      lastSyncPromosAt: _parseIso(prefs.getString(_kLastSyncPromos)),
      lastSyncOrdersAt: _parseIso(prefs.getString(_kLastSyncOrders)),
    );
  }

  static DateTime? _parseIso(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);

  Future<void> _stampNow(String prefsKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, DateTime.now().toIso8601String());
  }

  // ─── handlers ─────────────────────────────────────────────────────────

  Future<void> _onRefreshSnapshot(
      _RefreshSnapshot event, Emitter<SyncState> emit) async {
    final snap = await _readSnapshotFromDisk();
    _emit(emit, snap);
  }

  Future<void> _onBootstrap(
      _Bootstrap event, Emitter<SyncState> emit) async {
    var snap = await _readSnapshotFromDisk();
    // CRITICAL: set inProgress before the first emit so the SplashPage gate
    // doesn't read the (default-null) disk snapshot and route prematurely.
    // The marker is cleared at the end after all pulls complete.
    snap = snap.copyWith(inProgress: 'bootstrap');
    _emit(emit, snap);

    if (kDebugMode) debugPrint('[Sync] bootstrap: start');

    // Order matters: push pending orders FIRST so the BE has already
    // decremented stock. Then pulling products refills local with the
    // post-decrement values, avoiding a double-decrement window.
    snap = await _runPushOrders(snap, emit);
    snap = await _runPullProducts(snap, emit);
    snap = await _runPullCategories(snap, emit);
    snap = await _runPullPromos(snap, emit);

    snap = snap.copyWith(inProgress: null);
    _emit(emit, snap);

    if (kDebugMode) {
      debugPrint(
        '[Sync] bootstrap: done products=${snap.productCount} '
        'categories=${snap.categoryCount} pending=${snap.pendingOrderCount} '
        'errors=${snap.errors}',
      );
    }
  }

  Future<void> _onSyncAll(_SyncAll event, Emitter<SyncState> emit) async {
    var snap = _currentSnapshot();
    snap = await _runPushOrders(snap, emit);
    snap = await _runPullProducts(snap, emit);
    snap = await _runPullCategories(snap, emit);
    snap = await _runPullPromos(snap, emit);
    snap = snap.copyWith(inProgress: null);
    _emit(emit, snap);
  }

  Future<void> _onPullPromos(
      _PullPromos event, Emitter<SyncState> emit) async {
    var snap = _currentSnapshot();
    snap = await _runPullPromos(snap, emit);
    snap = snap.copyWith(inProgress: null);
    _emit(emit, snap);
  }

  Future<void> _onPullProducts(
      _PullProducts event, Emitter<SyncState> emit) async {
    var snap = _currentSnapshot();
    snap = await _runPullProducts(snap, emit);
    snap = snap.copyWith(inProgress: null);
    _emit(emit, snap);
  }

  Future<void> _onPullCategories(
      _PullCategories event, Emitter<SyncState> emit) async {
    var snap = _currentSnapshot();
    snap = await _runPullCategories(snap, emit);
    snap = snap.copyWith(inProgress: null);
    _emit(emit, snap);
  }

  Future<void> _onPushOrders(
      _PushOrders event, Emitter<SyncState> emit) async {
    var snap = _currentSnapshot();
    snap = await _runPushOrders(snap, emit);
    snap = snap.copyWith(inProgress: null);
    _emit(emit, snap);
  }

  // ─── domain operations ────────────────────────────────────────────────

  Future<SyncSnapshot> _runPullProducts(
      SyncSnapshot snap, Emitter<SyncState> emit) async {
    snap = snap.copyWith(
      inProgress: _domainProducts,
      errors: _without(snap.errors, _domainProducts),
    );
    _emit(emit, snap);

    final result = await _productRemote.getProducts();
    if (result.isLeft()) {
      final msg =
          result.swap().getOrElse(() => 'Gagal sinkron produk');
      if (kDebugMode) debugPrint('[Sync] pullProducts failed: $msg');
      return snap.copyWith(
        errors: _with(snap.errors, _domainProducts, _shorten(msg)),
      );
    }
    final response = result.getOrElse(
        () => throw StateError('unreachable: isLeft already false'));
    if (kDebugMode) {
      debugPrint(
        '[Sync] pullProducts: BE returned ${response.data.length} products',
      );
    }
    await _local.removeAllProduct();
    await _local.insertAllProduct(response.data);
    final inserted =
        (await _local.getAllProduct()).length;
    if (kDebugMode) {
      debugPrint('[Sync] pullProducts: local now has $inserted rows');
    }
    await _stampNow(_kLastSyncProducts);
    final fresh = await _readSnapshotFromDisk();
    return fresh.copyWith(errors: _without(snap.errors, _domainProducts));
  }

  Future<SyncSnapshot> _runPullPromos(
      SyncSnapshot snap, Emitter<SyncState> emit) async {
    snap = snap.copyWith(
      inProgress: _domainPromos,
      errors: _without(snap.errors, _domainPromos),
    );
    _emit(emit, snap);

    final result = await _promoRemote.list();
    if (result.isLeft()) {
      final msg =
          result.swap().getOrElse(() => 'Gagal sinkron promo');
      if (kDebugMode) debugPrint('[Sync] pullPromos failed: $msg');
      return snap.copyWith(
        errors: _with(snap.errors, _domainPromos, _shorten(msg)),
      );
    }
    final promos = result.getOrElse(
        () => throw StateError('unreachable: isLeft already false'));
    await _promoLocal.replaceAll(promos);
    await _stampNow(_kLastSyncPromos);
    final fresh = await _readSnapshotFromDisk();
    return fresh.copyWith(errors: _without(snap.errors, _domainPromos));
  }

  Future<SyncSnapshot> _runPullCategories(
      SyncSnapshot snap, Emitter<SyncState> emit) async {
    snap = snap.copyWith(
      inProgress: _domainCategories,
      errors: _without(snap.errors, _domainCategories),
    );
    _emit(emit, snap);

    final result = await _productRemote.getCategories();
    if (result.isLeft()) {
      final msg =
          result.swap().getOrElse(() => 'Gagal sinkron kategori');
      if (kDebugMode) debugPrint('[Sync] pullCategories failed: $msg');
      return snap.copyWith(
        errors: _with(snap.errors, _domainCategories, _shorten(msg)),
      );
    }
    final response = result.getOrElse(
        () => throw StateError('unreachable: isLeft already false'));
    await _local.removeAllCategories();
    await _local.insertAllCategories(response.data);
    await _stampNow(_kLastSyncCategories);
    final fresh = await _readSnapshotFromDisk();
    return fresh.copyWith(errors: _without(snap.errors, _domainCategories));
  }

  Future<SyncSnapshot> _runPushOrders(
      SyncSnapshot snap, Emitter<SyncState> emit) async {
    snap = snap.copyWith(
      inProgress: _domainOrders,
      errors: _without(snap.errors, _domainOrders),
    );
    _emit(emit, snap);

    final pending = await _local.getOrderByIsSync();
    var failed = 0;
    for (final order in pending) {
      final items = await _local.getOrderItemByOrderIdLocal(order.id!);
      final req = OrderRequestModel(
        clientUuid: order.clientUuid,
        transactionTime: order.transactionTime,
        totalItem: order.totalQuantity,
        totalPrice: order.totalPrice,
        kasirId: order.idKasir,
        paymentMethod: order.paymentMethod,
        promoId: order.promoId,
        discountAmount: order.discountAmount,
        cashSessionId: order.cashSessionId,
        amountPaid: order.nominalBayar,
        orderItems: items,
      );
      final ok = await _orderRemote.sendOrder(req);
      if (ok) {
        await _local.updateIsSyncOrderById(order.id!);
      } else {
        failed++;
      }
    }
    if (failed == 0 && pending.isNotEmpty) {
      await _stampNow(_kLastSyncOrders);
    } else if (pending.isEmpty) {
      // Nothing to push counts as a clean sync.
      await _stampNow(_kLastSyncOrders);
    }
    final fresh = await _readSnapshotFromDisk();
    return fresh.copyWith(
      errors: failed > 0
          ? _with(snap.errors, _domainOrders,
              '$failed order gagal dikirim, akan dicoba lagi.')
          : _without(snap.errors, _domainOrders),
    );
  }

  // ─── tiny map helpers (Freezed maps are immutable) ─────────────────────

  Map<String, String> _with(Map<String, String> m, String k, String v) =>
      {...m, k: v};
  Map<String, String> _without(Map<String, String> m, String k) =>
      {...m}..remove(k);

  /// Trim a server error message to something snackbar-friendly.
  String _shorten(String s) => s.length > 120 ? '${s.substring(0, 120)}…' : s;
}
