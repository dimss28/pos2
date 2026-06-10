# 25 — PaymentConfirmSheet (Cash)

## Goal

Bottom sheet konfirmasi pembayaran cash: tampilkan total, input uang diterima, quick chips (Pas/+5rb/+10rb/+20rb/+50rb), hitung kembalian live. Tombol "Konfirmasi" → trigger `OrderBloc.add(addPaymentMethod) + persistLocal`.

## Prerequisite

- Step 23 (OrderPage) selesai.
- `OrderBloc` & `OrderSummary` belum ada — kita buat di step 26. Sementara sheet trigger sheet success langsung sebagai stub.

## Konsep yang diajarkan

- **Live computation**: kembalian = uangDiterima − total.
- **Quick chip math**: tap "+10rb" → tambah 10000 ke amount.
- **State validation**: tombol disabled kalau uang < total.
- **`AppMoneyTextField` controller**: re-format saat chip ditap.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada `CheckoutSummary`, `AppMoneyTextField`, `AppKeyValueRow`, `AppButton.primaryWithArrow`, `AppChip`, `AppBottomSheet`. `OrderBloc` belum ada — di step 26.

Generate `lib/presentation/order/widgets/payment_confirm_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_button.dart';
import '../../../core/components/app_chip.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/app_money_text_field.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../home/bloc/checkout/checkout_bloc.dart';
import '../../home/models/checkout_summary.dart';

class PaymentConfirmSheet extends StatefulWidget {
  final CheckoutSummary cart;
  /// Triggered when user taps "Konfirmasi". Callback dari OrderPage: panggil
  /// OrderBloc.add(addPaymentMethod) + persistLocal di sana.
  final void Function(int nominalBayar) onConfirm;

  const PaymentConfirmSheet({
    super.key,
    required this.cart,
    required this.onConfirm,
  });

  @override
  State<PaymentConfirmSheet> createState() => _PaymentConfirmSheetState();
}

class _PaymentConfirmSheetState extends State<PaymentConfirmSheet> {
  late int _nominal = widget.cart.totalPrice;  // default = pas
  late int _initialValue = widget.cart.totalPrice;

  int get _change => _nominal - widget.cart.totalPrice;
  bool get _valid => _nominal >= widget.cart.totalPrice;

  void _addQuick(int amount) {
    setState(() {
      _nominal = (_nominal == widget.cart.totalPrice && _nominal == _initialValue)
          ? widget.cart.totalPrice + amount
          : _nominal + amount;
      _initialValue = _nominal; // trigger AppMoneyTextField didUpdateWidget
    });
  }

  void _setPas() {
    setState(() {
      _nominal = widget.cart.totalPrice;
      _initialValue = widget.cart.totalPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppKeyValueRow(
          label: 'Total Tagihan',
          value: widget.cart.totalPrice.currencyFormatRp,
          variant: AppKVVariant.big,
        ),
        const SpaceHeight(16),
        const AppSectionLabel('Uang Diterima', margin: EdgeInsets.only(bottom: 8)),
        AppMoneyTextField(
          initialValue: _initialValue,
          autofocus: true,
          onChanged: (v) => setState(() => _nominal = v),
        ),
        const SpaceHeight(10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            AppChip(label: 'Pas', variant: AppChipVariant.primary, active: _nominal == widget.cart.totalPrice, onTap: _setPas),
            AppChip(label: '+5rb', onTap: () => _addQuick(5000)),
            AppChip(label: '+10rb', onTap: () => _addQuick(10000)),
            AppChip(label: '+20rb', onTap: () => _addQuick(20000)),
            AppChip(label: '+50rb', onTap: () => _addQuick(50000)),
          ],
        ),
        const SpaceHeight(18),
        AppKeyValueRow(
          label: 'Kembalian',
          value: _change >= 0 ? _change.currencyFormatRp : '−${(-_change).currencyFormatRp}',
          variant: _change >= 0 ? AppKVVariant.accent : AppKVVariant.regular,
        ),
        if (!_valid) ...[
          const SpaceHeight(6),
          Text('Uang kurang dari total tagihan',
            style: AppTypography.bodyS.copyWith(color: p.error)),
        ],
        const SpaceHeight(20),
        AppButton.primaryWithArrow(
          label: 'Konfirmasi & Bayar',
          onPressed: _valid ? () {
            Navigator.of(context).pop();
            widget.onConfirm(_nominal);
          } : null,
        ),
      ],
    );
  }
}
```

═══════════════════════════════════════════════
Update `order_page.dart` step 23
═══════════════════════════════════════════════
Replace `_onPayTap()` kalau `_paymentMethod == 'cash'`:
```dart
void _onPayCashTap(CheckoutSummary cart) {
  showAppBottomSheet(
    context: context,
    title: 'Pembayaran Cash',
    subtitle: 'Catat uang yang diterima dari customer',
    child: PaymentConfirmSheet(
      cart: cart,
      onConfirm: (nominal) {
        // Step 26: OrderBloc.add(addPaymentMethod) + persistLocal.
        AppSnackbar.success(context, 'Bayar $nominal sukses (stub)');
      },
    ),
  );
}
```
Update sticky footer Bayar onPressed switch:
```dart
onPressed: () {
  if (_paymentMethod == 'cash') _onPayCashTap(cart);
  else if (_paymentMethod == 'qris') {} // step 28
  else {} // transfer
}
```
````

---

## Verifikasi

1. Cart isi (total Rp. 25.000) → tap Cash → tap "Bayar..." → sheet muncul.
2. Default field auto = "25.000" (pas). Kembalian "Rp. 0".
3. Tap "+10rb" → field jadi "35.000". Kembalian "Rp. 10.000".
4. Type manual "20000" → kembalian "−Rp. 5.000" (kurang) → tombol disabled.
5. Type "30000" → tombol enabled → tap → snackbar success.

## Talking points

1. **Default = pas**:
   Sebagian besar transaksi cash di POS UMKM = pas. Default ini kurangi friction.

2. **Quick chips additive**:
   Tap "+10rb" 3x → +30rb. Lebih cepat daripada ngetik di numpad.

3. **Kembalian negatif tampil "−Rp. X"**:
   Jangan hide. User perlu tahu kurang berapa.

4. **`AppMoneyTextField` re-init via `_initialValue`**:
   Karena AppMoneyTextField pakai `didUpdateWidget` cek perubahan `initialValue`. Setiap kita ganti nominal via chip, ganti `_initialValue` juga supaya TextField re-format.

5. **`Navigator.pop()` SEBELUM call onConfirm**:
   Supaya context sheet pop dulu, baru caller bisa show success sheet tanpa stack 2 modal.

## Commit suggestion

```bash
git add lib/presentation/order/widgets/payment_confirm_sheet.dart lib/presentation/order/pages/order_page.dart
git commit -m "Step 25: PaymentConfirmSheet (cash) with quick chips + change calc"
```

---

➡️ Lanjut ke [Step 26 — OrderBloc + Save Order Lokal](./26-order-bloc-save-local.md)
