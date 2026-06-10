# 31 — TransactionDetailPage

## Goal

Halaman full detail satu transaksi: hero status (LUNAS / REFUND), info kasir, list item, breakdown total, action row (Cetak Ulang, Share PDF, Refund).

## Prerequisite

- Step 30 selesai.
- `OrderModel.fromLocalMap` + items detail.

## Konsep yang diajarkan

- **Detail page promote dari ExpansionTile** — UX permanent record lebih bagus.
- **Action row priority** — destructive (Refund) eksplisit, primary (Cetak Ulang) prominent.
- **PDF share** via `pdf` package + `Share` plugin (optional fallback).

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `OrderModel` lengkap dengan refund fields. `ProductLocalDatasource.getOrderItemByOrderId(id)` ada.

Generate `lib/presentation/history/pages/transaction_detail_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/avatar.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/method_badge.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/product_local_datasource.dart';
import '../../../data/dataoutputs/cwb_print.dart';
import '../../../presentation/order/models/order_model.dart';
import '../../../presentation/order/models/order_summary.dart';
import '../../home/models/order_item.dart';
import '../../refund/widgets/refund_sheet.dart';   // step 32

class TransactionDetailPage extends StatefulWidget {
  final OrderModel order;
  const TransactionDetailPage({super.key, required this.order});
  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  List<OrderItem>? _items;
  bool _loading = true;

  PaymentMethod _resolveMethod(String pm) {
    switch (pm.toLowerCase()) {
      case 'qris': return PaymentMethod.qris;
      case 'transfer': return PaymentMethod.transfer;
      default: return PaymentMethod.cash;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.order.id;
    if (id == null) { setState(() => _loading = false); return; }
    final items = await ProductLocalDatasource.instance.getOrderItemByOrderId(id);
    if (!mounted) return;
    setState(() { _items = items; _loading = false; });
  }

  Future<void> _onReprint() async {
    if (_items == null) return;
    final summary = OrderSummary(
      products: _items!,
      totalQuantity: widget.order.totalQuantity,
      totalPrice: widget.order.totalPrice,
      paymentMethod: widget.order.paymentMethod,
      nominalBayar: widget.order.nominalBayar,
      idKasir: widget.order.idKasir,
      namaKasir: widget.order.namaKasir,
    );
    final ok = await CwbPrint.instance.printReceipt(
      summary: summary, localOrderId: widget.order.id ?? 0);
    if (!mounted) return;
    ok
      ? AppSnackbar.success(context, 'Struk dicetak ulang')
      : AppSnackbar.error(context, 'Printer tidak terhubung');
  }

  void _onRefund() {
    if (widget.order.isRefunded) return;
    showAppBottomSheet(
      context: context,
      title: 'Proses Refund',
      child: RefundSheet(
        localOrderId: widget.order.id!,
        serverOrderId: null,  // sync layer akan resolve nanti
        amount: widget.order.totalPrice,
      ),
    ).then((_) => Navigator.of(context).pop());  // setelah refund sukses, back ke list
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final o = widget.order;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Detail Transaksi',
        subtitle: '#${o.id} · ${o.transactionTime.toFormattedTime}',
      ),
      body: _loading
        ? Center(child: CircularProgressIndicator(color: p.primary))
        : SafeArea(bottom: false, child: ListView(padding: const EdgeInsets.all(16), children: [
            // Hero banner
            AppBanner(
              kind: o.isRefunded ? AppBannerKind.warning : AppBannerKind.success,
              leadingIcon: o.isRefunded ? Icons.undo_rounded : Icons.check_circle_outline,
              title: o.isRefunded ? 'Order Dibatalkan (Refund)' : 'Pembayaran Lunas',
              body: o.isRefunded
                ? 'Refunded: ${o.refundReason ?? "-"}'
                : 'Diproses pada ${o.transactionTime.toFormattedTime}',
            ),
            const SpaceHeight(16),

            // Info kasir + method
            AppCard(child: Row(children: [
              AppAvatar(name: o.namaKasir),
              const SpaceWidth(12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Kasir', style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar)),
                Text(o.namaKasir, style: AppTypography.bodyL.copyWith(color: p.onSurface, fontWeight: FontWeight.w600)),
              ])),
              MethodBadge(method: _resolveMethod(o.paymentMethod)),
            ])),
            const SpaceHeight(16),

            // Items
            const AppSectionLabel('Item Pesanan'),
            AppCard(padding: EdgeInsets.zero, child: Column(children: [
              for (final item in _items ?? []) Padding(padding: const EdgeInsets.all(14), child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(item.product.name, style: AppTypography.bodyM.copyWith(color: p.onSurface, fontWeight: FontWeight.w600)),
                  Text('${item.quantity}× ${item.product.price.currencyFormatRp}', style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar)),
                ])),
                Text((item.quantity * item.product.price).currencyFormatRp, style: AppTypography.priceM.copyWith(color: p.onSurface)),
              ])),
            ])),
            const SpaceHeight(16),

            // Total breakdown
            const AppSectionLabel('Ringkasan'),
            AppCard(child: Column(children: [
              AppKeyValueRow(label: 'Subtotal', value: (o.totalPrice + o.discountAmount).currencyFormatRp),
              if (o.discountAmount > 0)
                AppKeyValueRow(label: 'Diskon', value: '-${o.discountAmount.currencyFormatRp}', variant: AppKVVariant.muted),
              AppKeyValueRow(label: 'Total', value: o.totalPrice.currencyFormatRp, variant: AppKVVariant.big),
              if (o.paymentMethod == 'cash') ...[
                AppKeyValueRow(label: 'Diterima', value: o.nominalBayar.currencyFormatRp),
                AppKeyValueRow(label: 'Kembalian', value: (o.nominalBayar - o.totalPrice).currencyFormatRp, variant: AppKVVariant.accent),
              ],
            ])),
            const SpaceHeight(80),  // ruang untuk sticky footer
          ])),
      bottomNavigationBar: AppStickyFooter(
        child: Row(children: [
          Expanded(child: AppButton.outline(
            label: 'Cetak Ulang', leadingIcon: Icons.print_outlined,
            onPressed: _onReprint,
          )),
          const SpaceWidth(12),
          if (!o.isRefunded)
            Expanded(child: AppButton.danger(
              label: 'Refund', leadingIcon: Icons.undo,
              onPressed: _onRefund,
            )),
        ]),
      ),
    );
  }
}
```

