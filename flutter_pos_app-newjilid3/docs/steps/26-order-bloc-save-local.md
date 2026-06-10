# 26 — OrderBloc + OrderSummary + Save Order Lokal

## Goal

`OrderBloc` (state: success/persisted/error) + `OrderSummary` (Freezed) untuk simpan order ke SQLite lokal dengan `is_sync = 0` + decrement stock + attach `cash_session_id`.

## Prerequisite

- Step 25 selesai.
- `OrderModel` (step 12) ready dengan `toMapForLocal()`.

## Konsep yang diajarkan

- **Pure-offline persist** — UI tidak nunggu BE; sukses langsung emit.
- **`OrderSummary` value object** menggantikan 8-arg positional tuple legacy.
- **State `persisted(int localOrderId, OrderSummary summary)`** carry id + payload untuk listener.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `OrderModel.saveOrder` di `ProductLocalDatasource` bungkus transaction (insert order + insert items + decrement stock).

Generate 4 file.

═══════════════════════════════════════════════
FILE 1: lib/presentation/order/models/order_summary.dart
═══════════════════════════════════════════════
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../home/models/order_item.dart';

part 'order_summary.freezed.dart';

@freezed
abstract class OrderSummary with _$OrderSummary {
  const OrderSummary._();

  const factory OrderSummary({
    @Default(<OrderItem>[]) List<OrderItem> products,
    @Default(0) int totalQuantity,
    @Default(0) int totalPrice,
    @Default('') String paymentMethod,
    @Default(0) int nominalBayar,
    @Default(0) int idKasir,
    @Default('') String namaKasir,
    @Default('') String customerName,
    int? cashSessionId,
    // appliedDiscount akan ditambah di step 42.
  }) = _OrderSummary;

  int get change => nominalBayar - totalPrice;
  int get subtotal => products.fold<int>(0, (s, i) => s + i.quantity * i.product.price);
  int get discountAmount => 0; // step 42 ganti dengan appliedDiscount?.amount
  int? get promoId => null;
}
```

═══════════════════════════════════════════════
FILE 2-4: order_bloc/event/state
═══════════════════════════════════════════════

**order_event.dart** (`part of`):
```dart
@freezed
sealed class OrderEvent with _$OrderEvent {
  const factory OrderEvent.started() = _Started;
  const factory OrderEvent.reset() = _Reset;
  const factory OrderEvent.addPaymentMethod({
    required String paymentMethod,
    required List<OrderItem> orders,
    required String customerName,
    required int? cashSessionId,
  }) = _AddPaymentMethod;
  const factory OrderEvent.addNominalBayar(int nominal) = _AddNominalBayar;
  const factory OrderEvent.persistLocal() = _PersistLocal;
}
```

**order_state.dart** (`part of`):
```dart
@freezed
sealed class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  const factory OrderState.loading() = _Loading;
  const factory OrderState.success(OrderSummary summary) = _Success;
  const factory OrderState.persisted(int localOrderId, OrderSummary summary) = _Persisted;
  const factory OrderState.error(String message) = _Error;
}
```

**order_bloc.dart**:
```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/product_local_datasource.dart';
import '../../../home/models/order_item.dart';
import '../../models/order_model.dart';
import '../../models/order_summary.dart';

