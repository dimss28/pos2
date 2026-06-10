# 22 — CheckoutBloc + CheckoutSummary

## Goal

`CheckoutBloc` (cart state) dengan operasi addCheckout/removeCheckout/removeProduct/saveDraftOrder/loadDraftOrder/started + `CheckoutSummary` (Freezed value object pengganti positional tuple).

## Prerequisite

- Step 21 selesai.
- `OrderItem` (step 12), `DraftOrderModel` (step 12), `ProductLocalDatasource.instance` ready.

## Konsep yang diajarkan

- **Freezed value object** sebagai pengganti positional tuple di state.
- **Cart math** via static helper (`CheckoutSummary.totalsOf`).
- **Mutability di OrderItem** (`int quantity;` mutable) — trade-off vs immutable list copy.
- **Stock guard** di Bloc layer — defensive.
- **`linkedDraftId` carry-through** — kalau cart di-load dari draft, save akan replace bukan duplicate.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada: `Product`, `OrderItem` (quantity mutable), `DraftOrderModel`, `DraftOrderItem`, `ProductLocalDatasource.instance`.

Generate 4 file.

═══════════════════════════════════════════════
FILE 1: lib/presentation/home/models/checkout_summary.dart
═══════════════════════════════════════════════
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item.dart';

part 'checkout_summary.freezed.dart';

@freezed
abstract class CheckoutSummary with _$CheckoutSummary {
  const CheckoutSummary._();

  const factory CheckoutSummary({
    @Default(<OrderItem>[]) List<OrderItem> products,
    @Default(0) int totalQuantity,
    @Default(0) int totalPrice,
    @Default('customer') String draftName,
    int? linkedDraftId,           // FK ke draft_orders.id kalau load-from-draft
    String? linkedTableLabel,
    String? linkedCustomerName,
  }) = _CheckoutSummary;

  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;

  /// Hitung totalQuantity & totalPrice dari list items.
  /// Pakai record syntax Dart 3.
  static (int qty, int price) totalsOf(Iterable<OrderItem> items) {
    var qty = 0;
    var price = 0;
    for (final item in items) {
      qty += item.quantity;
      price += item.quantity * item.product.price;
    }
    return (qty, price);
  }
}
```

═══════════════════════════════════════════════
FILE 2-4: lib/presentation/home/bloc/checkout/checkout_bloc.dart + event + state
═══════════════════════════════════════════════

**checkout_event.dart** (`part of`):
```dart
@freezed
sealed class CheckoutEvent with _$CheckoutEvent {
  const factory CheckoutEvent.started() = _Started;
  const factory CheckoutEvent.addCheckout(Product product) = _AddCheckout;
  const factory CheckoutEvent.removeCheckout(Product product) = _RemoveCheckout;
  const factory CheckoutEvent.removeProduct(Product product) = _RemoveProduct;
  const factory CheckoutEvent.saveDraftOrder({
    @Default('') String tableLabel,
    @Default('') String customerName,
    @Default(0) int tableNumber,
  }) = _SaveDraftOrder;
  const factory CheckoutEvent.loadDraftOrder(DraftOrderModel data) = _LoadDraftOrder;
}
```

**checkout_state.dart** (`part of`):
```dart
@freezed
sealed class CheckoutState with _$CheckoutState {
  const factory CheckoutState.initial() = _Initial;
  const factory CheckoutState.loading() = _Loading;
  const factory CheckoutState.success(CheckoutSummary summary) = _Success;
  const factory CheckoutState.error(String message) = _Error;
  const factory CheckoutState.savedDraftOrder() = _SavedDraftOrder;
}
```

**checkout_bloc.dart**:
```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:flutter_pos_app/presentation/home/models/checkout_summary.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';
import 'package:flutter_pos_app/presentation/order/models/draft_order_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../../../data/datasources/product_local_datasource.dart';
import '../../models/draft_order_item.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';
part 'checkout_bloc.freezed.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final ProductLocalDatasource _local;

  CheckoutBloc({ProductLocalDatasource? local})
      : _local = local ?? ProductLocalDatasource.instance,
        super(const CheckoutState.success(CheckoutSummary())) {
    on<_AddCheckout>(_onAdd);
    on<_RemoveCheckout>(_onDecrement);
    on<_RemoveProduct>(_onRemove);
    on<_Started>(_onStarted);
    on<_SaveDraftOrder>(_onSaveDraft);
    on<_LoadDraftOrder>(_onLoadDraft);
  }

  CheckoutSummary _summaryFrom(List<OrderItem> items) {
    final (qty, price) = CheckoutSummary.totalsOf(items);
    final cur = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    return cur.copyWith(products: items, totalQuantity: qty, totalPrice: price);
  }

  void _onAdd(_AddCheckout event, Emitter<CheckoutState> emit) {
    final current = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    final newItems = [...current.products];
    final idx = newItems.indexWhere((e) => e.product == event.product);
    final inCartQty = idx >= 0 ? newItems[idx].quantity : 0;

    // V1 stock guard.
    final stock = event.product.stock;
    if (stock > 0 && inCartQty >= stock) return;

    if (idx >= 0) {
      newItems[idx].quantity++;
    } else {
      newItems.add(OrderItem(product: event.product, quantity: 1));
    }
    emit(CheckoutState.success(_summaryFrom(newItems)));
  }

  void _onDecrement(_RemoveCheckout event, Emitter<CheckoutState> emit) {
    final current = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    final newItems = [...current.products];
    final idx = newItems.indexWhere((e) => e.product == event.product);
    if (idx >= 0) {
      if (newItems[idx].quantity > 1) {
        newItems[idx].quantity--;
      } else {
        newItems.removeAt(idx);
      }
    }
    emit(CheckoutState.success(_summaryFrom(newItems)));
  }

  void _onRemove(_RemoveProduct event, Emitter<CheckoutState> emit) {
    final current = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    final newItems = [...current.products]
      ..removeWhere((e) => e.product == event.product);
    emit(CheckoutState.success(_summaryFrom(newItems)));
  }

  void _onStarted(_Started event, Emitter<CheckoutState> emit) {
    emit(const CheckoutState.success(CheckoutSummary()));
  }

  Future<void> _onSaveDraft(
      _SaveDraftOrder event, Emitter<CheckoutState> emit) async {
    final current = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    // Replace flow: hapus draft lama supaya tidak duplicate.
    if (current.linkedDraftId != null) {
      await _local.removeDraftOrderById(current.linkedDraftId!);
    }
    final draft = DraftOrderModel(
      orders: current.products
          .map((e) => DraftOrderItem(product: e.product, quantity: e.quantity))
          .toList(),
      totalQuantity: current.totalQuantity,
      totalPrice: current.totalPrice,
      tableLabel: event.tableLabel,
      customerName: event.customerName,
      tableNumber: event.tableNumber,
      draftName: event.customerName,
      transactionTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );
    await _local.saveDraftOrder(draft);
    emit(const CheckoutState.savedDraftOrder());
  }

  void _onLoadDraft(_LoadDraftOrder event, Emitter<CheckoutState> emit) {
    final draft = event.data;
    final items = draft.orders
        .map((e) => OrderItem(product: e.product, quantity: e.quantity))
        .toList();
    final (qty, price) = CheckoutSummary.totalsOf(items);
    emit(CheckoutState.success(CheckoutSummary(
      products: items,
      totalQuantity: qty,
      totalPrice: price,
      draftName: draft.displayCustomerName,
      linkedDraftId: draft.id,
      linkedTableLabel: draft.displayTableLabel,
      linkedCustomerName: draft.displayCustomerName,
    )));
  }
}
```

═══════════════════════════════════════════════
STEP 5: Update main.dart + HomePage
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => CheckoutBloc())`.
- DashboardPage: ganti `cartCount: 0` jadi dari `BlocBuilder<CheckoutBloc, CheckoutState>`:
  ```dart
  bottomNavigationBar: BlocBuilder<CheckoutBloc, CheckoutState>(
    builder: (context, state) {
      final cartCount = state.maybeWhen(
        success: (s) => s.totalQuantity,
        orElse: () => 0,
      );
      return AppBottomNav.standard(activeIndex: _index, onTap: _switchTo, cartCount: cartCount);
    },
  ),
  ```
