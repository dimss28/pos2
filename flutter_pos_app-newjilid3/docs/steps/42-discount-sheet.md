# 42 — DiscountSheet (Apply Promo / Voucher / Manual Discount di Order)

## Goal

Bottom sheet di OrderPage untuk apply diskon: tab voucher (input code) / auto-promo (otomatis match) / manual (kasir input nominal). Update `OrderBloc.applyDiscount(AppliedDiscount)`.

## Prerequisite

- Step 41 selesai.
- `OrderBloc.applyDiscount/clearDiscount` ada (step 26, akan ditambah event).

## Konsep yang diajarkan

- **3-tab voucher/auto/manual** UX pattern.
- **Voucher validation client-side preview**, BE final source.
- **`AppliedDiscount`** sebagai value object.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `PromoModel.computeDiscount(subtotal)` & `isLive()` ada. `AppliedDiscount` ada.

═══════════════════════════════════════════════
STEP 1: Update OrderBloc event/state (step 26)
═══════════════════════════════════════════════
Tambah event:
```dart
const factory OrderEvent.applyDiscount(AppliedDiscount discount) = _ApplyDiscount;
const factory OrderEvent.clearDiscount() = _ClearDiscount;
```

Tambah handler:
```dart
void _onApplyDiscount(_ApplyDiscount event, Emitter<OrderState> emit) {
  final cur = _currentSummary();
  emit(OrderState.success(cur.copyWith(
    appliedDiscount: event.discount,
    totalPrice: (cur.subtotal - event.discount.amount).clamp(0, 1 << 31),
  )));
}

void _onClearDiscount(_ClearDiscount event, Emitter<OrderState> emit) {
  final cur = _currentSummary();
  emit(OrderState.success(cur.copyWith(
    appliedDiscount: null,
    totalPrice: cur.subtotal,
  )));
}
```

Update `_AddPaymentMethod` untuk preserve appliedDiscount + recompute total.

Update `OrderSummary`:
```dart
@Default(null) AppliedDiscount? appliedDiscount,
int get discountAmount => appliedDiscount?.amount ?? 0;
int? get promoId => appliedDiscount?.promo?.id;
```

═══════════════════════════════════════════════
FILE: lib/presentation/promo/widgets/discount_sheet.dart
═══════════════════════════════════════════════
StatefulWidget. Field: `int subtotal, AppliedDiscount? current, ValueChanged<AppliedDiscount?> onApply`.

State: `_tab: int = 0` (0=voucher, 1=auto, 2=manual), `_voucherCtrl`, `_voucherError`, `_manualCtrl`, `_manualNote`.

Build:
- Column:
  1. AppSegmentedToggle<int>(options: [SegmentOption(0,'Voucher'), (1,'Auto'), (2,'Manual')], value: _tab, onChanged).
  2. SpaceHeight 16.
  3. Switch tab content:
     - **Voucher tab**:
       - AppTextField 'Kode voucher' uppercase, hint 'MEMBER10', controller, errorText: _voucherError.
       - SpaceHeight 12.
       - AppButton.primary('Terapkan', onPressed: _applyVoucher).
     - **Auto tab**:
       - BlocBuilder<PromoBloc>: extract list, filter `p.code == null && p.isLive() && p.computeDiscount(subtotal) > 0`.
       - Empty → Text 'Tidak ada promo otomatis yang berlaku saat ini.'
       - List → AppCard per promo: name + 'Hemat ${computeDiscount.currencyFormatRp}' + tap → apply.
     - **Manual tab**:
       - AppMoneyTextField 'Nominal diskon', onChanged → _manual.
       - AppTextField 'Catatan (opsional)', controller _manualNote.
       - AppButton.primary('Terapkan').
  4. SpaceHeight 16.
  5. Kalau ada `current`: AppButton.outline('Hapus Diskon', onPressed: () { widget.onApply(null); Navigator.pop(context); }).

