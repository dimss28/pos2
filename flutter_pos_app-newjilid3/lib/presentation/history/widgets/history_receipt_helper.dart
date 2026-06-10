import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/feedback.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/dataoutputs/cwb_print.dart';
import '../../order/models/order_model.dart';
import 'receipt_preview_sheet.dart';

Future<void> showHistoryStrukMenu(BuildContext context, OrderModel order) async {
  final action = await showAppActionSheet<String>(
    context: context,
    title: 'Struk',
    items: const [
      AppActionItem(
        value: 'view',
        label: 'Lihat struk',
        icon: Icons.visibility_outlined,
      ),
      AppActionItem(
        value: 'print',
        label: 'Cetak struk',
        icon: Icons.print_outlined,
      ),
    ],
  );
  if (!context.mounted || action == null) return;
  if (action == 'view') {
    await showReceiptPreviewSheet(context, order: order);
  } else {
    await printHistoryReceipt(context, order);
  }
}

Future<void> printHistoryReceipt(BuildContext context, OrderModel order) async {
  try {
    final connected = await PrinterService.instance.ensureConnected();
    if (!connected) {
      if (context.mounted) {
        AppSnackbar.error(
          context,
          'Printer belum terhubung. Pair dulu di Pengaturan > Printer.',
        );
      }
      return;
    }
    final paperSize = await PrinterService.instance.currentPaperSize();
    final branding = await PrinterService.instance.getBranding();
    final bytes = await CwbPrint.instance.printOrderV2(
      order.orders,
      order.totalQuantity,
      order.totalPrice,
      order.paymentMethod,
      order.nominalBayar,
      order.namaKasir,
      'Walk-in',
      paperSize: paperSize,
      branding: branding,
      discountAmount: order.discountAmount,
    );
    await PrintBluetoothThermal.writeBytes(bytes);
    if (context.mounted) {
      AppSnackbar.success(context, 'Struk dikirim ke printer');
    }
  } catch (e) {
    if (context.mounted) {
      AppSnackbar.error(context, 'Gagal cetak: $e');
    }
  }
}

Future<void> showReceiptPreviewSheet(
  BuildContext context, {
  required OrderModel order,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ReceiptPreviewSheet(order: order),
  );
}

/// Monospace receipt preview used by history "Lihat struk".
class ReceiptPreviewBody extends StatelessWidget {
  final OrderModel order;

  const ReceiptPreviewBody({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FutureBuilder(
      future: PrinterService.instance.getBranding(),
      builder: (context, snap) {
        final branding = snap.data;
        final dt = DateTime.tryParse(order.transactionTime);
        final timeText = dt == null
            ? '-'
            : DateFormat('dd MMM yyyy · HH:mm', 'id').format(dt);
        final nota = order.id != null
            ? '#${order.id.toString().padLeft(6, '0')}'
            : '-';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: p.outlineSoft),
          ),
          child: DefaultTextStyle(
            style: AppTypography.bodyS.copyWith(
              color: p.onSurface,
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.45,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (branding != null && branding.storeName.isNotEmpty)
                  _center(branding.storeName, bold: true, size: 14),
                if (branding != null && branding.addressLine1.isNotEmpty)
                  _center(branding.addressLine1),
                if (branding != null && branding.addressLine2.isNotEmpty)
                  _center(branding.addressLine2),
                if (branding != null && branding.phone.isNotEmpty)
                  _center(branding.phone),
                const SizedBox(height: 8),
                _divider(),
                _row('No Nota', nota),
                _row('Waktu', timeText),
                _row('Kasir', order.namaKasir),
                _row('Pelanggan', 'Walk-in'),
                _row('Metode', order.paymentMethod),
                _divider(),
                for (final item in order.orders) ...[
                  Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                  _row(
                    '${item.quantity} x ${item.product.price.currencyFormatRp.trim()}',
                    (item.quantity * item.product.price).currencyFormatRp.trim(),
                  ),
                  const SizedBox(height: 4),
                ],
                _divider(),
                _row('Subtotal', order.totalPrice.currencyFormatRp.trim()),
                if (order.discountAmount > 0)
                  _row('Diskon', '-${order.discountAmount.currencyFormatRp.trim()}'),
                _row('Total', order.totalPrice.currencyFormatRp.trim(), bold: true),
                if (order.paymentMethod.toLowerCase().contains('cash') ||
                    order.paymentMethod.toLowerCase().contains('tunai')) ...[
                  _row('Bayar', order.nominalBayar.currencyFormatRp.trim()),
                  _row(
                    'Kembali',
                    (order.nominalBayar - order.totalPrice).currencyFormatRp.trim(),
                  ),
                ],
                _divider(),
                if (branding != null && branding.footerLine1.isNotEmpty)
                  _center(branding.footerLine1),
                if (branding != null && branding.footerLine2.isNotEmpty)
                  _center(branding.footerLine2),
                if (branding == null ||
                    (branding.footerLine1.isEmpty && branding.footerLine2.isEmpty))
                  _center('Terima kasih'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _center(String text, {bool bold = false, double size = 12}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        fontSize: size,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text('--------------------------------'),
    );
  }

  Widget _row(String left, String right, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(left, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null))),
          const SizedBox(width: 8),
          Text(right, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null)),
        ],
      ),
    );
  }
}
