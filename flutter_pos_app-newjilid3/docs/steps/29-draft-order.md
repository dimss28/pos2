# 29 — DraftOrderBloc + DraftOrderPage

## Goal

`DraftOrderBloc` (load list + remove + optimistic update) + `DraftOrderPage` (list draft, expand details, action: Bayar / Cetak ulang / Hapus).

## Prerequisite

- Step 28 selesai. `DraftOrderModel`, `ProductLocalDatasource.getAllDraftOrder/removeDraftOrderById/saveDraftOrder`.

## Konsep yang diajarkan

- **Optimistic update** — UI hapus item dulu, kalau DB gagal refetch authoritative.
- **`ExpansionTile`** / custom expand untuk detail per card.
- **Load draft ke cart** — `CheckoutBloc.add(loadDraftOrder(draft))` → user kembali ke OrderPage.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `ProductLocalDatasource.getAllDraftOrder/removeDraftOrderById` siap. `CheckoutBloc.loadDraftOrder` siap.

Generate 4 file.

═══════════════════════════════════════════════
FILE 1: draft_order_bloc.dart
═══════════════════════════════════════════════
```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';

import '../../../order/models/draft_order_model.dart';

part 'draft_order_bloc.freezed.dart';
part 'draft_order_event.dart';
part 'draft_order_state.dart';

class DraftOrderBloc extends Bloc<DraftOrderEvent, DraftOrderState> {
  final ProductLocalDatasource _local;
  DraftOrderBloc(this._local) : super(const DraftOrderState.initial()) {
    on<_GetAllDraftOrder>((event, emit) async {
      emit(const DraftOrderState.loading());
      try {
        final list = await _local.getAllDraftOrder();
        emit(DraftOrderState.success(list));
      } catch (e) { emit(DraftOrderState.error(e.toString())); }
    });

    on<_RemoveDraft>((event, emit) async {
      final current = state.maybeWhen(
        success: (list) => list, orElse: () => <DraftOrderModel>[]);
      // Optimistic — remove from UI dulu.
      emit(DraftOrderState.success(
        current.where((d) => d.id != event.id).toList()));
      try {
        await _local.removeDraftOrderById(event.id);
      } catch (_) {
        add(const DraftOrderEvent.getAllDraftOrder()); // refetch authoritative
      }
    });
  }
}
```

**draft_order_event.dart**:
```dart
@freezed
class DraftOrderEvent with _$DraftOrderEvent {
  const factory DraftOrderEvent.started() = _Started;
  const factory DraftOrderEvent.getAllDraftOrder() = _GetAllDraftOrder;
  const factory DraftOrderEvent.removeDraft(int id) = _RemoveDraft;
}
```

**draft_order_state.dart**:
```dart
@freezed
sealed class DraftOrderState with _$DraftOrderState {
  const factory DraftOrderState.initial() = _Initial;
  const factory DraftOrderState.loading() = _Loading;
  const factory DraftOrderState.success(List<DraftOrderModel> draftOrders) = _Success;
  const factory DraftOrderState.error(String message) = _Error;
}
```

═══════════════════════════════════════════════
FILE 4: lib/presentation/draft_order/pages/draft_order_page.dart
═══════════════════════════════════════════════
`StatefulWidget`. State punya `int? _expandedId`.

initState: `context.read<DraftOrderBloc>().add(const DraftOrderEvent.getAllDraftOrder())`.

Build:
- Scaffold(bg surface) > AppAppBar(title: 'Draft Order').
- body: BlocBuilder<DraftOrderBloc>:
  - loading → CircularProgressIndicator.
  - error → AppEmptyState.error.
  - success(list):
    - Kalau empty → AppEmptyState(visual: receipts icon, title: 'Belum ada draft', body: 'Order yang belum dibayar akan muncul di sini.', primaryAction: AppButton('Kembali ke Order', onPressed: pop)).
    - Else: ListView.separated padding 16:
      - For each draft: `_DraftCard(draft, isExpanded: _expandedId == draft.id, onTap: () => setState(_expandedId = ...), onPay, onDelete, onReprint)`.

