import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/app_button.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/method_badge.dart';
import '../../../core/components/product_img.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/dataoutputs/cwb_print.dart';
import '../../order/models/order_model.dart';
import '../pages/transaction_detail_page.dart';

/// Single transaction row in HistoryPage. Collapsed shows id+time+method
/// badge+total+chev; expanded reveals item list + 3-action row.
class HistoryTransactionCard extends StatelessWidget {
  final OrderModel data;
  final bool expanded;
  final VoidCallback onToggle;

  const HistoryTransactionCard({
    super.key,
    required this.data,
    required this.expanded,
    required this.onToggle,
  });

  PaymentMethod _method() {
    final m = data.paymentMethod.toLowerCase();
    if (m.contains('qris') || m.contains('qr')) return PaymentMethod.qris;
    if (m.contains('transfer')) return PaymentMethod.transfer;
    return PaymentMethod.cash;
  }

  String _shortId() => (data.id ?? 0).toString().padLeft(4, '0');

  String _timeOnly() {
    final dt = DateTime.tryParse(data.transactionTime);
    if (dt == null) return '-';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _reprint(BuildContext context) async {
    try {
      final connected = await PrinterService.instance.ensureConnected();
      if (!connected) {
        if (context.mounted) {
          AppSnackbar.error(context, 'Printer belum terhubung. Pair dulu di Pengaturan > Printer.');
        }
        return;
      }
      final paperSize = await PrinterService.instance.currentPaperSize();
      final branding = await PrinterService.instance.getBranding();
      final bytes = await CwbPrint.instance.printOrderV2(
        data.orders,
        data.totalQuantity,
        data.totalPrice,
        data.paymentMethod,
        data.nominalBayar,
        data.namaKasir,
        'Walk-in',
        paperSize: paperSize,
        branding: branding,
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

  int _hueFor(int? id) => ((id ?? 0) * 47) % 360;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: expanded ? p.primary.withValues(alpha: 0.55) : p.outlineSoft,
          width: expanded ? 1.5 : 1,
        ),
        boxShadow: expanded
            ? [
                BoxShadow(
                  color: p.primary.withValues(alpha: 0.20),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  MethodBadge(method: _method(), size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '#${_shortId()} · ${_timeOnly()}',
                                style: AppTypography.bodyL.copyWith(
                                  color: p.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (data.isRefunded) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.errorContainer,
                                  borderRadius:
                                      BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'REFUND',
                                  style: AppTypography.labelM.copyWith(
                                    color: p.error,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${data.totalQuantity} item · ${data.namaKasir}',
                          style: AppTypography.bodyS.copyWith(
                            color: p.onSurfaceVar,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.totalPrice.currencyFormatRp.trim(),
                    style: AppTypography.titleM.copyWith(
                      color: data.isRefunded ? p.onSurfaceVar : p.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: data.isRefunded
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more,
                        color: p.onSurfaceVar, size: 20),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Container(height: 1, color: p.outlineSoft),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in data.orders)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          ProductImg(
                            name: item.product.name,
                            hue: _hueFor(
                                item.product.productId ?? item.product.id),
                            size: 36,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.product.name,
                              style: AppTypography.bodyM.copyWith(
                                color: p.onSurface,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.quantity}×',
                            style: AppTypography.bodyS.copyWith(
                              color: p.onSurfaceVar,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (item.quantity * item.product.price)
                                .currencyFormatRp
                                .trim(),
                            style: AppTypography.bodyM.copyWith(
                              color: p.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Detail',
                          leadingIcon: Icons.visibility_outlined,
                          variant: AppButtonVariant.outline,
                          size: AppButtonSize.sm,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransactionDetailPage(order: data),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: 'Cetak ulang',
                          leadingIcon: Icons.print_outlined,
                          size: AppButtonSize.sm,
                          onPressed: () => _reprint(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
