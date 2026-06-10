# 40 — SyncDataPage + SyncBloc + SyncSnapshot

## Goal

`SyncBloc` orchestrate all sync (pull products/categories/promos, push pending orders) dengan `SyncSnapshot` sebagai single-source-of-truth state untuk UI. Plus `SyncDataPage` (manual trigger per-domain + sync all).

## Prerequisite

- Step 39 selesai.
- Datasources: `ProductRemoteDatasource.getProducts`, `OrderRemoteDatasource.sendOrder`, `PromoRemoteDatasource.list` (akan dibuat di step 41).

## Konsep yang diajarkan

- **Single snapshot state** — UI tidak deal with banyak event variant.
- **Domain key** ('products' | 'categories' | 'orders' | 'promos') sebagai discriminator.
- **`refreshSnapshot`** — recompute counts dari local DB tanpa network.
- **Bootstrap** — fire di splash.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Datasources ready: `ProductRemoteDatasource.getProducts/getCategories`, `OrderRemoteDatasource.sendOrder(OrderRequestModel)`, `ProductLocalDatasource` save/load.

Generate 4 file. `PromoRemoteDatasource` & `PromoLocalDatasource` (step 41) ditrigger sebagai stub di sini.

═══════════════════════════════════════════════
FILE 1-3: sync_bloc/event/state
═══════════════════════════════════════════════
**sync_event.dart**:
```dart
@freezed
class SyncEvent with _$SyncEvent {
  const factory SyncEvent.bootstrap() = _Bootstrap;
  const factory SyncEvent.syncAll() = _SyncAll;
  const factory SyncEvent.pullProducts() = _PullProducts;
  const factory SyncEvent.pullCategories() = _PullCategories;
  const factory SyncEvent.pullPromos() = _PullPromos;
  const factory SyncEvent.pushOrders() = _PushOrders;
  const factory SyncEvent.refreshSnapshot() = _RefreshSnapshot;
}
```

**sync_state.dart**:
```dart
@freezed
abstract class SyncSnapshot with _$SyncSnapshot {
  const factory SyncSnapshot({
    @Default(0) int productCount,
    @Default(0) int categoryCount,
    @Default(0) int promoCount,
    @Default(0) int pendingOrderCount,
    DateTime? lastSyncProductsAt,
    DateTime? lastSyncCategoriesAt,
    DateTime? lastSyncPromosAt,
    DateTime? lastSyncOrdersAt,
    String? inProgress,    // 'products' | 'categories' | 'orders' | 'promos'
    @Default(<String, String>{}) Map<String, String> errors,
  }) = _SyncSnapshot;
}

@freezed
abstract class SyncState with _$SyncState {
  const factory SyncState.initial() = _Initial;
  const factory SyncState.ready(SyncSnapshot snapshot) = _Ready;
}
```

**sync_bloc.dart**:
```dart
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ProductRemoteDatasource _productRemote;
  final OrderRemoteDatasource _orderRemote;
  final ProductLocalDatasource _local;
  // PromoRemoteDatasource _promoRemote, PromoLocalDatasource _promoLocal — step 41.

  static const _kLastSyncProducts = 'sync.last_at.products';
  static const _kLastSyncCategories = 'sync.last_at.categories';
  static const _kLastSyncOrders = 'sync.last_at.orders';
  static const _kLastSyncPromos = 'sync.last_at.promos';

  SyncBloc({...defaults...}) : super(const SyncState.initial()) {
    on<_Bootstrap>(_onBootstrap);
    on<_SyncAll>(_onSyncAll);
    on<_PullProducts>(_onPullProducts);
    on<_PullCategories>(_onPullCategories);
    on<_PullPromos>(_onPullPromos);
    on<_PushOrders>(_onPushOrders);
    on<_RefreshSnapshot>(_onRefreshSnapshot);
  }

  SyncSnapshot _current() => state.maybeWhen(ready: (s) => s, orElse: () => const SyncSnapshot());

  Future<SyncSnapshot> _readFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final pCount = (await _local.getAllProduct()).length;
    final cCount = (await _local.getAllCategories()).length;
    final pending = (await _local.getOrderByIsSync()).length;
    return _current().copyWith(
      productCount: pCount, categoryCount: cCount,
      pendingOrderCount: pending,
      lastSyncProductsAt: _parseIso(prefs.getString(_kLastSyncProducts)),
      lastSyncCategoriesAt: _parseIso(prefs.getString(_kLastSyncCategories)),
      lastSyncOrdersAt: _parseIso(prefs.getString(_kLastSyncOrders)),
    );
  }

  DateTime? _parseIso(String? s) => s == null ? null : DateTime.tryParse(s);

  Future<void> _stamp(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, DateTime.now().toIso8601String());
  }

  Future<void> _onBootstrap(_, Emitter<SyncState> emit) async {
    // Pull products + categories paralel; push orders best-effort.
    emit(SyncState.ready(_current().copyWith(inProgress: 'products')));
    await _pullProductsInner(emit);
    emit(SyncState.ready(_current().copyWith(inProgress: 'categories')));
    await _pullCategoriesInner(emit);
    emit(SyncState.ready(_current().copyWith(inProgress: 'orders')));
    await _pushOrdersInner(emit);
    final snap = await _readFromDisk();
    emit(SyncState.ready(snap.copyWith(inProgress: null)));
  }

  Future<void> _onSyncAll(_, Emitter<SyncState> emit) async {
    await _pullProductsInner(emit);
    await _pullCategoriesInner(emit);
    await _pushOrdersInner(emit);
    final snap = await _readFromDisk();
    emit(SyncState.ready(snap.copyWith(inProgress: null)));
  }

  Future<void> _pullProductsInner(Emitter<SyncState> emit) async {
    emit(SyncState.ready(_current().copyWith(inProgress: 'products')));
    final res = await _productRemote.getProducts();
    await res.fold(
      (msg) async {
        emit(SyncState.ready(_current().copyWith(
          inProgress: null,
          errors: {..._current().errors, 'products': msg})));
      },
      (data) async {
        await _local.removeAllProduct();
        await _local.insertAllProduct(data.data);
        await _stamp(_kLastSyncProducts);
        final errs = {..._current().errors}..remove('products');
        final snap = await _readFromDisk();
        emit(SyncState.ready(snap.copyWith(inProgress: null, errors: errs)));
      },
    );
  }

  Future<void> _pullCategoriesInner(Emitter<SyncState> emit) async {
    // sama, untuk categories.
  }

  Future<void> _pushOrdersInner(Emitter<SyncState> emit) async {
    emit(SyncState.ready(_current().copyWith(inProgress: 'orders')));
    final pending = await _local.getOrderByIsSync();
    for (final order in pending) {
      // Build OrderItemModel list dari local items.
      final items = await _local.getOrderItemByOrderIdLocal(order.id!);
      final req = OrderRequestModel(
        transactionTime: order.transactionTime,
        kasirId: order.idKasir,
        totalPrice: order.totalPrice,
        totalItem: order.totalQuantity,
        paymentMethod: order.paymentMethod,
        orderItems: items,
        promoId: order.promoId,
        discountAmount: order.discountAmount,
      );
      final res = await _orderRemote.sendOrder(req);
      await res.fold(
        (_) async {/* keep is_sync = 0 */},
        (_) async { await _local.updateIsSyncOrderById(order.id!); },
      );
    }
    await _stamp(_kLastSyncOrders);
    final snap = await _readFromDisk();
    emit(SyncState.ready(snap.copyWith(inProgress: null)));
  }

  Future<void> _onPullProducts(_, Emitter<SyncState> emit) => _pullProductsInner(emit);
  Future<void> _onPullCategories(_, Emitter<SyncState> emit) => _pullCategoriesInner(emit);
  Future<void> _onPushOrders(_, Emitter<SyncState> emit) => _pushOrdersInner(emit);
  Future<void> _onPullPromos(_, Emitter<SyncState> emit) async { /* TODO step 41 */ }

  Future<void> _onRefreshSnapshot(_, Emitter<SyncState> emit) async {
    emit(SyncState.ready(await _readFromDisk()));
  }
}
```