part 'order_event.dart';
part 'order_state.dart';
part 'order_bloc.freezed.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final AuthLocalDatasource _auth;
  final ProductLocalDatasource _local;

  OrderBloc({AuthLocalDatasource? auth, ProductLocalDatasource? local})
      : _auth = auth ?? AuthLocalDatasource(),
        _local = local ?? ProductLocalDatasource.instance,
        super(const OrderState.success(OrderSummary())) {
    on<_Started>((e, emit) => emit(const OrderState.success(OrderSummary())));
    on<_Reset>((e, emit) => emit(const OrderState.success(OrderSummary())));
    on<_AddPaymentMethod>(_onAddPaymentMethod);
    on<_AddNominalBayar>(_onAddNominal);
    on<_PersistLocal>(_onPersistLocal);
  }

  OrderSummary _currentSummary() => switch (state) {
        _Success(:final summary) => summary,
        _Persisted(:final summary) => summary,
        _ => const OrderSummary(),
      };

  Future<void> _onAddPaymentMethod(
      _AddPaymentMethod event, Emitter<OrderState> emit) async {
    emit(const OrderState.loading());
    try {
      final auth = await _auth.getAuthData();
      var qty = 0;
      var subtotal = 0;
      for (final i in event.orders) {
        qty += i.quantity;
        subtotal += i.quantity * i.product.price;
      }
      emit(OrderState.success(OrderSummary(
        products: event.orders,
        totalQuantity: qty,
        totalPrice: subtotal,
        paymentMethod: event.paymentMethod,
        nominalBayar: 0,
        idKasir: auth.user.id,
        namaKasir: auth.user.name,
        customerName: event.customerName,
        cashSessionId: event.cashSessionId,
      )));
    } catch (e) {
      emit(OrderState.error(e.toString()));
    }
  }

  void _onAddNominal(_AddNominalBayar event, Emitter<OrderState> emit) {
    final cur = _currentSummary();
    emit(OrderState.success(cur.copyWith(nominalBayar: event.nominal)));
  }

  Future<void> _onPersistLocal(
      _PersistLocal event, Emitter<OrderState> emit) async {
    final s = _currentSummary();
    if (s.products.isEmpty) {
      emit(const OrderState.error('Tidak ada item di keranjang'));
      return;
    }
    emit(const OrderState.loading());
    try {
      final orderModel = OrderModel(
        paymentMethod: s.paymentMethod,
        nominalBayar: s.nominalBayar,
        orders: s.products,
        totalQuantity: s.totalQuantity,
        totalPrice: s.totalPrice,
        idKasir: s.idKasir,
        namaKasir: s.namaKasir,
        isSync: false,
        transactionTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        cashSessionId: s.cashSessionId,
        promoId: s.promoId,
        discountAmount: s.discountAmount,
      );
      final localId = await _local.saveOrder(orderModel);
      emit(OrderState.persisted(localId, s));
    } catch (e) {
      emit(OrderState.error(e.toString()));
    }
  }
}
```

═══════════════════════════════════════════════
STEP 5: Wiring
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => OrderBloc())`.
- `order_page.dart`: replace stub `onConfirm` di PaymentConfirmSheet:
  ```dart
  onConfirm: (nominal) {
    final orderBloc = context.read<OrderBloc>();
    orderBloc.add(OrderEvent.addPaymentMethod(
      paymentMethod: 'cash',
      orders: cart.products,
      customerName: cart.linkedCustomerName ?? '',
      cashSessionId: null, // step 33 isi dari CashSessionBloc
    ));
    orderBloc.add(OrderEvent.addNominalBayar(nominal));
    orderBloc.add(const OrderEvent.persistLocal());
  }
  ```
- Tambah `BlocListener<OrderBloc>` di OrderPage:
  ```dart
  BlocListener<OrderBloc, OrderState>(
    listener: (ctx, state) {
      state.maybeWhen(
        persisted: (id, summary) {
          // Clear cart, navigate ke PaymentSuccessSheet (step 27).
          context.read<CheckoutBloc>().add(const CheckoutEvent.started());
          // TODO step 27: showAppBottomSheet(PaymentSuccessSheet(summary))
          AppSnackbar.success(ctx, 'Order #$id tersimpan lokal');
          context.pop(); // ke Home / Dashboard
        },
        error: (msg) => AppSnackbar.error(ctx, msg),
        orElse: () {},
      );
    },
    child: ...,
  )
  ```

═══════════════════════════════════════════════
STEP 6: build_runner
═══════════════════════════════════════════════
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
````

---

## Verifikasi

1. Cart isi → Cash → Konfirmasi (Rp pas) → snackbar "Order #N tersimpan lokal".
2. Cek DB: 1 row di `orders` (is_sync = 0), N rows di `order_items`, stock products turun.
3. Reopen Home → product stock displayed updated.

## Talking points

1. **Mengapa save lokal dulu, bukan langsung POST BE?**
   Offline-first. Kalau BE down/network drop, transaksi tetap tercatat. SyncBloc (step 40) akan push pending orders saat ada koneksi.

2. **`_currentSummary()` pakai `switch` pattern**:
   Dart 3 pattern matching: destructure `_Success(:final summary)`. Cleaner dari `state.maybeWhen`.

3. **Stock decrement di SQLite transaction**:
   `ProductLocalDatasource.saveOrder` jalan dalam transaction. Insert order + insert items + UPDATE products SET stock atomik. Kalau salah satu gagal, rollback.

4. **`cashSessionId: null` sementara**:
   Step 33 nanti `CashSessionBloc.state` punya open session → ambil id-nya. Untuk sekarang null, BE akan terima sebagai legacy order.

5. **State `persisted(id, summary)`** carry `localOrderId`:
   Untuk receipt print (step 27) dan refund tracking (step 32) — butuh id local row.

## Commit suggestion

```bash
git add lib/presentation/order/models/order_summary.dart lib/presentation/order/bloc/order/ lib/presentation/order/pages/order_page.dart lib/main.dart
git commit -m "Step 26: OrderBloc + OrderSummary + save order to local SQLite"
```

---

➡️ Lanjut ke [Step 27 — PaymentSuccessSheet + Print Struk](./27-payment-success-receipt.md)