`_DraftCard`:
- AppCard(padding 0) > Column:
  - Header InkWell(onTap toggle expand) Padding(14):
    - Row: Container 40 bg primaryContainer Icon table_restaurant primary, SpaceWidth 12.
    - Expanded Column.start: Text 'Meja ${draft.displayTableLabel}' titleS, Text '${draft.totalQuantity} item · ${draft.transactionTime.toFormattedTime}' bodyS onSurfaceVar.
    - Text draft.totalPrice.currencyFormatRp priceM.
    - SpaceWidth 8.
    - Icon expand_more (rotate 180° if expanded).
  - AnimatedCrossFade firstChild SizedBox.shrink, secondChild Padding 14: Column:
    - Divider outlineSoft.
    - SpaceHeight 8.
    - For each item: Row: Expanded Text '${item.quantity}× ${item.product.name}' bodyM, Text (qty*price).currencyFormatRp bodyM.
    - SpaceHeight 12.
    - Row buttons:
      - Expanded AppButton.outline('Hapus', danger style? variant danger, onPressed: onDelete).
      - SpaceWidth 8.
      - Expanded AppButton.outline('Cetak Ulang', leadingIcon print_outlined, onPressed: onReprint).
      - SpaceWidth 8.
      - Expanded AppButton.primaryWithArrow('Bayar', onPressed: onPay).

`onPay`:
- `context.read<CheckoutBloc>().add(CheckoutEvent.loadDraftOrder(draft));`
- Push OrderPage atau `DashboardScope.switchTo(1)` + pop.

`onDelete`:
- AppConfirm → `DraftOrderBloc.add(removeDraft(draft.id!))`.

`onReprint`:
- Convert draft → OrderSummary placeholder → `CwbPrint.printReceipt(...)`.

═══════════════════════════════════════════════
STEP 5: Wiring + nav
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => DraftOrderBloc(ProductLocalDatasource.instance))`.
- OpenBillSheet (step 24) listener: setelah savedDraftOrder, push DraftOrderPage:
  ```dart
  // di OrderPage savedDraftOrder listener:
  context.push(const DraftOrderPage());
  ```
- HomePage: optional, tambah icon notes di app bar yang push DraftOrderPage.
````

---

## Verifikasi

1. Save cart → DraftOrderPage tampil.
2. Tap card → expand show items + action row.
3. Tap "Hapus" → konfirm → card hilang dari list (optimistic), DB juga terhapus.
4. Tap "Bayar" → cart re-loaded → masuk OrderPage.

## Talking points

1. **Optimistic update pattern**:
   UI responsif (langsung hilang) tapi safe (refetch on error). Standard untuk delete operation.

2. **Reprint dari draft**:
   Draft belum punya orderId DB. Convert ke OrderSummary placeholder dengan `localOrderId: 0` atau 'DRAFT' untuk header struk.

3. **`AnimatedCrossFade`** vs `if (expanded)`:
   Smoother transition. Alternatif: `ExpansionTile` (lebih default look, kurang custom).

4. **Single-expand pattern** (`_expandedId` int?):
   Hanya 1 card expanded tiap waktu. UX lebih clean — banyak expanded = visual ribet.

5. **Action button order**: Hapus | Cetak Ulang | Bayar (left-to-right severity):
   Destructive di kiri (jauh dari thumb dominan → mengurangi misklik), positive action di kanan.

## Commit suggestion

```bash
git add lib/presentation/draft_order/ lib/main.dart lib/presentation/order/pages/order_page.dart
git commit -m "Step 29: DraftOrderBloc + DraftOrderPage with optimistic delete"
```

---

➡️ Lanjut ke [Step 30 — HistoryPage](./30-history-page.md)