═══════════════════════════════════════════════
FILE 4: lib/presentation/setting/pages/sync_data_page.dart
═══════════════════════════════════════════════
StatefulWidget. Build BlocBuilder<SyncBloc>:
- Scaffold > AppAppBar('Sinkronisasi Data').
- body ListView padding 16:
  1. AppCard summary: 4 KV row (Produk, Kategori, Promo, Pending).
  2. SpaceHeight 16.
  3. AppListGroup per domain:
     - Row: icon + Column [Text 'Produk', Text 'Terakhir: ${snapshot.lastSyncProductsAt?.toFormattedTime() ?? "Belum pernah"}'] + AppButton.outline('Sync', loading: inProgress == 'products', onPressed: () => bloc.add(pullProducts())).
     - Same untuk Categories, Promos, Pending Orders (button label "Push" untuk orders).
  4. SpaceHeight 16.
  5. AppButton.primary('Sinkronkan Semua', loading: inProgress != null, onPressed: () => bloc.add(syncAll())).
  6. Kalau ada errors → AppBanner.error per error.

═══════════════════════════════════════════════
WIRING
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => SyncBloc()..add(refreshSnapshot()))`.
- DashboardPage badge pendingSync: nested BlocBuilder `SyncBloc.snapshot.pendingOrderCount`.
- OrderBloc.persistLocal listener: emit success → `context.read<SyncBloc>().add(refreshSnapshot())` supaya badge update.
- SplashPage step 16/33: fire `SyncBloc.bootstrap()`.
````

---

## Verifikasi

1. Setting → Sinkronisasi → tampil 4 domain count + last-sync.
2. Tap "Sync" Produk → BE call → local updated.
3. Bikin order offline (BE matikan) → pendingOrderCount > 0, badge Setting tab.
4. BE nyala → tap "Push" → orders sync, pending = 0.

## Talking points

1. **`SyncSnapshot` single state**:
   UI baca 1 state, gak perlu jaga multi-bloc orchestration. Pola "snapshot" cocok untuk dashboard-like state.

2. **`inProgress: 'products'`** string discriminator:
   Bisa enum, tapi string + switch lebih fleksibel. UI cek `inProgress == 'products'` untuk loading spinner per domain.

3. **`refreshSnapshot` tanpa network**:
   Cepat — recompute dari local DB. Trigger setelah persistLocal supaya badge update.

4. **Push best-effort per order**:
   Loop pending; satu gagal, lanjut yang lain. is_sync tetap 0 untuk retry berikutnya.

5. **`errors` map per domain**:
   Surface ke UI banner per domain. User tahu apa yang gagal.

6. **`removeAllProduct + insertAllProduct`** (full replace):
   Lebih simple daripada diff-merge. Trade-off: kalau pending edit lokal hilang. Untuk POS yang BE = source of truth, OK.

## Commit suggestion

```bash
git add lib/presentation/setting/bloc/sync/ lib/presentation/setting/pages/sync_data_page.dart lib/main.dart lib/presentation/home/pages/dashboard_page.dart
git commit -m "Step 40: SyncBloc + SyncDataPage with per-domain status"
```

---

➡️ Lanjut ke [Step 41 — Promo Management](./41-promo-management.md)