- HomePage: hapus placeholder dummy CheckoutSummary, import dari `lib/presentation/home/models/checkout_summary.dart`. Pastikan `_onAdd` & `_onDecrement` di product card call `CheckoutBloc.add(CheckoutEvent.addCheckout/removeCheckout(product))`.

═══════════════════════════════════════════════
STEP 6: build_runner
═══════════════════════════════════════════════
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
````

---

## Verifikasi

1. Run → login → dashboard → tap produk di grid.
2. Badge bottom nav "Order" naik (1, 2, 3, ...).
3. Tap stepper + / − di card → cart sync.
4. Reload app → cart kembali kosong (state in-memory, hilang saat process kill).

## Talking points

1. **`CheckoutSummary` Freezed daripada positional tuple**:
   Legacy bug: `_Success(products, qty, price, draftName)` — 4 positional args mudah ketuker. Sekarang `CheckoutSummary({...})` named + default. Tambah field (`linkedDraftId`, dst) gak break callsite.

2. **`(int qty, int price) totalsOf(...)`** record syntax:
   Dart 3 records — return 2 nilai tanpa class wrapper. Destructure di caller: `final (qty, price) = CheckoutSummary.totalsOf(items);`.

3. **`OrderItem.quantity` mutable** (`int quantity;` non-final):
   Trade-off pragmatik. Pure immutable: tiap update bikin OrderItem baru → copy list. Pilihan kita: mutable di item, immutable di summary (copy list shell). Cukup safe karena emit state baru tiap perubahan.

4. **Stock guard `if (stock > 0 && inCartQty >= stock) return`**:
   Defensive — UI sudah disable tombol add saat at-cap, tapi race condition mungkin terjadi. Bloc enforce sebagai final guard.

5. **`linkedDraftId`** carry-through:
   Kalau user load draft → modify → save lagi, kita hapus draft lama dulu lalu insert baru. Tanpa carry, akumulasi draft duplicate.

6. **`@Default(<OrderItem>[])` di Freezed**:
   Constant default list. Wajib karena `@freezed` immutable + butuh nilai default `const` untuk constructor `const`.

7. **State `savedDraftOrder()` terpisah dari `success`**:
   Setelah save draft, UI listener pop ke DraftOrderPage. Distinct state supaya BlocListener bisa match.

## Commit suggestion

```bash
git add lib/presentation/home/models/checkout_summary.dart lib/presentation/home/bloc/checkout/ lib/presentation/home/pages/home_page.dart lib/presentation/home/pages/dashboard_page.dart lib/main.dart
git commit -m "Step 22: CheckoutBloc with CheckoutSummary + cart badge wired"
```

---

➡️ Lanjut ke [Step 23 — OrderPage](./23-order-page.md)
