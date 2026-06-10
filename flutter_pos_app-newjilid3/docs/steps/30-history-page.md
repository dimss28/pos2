# 30 — HistoryBloc + HistoryPage (Filter Tanggal, Group by Day)

## Goal

`HistoryBloc` (fetch lokal + remote merge, filter range Today/Week/Month/Custom) + `HistoryPage` (chips filter, group by day dengan sticky header, expandable card per transaksi).

## Prerequisite

- Step 29 selesai.
- `OrderRemoteDatasource.list()` — fetch transaksi dari BE.

## Konsep yang diajarkan

- **Merge remote + local** — BE authoritative untuk synced, local-pending appended.
- **Pure helpers static** (`applyFilter`, `groupByDay`, `sumRevenue`) — testable.
- **`DateTime` arithmetic** — ISO week (Mon-Sun), bulan boundary.
- **`groupBy`** dengan `Map<DateTime, List>`.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `ProductLocalDatasource.getAllOrder()` + `OrderModel` ready. `OrderRemoteDatasource.list()` perlu dibuat.

═══════════════════════════════════════════════
STEP 1: Tambah method di OrderRemoteDatasource
═══════════════════════════════════════════════
File `lib/data/datasources/order_remote_datasource.dart` (kalau belum ada, create):
```dart
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/variables.dart';
import 'auth_local_datasource.dart';
import '../models/request/order_request_model.dart';
import '../../presentation/order/models/order_model.dart';

class OrderRemoteDatasource {
  /// POST /api/orders — dipakai SyncBloc.
  Future<Either<String, String>> sendOrder(OrderRequestModel req) async {
    final auth = await AuthLocalDatasource().getAuthData();
    final res = await http.post(
      Uri.parse('${Variables.baseUrl}/api/orders'),
      headers: {'Authorization': 'Bearer ${auth.token}', 'Content-Type': 'application/json'},
      body: req.toJson(),
    );
    return res.statusCode == 200 || res.statusCode == 201
        ? right(res.body) : left(res.body);
  }

  /// GET /api/orders — list history dari BE.
  Future<Either<String, List<OrderModel>>> list() async {
    final auth = await AuthLocalDatasource().getAuthData();
    final res = await http.get(
      Uri.parse('${Variables.baseUrl}/api/orders'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );
    if (res.statusCode != 200) return left(res.body);
    // BE return {data: [...]}. Parse manual karena no wrapper class.
    try {
      final body = res.body;
      // Skip parsing detail di sini — caller treat list-of-map → OrderModel.fromMap.
      // Asumsi: BE-mu return list orders di field `data`. Sesuaikan kalau beda.
      final decoded = (jsonDecode(body)['data'] as List?) ?? const [];
      return right(decoded.map((e) => OrderModel.fromMap(e as Map<String, dynamic>)).toList());
    } catch (e) { return left('Parse error: $e'); }
  }

  /// PATCH /api/orders/{id}/refund — body {reason, note}.
  Future<Either<String, OrderModel>> refund({
    required int orderId, required String reason, String? note,
  }) async {
    final auth = await AuthLocalDatasource().getAuthData();
    final res = await http.patch(
      Uri.parse('${Variables.baseUrl}/api/orders/$orderId/refund'),
      headers: {'Authorization': 'Bearer ${auth.token}', 'Content-Type': 'application/json'},
      body: jsonEncode({'reason': reason, if (note != null) 'note': note}),
    );
    if (res.statusCode != 200) return left(res.body);
    try {
      final m = jsonDecode(res.body)['data'] as Map<String, dynamic>;
      return right(OrderModel.fromMap(m));
    } catch (e) { return left('Parse error: $e'); }
  }
}
```

═══════════════════════════════════════════════
STEP 2: HistoryBloc + event + state
═══════════════════════════════════════════════
**history_event.dart**:
```dart
@freezed
sealed class HistoryEvent with _$HistoryEvent {
  const factory HistoryEvent.fetch() = _Fetch;
  const factory HistoryEvent.refresh() = _Refresh;
  const factory HistoryEvent.filterByRange({
    required HistoryDateRange range,
    DateTime? from,
    DateTime? to,
  }) = _FilterByRange;
}

enum HistoryDateRange { today, week, month, custom }
```