`_applyVoucher()`:
- code = _voucherCtrl.text.trim().toUpperCase().
- promos = context.read<PromoBloc>().state.maybeWhen(success: (list) => list, orElse: () => []).
- match = promos.firstWhereOrNull((p) => p.code?.toUpperCase() == code && p.isLive());
- Kalau null: setState `_voucherError = 'Kode tidak valid atau kedaluwarsa'`.
- Else: amount = match.computeDiscount(subtotal). Kalau 0 → error 'Tidak memenuhi syarat'.
- Else: widget.onApply(AppliedDiscount(amount, promo: match, source: voucher)); pop.

`_applyManual()`:
- amount = ... (from _manualCtrl).
- Kalau > subtotal → error 'Diskon melebihi subtotal'.
- widget.onApply(AppliedDiscount(amount, source: manual, note: _manualNote.text.trim())). pop.

═══════════════════════════════════════════════
Update OrderPage step 23
═══════════════════════════════════════════════
- Tambah tile 'Diskon' di Ringkasan section: tap → showAppBottomSheet(DiscountSheet(...)).
- Setelah apply, OrderPage rebuild dari BlocBuilder<OrderBloc> — atau caller-side `OrderBloc.add(applyDiscount(...))`.
- Wait — current OrderBloc state tidak punya products yet sebelum addPaymentMethod. Solusi: apply discount via OrderBloc tapi pakai subtotal dari CheckoutBloc.

Cleanest pattern:
```dart
// di OrderPage:
ListTile(title: Text('Diskon'), trailing: cart.discountText, onTap: () {
  showAppBottomSheet(context: context,
    title: 'Pilih Diskon',
    child: DiscountSheet(
      subtotal: cart.totalPrice,
      current: context.read<OrderBloc>().state.maybeWhen(
        success: (s) => s.appliedDiscount, orElse: () => null),
      onApply: (discount) {
        if (discount == null) {
          context.read<OrderBloc>().add(const OrderEvent.clearDiscount());
        } else {
          context.read<OrderBloc>().add(OrderEvent.applyDiscount(discount));
        }
      },
    ),
  );
}),
```

Update summary section:
- Tampilkan AppKeyValueRow 'Subtotal' subtotal, kalau discount → AppKeyValueRow appliedDiscount.displayLabel(), value '-${amount.currencyFormatRp}' muted.
- 'Total' = subtotal - discount, big.
````

---

## Verifikasi

1. Order page → tile 'Diskon' → sheet.
2. Tab Voucher → 'MEMBER10' (asumsikan promo aktif) → Terapkan → summary tampil "Diskon · MEMBER10 -Rp X".
3. Tab Auto → tampil list promo no-code yang live + match subtotal.
4. Tab Manual → input 5000 → tampil.
5. Hapus Diskon → discount reset.

## Talking points

1. **3-tab UX**:
   Real-world: voucher (customer punya code), auto (promo HPP), manual (manager override). Tiap source punya use case beda.

2. **Voucher validation client-side**:
   Cek code match + isLive + minSubtotal. Kalau gagal, error inline. BE recompute saat order persist (anti-tamper).

3. **`AppliedDiscount` carry to persistLocal**:
   OrderModel punya `promoId` + `discountAmount`. Disimpan ke local + push ke BE.

4. **`firstWhereOrNull`** dari `package:collection`:
   Atau pakai try-catch StateError pada `firstWhere`. `firstWhereOrNull` lebih clean.

5. **Manual discount note**:
   Audit-friendly. "Diskon manual" tanpa note bisa dipakai abuse — tambah catatan supaya manager bisa cek.

## Commit suggestion

```bash
git add lib/presentation/promo/widgets/discount_sheet.dart lib/presentation/order/bloc/order/ lib/presentation/order/models/order_summary.dart lib/presentation/order/pages/order_page.dart
git commit -m "Step 42: DiscountSheet (voucher/auto/manual) + OrderBloc applyDiscount"
```

---

➡️ Lanjut ke [Step 43 — Report Page](./43-report-page.md)