═══════════════════════════════════════════════
Update HistoryPage card tap:
═══════════════════════════════════════════════
```dart
onTap: () => context.push(TransactionDetailPage(order: order)),
```
````

---

## Verifikasi

1. Tab Riwayat → tap card → masuk detail page.
2. Hero banner sesuai status (LUNAS hijau / REFUND warning).
3. Item list correct.
4. Tap Cetak Ulang → struk keluar lagi.
5. Tap Refund → RefundSheet (step 32) muncul.

## Talking points

1. **Detail page vs inline expand**:
   Riwayat page list = ringkas. Detail = scrollable, action sticky. Lebih ergonomis di HP kecil daripada expansion.

2. **`_resolveMethod(String)` helper**:
   String → enum mapping. Hati-hati case: 'cash' / 'Cash' / 'CASH'.

3. **`OrderSummary` placeholder untuk reprint**:
   Tidak perlu carry `cashSessionId`/`appliedDiscount` di reprint — struk historical context cukup.

4. **`OrderSummary` vs `OrderModel`**:
   OrderModel = persisted DB shape. OrderSummary = working state UI. Convert keduanya saat reprint.

5. **Refund button hidden kalau sudah refunded**:
   Avoid double refund. Plus visual cue: order ini final.

6. **Sticky footer di `bottomNavigationBar`**:
   Karena tidak ada `bottomNavigationBar` lain di page ini, slot bisa dipakai untuk sticky action.

## Commit suggestion

```bash
git add lib/presentation/history/pages/transaction_detail_page.dart lib/presentation/history/widgets/history_transaction_card.dart
git commit -m "Step 31: TransactionDetailPage with hero, items, action footer"
```

---

➡️ Lanjut ke [Step 32 — Refund Flow](./32-refund-flow.md)