**history_state.dart**:
```dart
@freezed
sealed class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = _Initial;
  const factory HistoryState.loading() = _Loading;
  const factory HistoryState.success({
    required List<OrderModel> all,
    required List<OrderModel> filtered,
    @Default(HistoryDateRange.today) HistoryDateRange range,
    DateTime? customFrom, DateTime? customTo,
  }) = _Success;
  const factory HistoryState.error(String message) = _Error;
}
```

**history_bloc.dart**:
```dart
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ProductLocalDatasource _local;
  final OrderRemoteDatasource _remote;

  HistoryBloc({ProductLocalDatasource? local, OrderRemoteDatasource? remote})
      : _local = local ?? ProductLocalDatasource.instance,
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
      final filtered = applyFilter(merged, HistoryDateRange.today, null, null);
      emit(HistoryState.success(all: merged, filtered: filtered));
    } catch (e) { emit(HistoryState.error(e.toString())); }
  }

  Future<void> _onRefresh(_Refresh event, Emitter<HistoryState> emit) async {
    final prev = state;
    if (prev is! _Success) { add(const HistoryEvent.fetch()); return; }
    try {
      final merged = await _loadMerged();
      final filtered = applyFilter(merged, prev.range, prev.customFrom, prev.customTo);
      emit(HistoryState.success(
        all: merged, filtered: filtered, range: prev.range,
        customFrom: prev.customFrom, customTo: prev.customTo));
    } catch (_) {}  // keep prev data on refresh fail
  }

  void _onFilter(_FilterByRange event, Emitter<HistoryState> emit) {
    final all = state.maybeWhen(
      success: (all, _, __, ___, ____) => all, orElse: () => <OrderModel>[]);
    final filtered = applyFilter(all, event.range, event.from, event.to);
    emit(HistoryState.success(
      all: all, filtered: filtered, range: event.range,
      customFrom: event.from, customTo: event.to));
  }

  Future<List<OrderModel>> _loadMerged() async {
    final localOrders = await _local.getAllOrder();
    final remoteRes = await _remote.list().catchError(
      (_) => left<String, List<OrderModel>>('network'));
    return remoteRes.fold(
      (_) => localOrders,  // offline → local only
      (remote) => _mergeRemoteAndLocal(remote, localOrders),
    );
  }

  static List<OrderModel> _mergeRemoteAndLocal(List<OrderModel> remote, List<OrderModel> local) {
    final pendingLocal = local.where((o) => !o.isSync).toList();
    return [...remote, ...pendingLocal];
  }

  /// Pure helper (testable).
  static List<OrderModel> applyFilter(
      List<OrderModel> orders, HistoryDateRange range,
      DateTime? from, DateTime? to, {DateTime? now}) {
    final n = now ?? DateTime.now();
    DateTime? start, end;
    switch (range) {
      case HistoryDateRange.today:
        start = DateTime(n.year, n.month, n.day);
        end = start.add(const Duration(days: 1));
      case HistoryDateRange.week:
        final mondayOffset = n.weekday - 1;
        start = DateTime(n.year, n.month, n.day).subtract(Duration(days: mondayOffset));
        end = start.add(const Duration(days: 7));
      case HistoryDateRange.month:
        start = DateTime(n.year, n.month, 1);
        end = DateTime(n.year, n.month + 1, 1);
      case HistoryDateRange.custom:
        start = from; end = to?.add(const Duration(days: 1));
    }
    return orders.where((o) {
      final ts = DateTime.tryParse(o.transactionTime);
      if (ts == null) return false;
      if (start != null && ts.isBefore(start)) return false;
      if (end != null && !ts.isBefore(end)) return false;
      return true;
    }).toList();
  }

  static Map<DateTime, List<OrderModel>> groupByDay(List<OrderModel> orders) {
    final map = <DateTime, List<OrderModel>>{};
    for (final o in orders) {
      final ts = DateTime.tryParse(o.transactionTime);
      if (ts == null) continue;
      final day = DateTime(ts.year, ts.month, ts.day);
      map.putIfAbsent(day, () => []).add(o);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.transactionTime.compareTo(a.transactionTime));
    }
    return map;
  }

  static int sumRevenue(List<OrderModel> orders) =>
      orders.fold<int>(0, (s, o) => s + o.totalPrice);
}
```

