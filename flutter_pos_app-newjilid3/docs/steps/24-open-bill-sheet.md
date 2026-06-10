# 24 — OpenBillSheet (Simpan Cart ke Draft)

## Goal

`OpenBillSheet` bottom sheet: user input nama customer + label meja, lalu trigger `CheckoutBloc.saveDraftOrder(...)`. Setelah save → snackbar + pop ke HomePage / DraftOrderPage.

## Prerequisite

- Step 23 selesai.

## Konsep yang diajarkan

- **Bottom sheet form** — `AppBottomSheet` shell + form widget.
- **Quick-pick chips** untuk shortcut meja (Meja 1-6, Takeaway).
- **State lokal di sheet** (`StatefulWidget`) — bukan global bloc.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `CheckoutBloc.saveDraftOrder(tableLabel, customerName, tableNumber)` ada.

Generate `lib/presentation/order/widgets/open_bill_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_button.dart';
import '../../../core/components/app_chip.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/spaces.dart';
import '../../home/bloc/checkout/checkout_bloc.dart';

class OpenBillSheet extends StatefulWidget {
  const OpenBillSheet({super.key});
  @override
  State<OpenBillSheet> createState() => _OpenBillSheetState();
}

class _OpenBillSheetState extends State<OpenBillSheet> {
  final _nameCtrl = TextEditingController();
  final _tableCtrl = TextEditingController();

  static const _quickTables = ['Meja 1', 'Meja 2', 'Meja 3', 'Meja 4',
                               'Meja 5', 'Meja 6', 'Takeaway', 'Bar'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tableCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final table = _tableCtrl.text.trim();
    if (name.isEmpty && table.isEmpty) {
      AppSnackbar.error(context, 'Isi nama customer atau meja');
      return;
    }
    context.read<CheckoutBloc>().add(CheckoutEvent.saveDraftOrder(
      tableLabel: table,
      customerName: name,
    ));
    // Pop sheet — OrderPage listener akan handle navigasi.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Nama customer',
          hint: 'Andi',
          controller: _nameCtrl,
          autofocus: true,
        ),
        const SpaceHeight(16),
        AppTextField(
          label: 'Meja / Lokasi',
          hint: 'Meja 4 atau Takeaway',
          controller: _tableCtrl,
        ),
        const SpaceHeight(12),
        const AppSectionLabel('Pilihan Cepat'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            for (final t in _quickTables)
              AppChip(
                label: t,
                active: _tableCtrl.text == t,
                onTap: () => setState(() => _tableCtrl.text = t),
              ),
          ],
        ),
        const SpaceHeight(20),
        AppButton.primary(label: 'Simpan ke Draft', onPressed: _save),
      ],
    );
  }
}
```

═══════════════════════════════════════════════
Update `order_page.dart` step 23
═══════════════════════════════════════════════
Ganti `showOpenBillSheet()`:
```dart
void _showOpenBillSheet() {
  showAppBottomSheet(
    context: context,
    title: 'Simpan ke Draft',
    subtitle: 'Catat customer & meja sebelum dilanjutkan',
    child: const OpenBillSheet(),
  );
}
```

Update listener `CheckoutBloc.savedDraftOrder` di OrderPage:
- Pop ke HomePage (`DashboardScope.switchTo(0); context.pop()`) atau push `DraftOrderPage` (step 29).
````

---

## Verifikasi

1. Order page dengan cart isi → tap "Simpan ke Draft" → sheet muncul.
2. Tap chip "Meja 4" → field meja terisi.
3. Input nama → tap "Simpan ke Draft" → sheet close → snackbar success → kembali ke Home.
4. Cek DB (atau step 29 DraftOrderPage): ada baris di `draft_orders`.

## Talking points

1. **Chip-driven form** vs free input:
   Mempercepat kasir — tap chip 1x lebih cepat daripada ngetik "Meja 4". Free input tetap ada untuk edge case.

2. **`autofocus: true`** di field nama:
   Sheet buka → keyboard langsung muncul → kasir tinggal ketik.

3. **Validation simple**: "name OR table required":
   Tidak terlalu strict. Kasir cenderung skip 1 field karena rusuh.

4. **State lokal vs Bloc**:
   Sheet hanya hidup beberapa detik. State lokal OK; bloc overkill. Pattern: bloc untuk state yang share antar page.

5. **`Wrap(spacing, runSpacing)`** untuk chip grid:
   Auto-wrap kalau gak muat. `Row(children: [...])` akan overflow.

## Commit suggestion

```bash
git add lib/presentation/order/widgets/open_bill_sheet.dart lib/presentation/order/pages/order_page.dart
git commit -m "Step 24: OpenBillSheet (save cart to draft)"
```

---

➡️ Lanjut ke [Step 25 — PaymentConfirmSheet (Cash)](./25-payment-confirm-cash.md)