═══════════════════════════════════════════════
STEP 3: HistoryPage
═══════════════════════════════════════════════
`StatefulWidget`. initState: `context.read<HistoryBloc>().add(const HistoryEvent.fetch())`.

Build:
- Scaffold(bg surface).
- appBar: AppAppBar(title: 'Riwayat').
- body: SafeArea(bottom:false) > Column:
  1. **Filter chips row** (padding 16, scroll horizontal):
     - For each HistoryDateRange (today, week, month, custom):
       - AppChip(label: range.label, active: state.range == range, onTap: emit filter).
       - Untuk 'custom' → tap → `showDateRangePicker` → emit dengan from/to.
  2. **Summary row** AppCard horizontal: Total transaksi | Total revenue.
  3. Expanded > RefreshIndicator (onRefresh: bloc.refresh) > BlocBuilder:
     - success(filtered):
       - Empty → AppEmptyState 'Tidak ada transaksi pada periode ini'.
       - Else: ListView with sticky day headers:
         - Group `HistoryBloc.groupByDay(filtered)`.
         - For each (day, orders) sorted desc:
           - SectionHeader: AppSectionLabel(day.toFormattedTime).
           - For each order: `HistoryTransactionCard(order, onTap: push TransactionDetailPage(order))`.

`HistoryTransactionCard`:
- AppCard onTap: Row: MethodBadge(method based on order.paymentMethod), SpaceWidth 12. Expanded Column: Text '#${order.id}' titleS, Text '${order.totalQuantity} item' bodyS onSurfaceVar. Column.end: Text order.totalPrice.currencyFormatRp priceM, AppStatusPill(label: order.isRefunded ? 'REFUND' : 'LUNAS', kind: order.isRefunded ? warning : success).

═══════════════════════════════════════════════
STEP 4: Wiring
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => HistoryBloc())`.
- DashboardPage Riwayat tab → HistoryPage (sudah).
````

---

## Verifikasi

1. Buat beberapa order (cash + qris).
2. Buka tab Riwayat → list orders today.
3. Tap "Minggu Ini" → list bertambah (kalau ada order minggu ini).
4. Tap "Custom" → pick range → filter applied.
5. Pull-to-refresh → fetch remote + merge.

## Talking points

1. **Merge remote + local pending**:
   Multi-device scenario: kasir lain bikin order via BE, ingin terlihat. Lokal pending (belum sync) juga terlihat. Sumber kebenaran: BE untuk synced, local untuk pending.

2. **Pure static helpers**:
   `applyFilter` & `groupByDay` static → testable tanpa Bloc instance. `applyFilter` terima `now` param untuk freezing time di unit test.

3. **`switch (range)` exhaustive Dart 3**:
   Compiler complain kalau enum value baru ga di-cover. Future-proof.

4. **`!ts.isBefore(end)`** vs `ts.isAfter(end)`:
   `ts < end` (exclusive). Hindari edge case ts == end terhitung 2x kalau jam tepat di boundary.

5. **`RefreshIndicator`** pull-to-refresh:
   Konvensi Android. Wrap `Expanded > RefreshIndicator > ListView`. `onRefresh` return Future.

6. **Refresh failure preserved data**:
   Kalau network drop saat refresh, jangan empty list. Keep prev success → "old data still better than no data".

## Commit suggestion

```bash
git add lib/data/datasources/order_remote_datasource.dart lib/presentation/history/bloc/ lib/presentation/history/pages/ lib/presentation/history/widgets/ lib/main.dart
git commit -m "Step 30: HistoryBloc + HistoryPage with range filter & day grouping"
```

---

➡️ Lanjut ke [Step 31 — TransactionDetailPage](./31-transaction-detail.md)
