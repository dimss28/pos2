import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_icon_button.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/method_badge.dart';
import '../../../core/components/product_img.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/dataoutputs/cwb_print.dart';
import '../../../data/models/response/product_response_model.dart';
import '../../order/models/order_model.dart';
import '../../refund/widgets/refund_sheet.dart';

/// Permanent record view for a single completed transaction. Promoted from
/// the legacy inline `ExpansionTile` so the UX can host richer actions
/// (refund, share, reprint) without breaking the list layout.
///
/// Maps to `.claude/new-design/screens/transaction-detail.jsx`.
class TransactionDetailPage extends StatelessWidget {
  final OrderModel order;

  const TransactionDetailPage({super.key, required this.order});

  PaymentMethod _resolveMethod() {
    final m = order.paymentMethod.toLowerCase();
    if (m.contains('qris') || m.contains('qr')) return PaymentMethod.qris;
    if (m.contains('transfer')) return PaymentMethod.transfer;
    return PaymentMethod.cash;
  }

  String _trxNumber() {
    final id = order.id ?? 0;
    return '#TRX-${id.toString().padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final method = _resolveMethod();
    final dt = DateTime.tryParse(order.transactionTime);

    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Detail Transaksi',
        subtitle: _trxNumber(),
        trailing: [
          AppIconButton(
            icon: Icons.more_horiz,
            variant: AppIconButtonVariant.surfaceVariant,
            onPressed: () => _showOverflow(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _SuccessHero(order: order, dt: dt),
          const _SectionLabel('Info Order'),
          AppCard(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                const AppKeyValueRow(label: 'Meja', value: 'Walk-in'),
                const AppKeyValueRow(
                    label: 'Pelanggan', value: 'Walk-in'),
                AppKeyValueRow(
                    label: 'Kasir', value: order.namaKasir),
                _MethodRow(method: method, label: order.paymentMethod),
                AppKeyValueRow(
                  label: 'Status sync',
                  value: order.isSync ? 'Terkirim' : 'Pending',
                  variant: order.isSync
                      ? AppKVVariant.accent
                      : AppKVVariant.muted,
                ),
              ],
            ),
          ),
          _SectionLabel('Item (${order.totalQuantity})'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < order.orders.length; i++) ...[
                  _ItemRow(item: order.orders[i].product, qty: order.orders[i].quantity),
                  if (i < order.orders.length - 1)
                    Container(height: 1, color: p.outlineSoft),
                ],
              ],
            ),
          ),
          const _SectionLabel('Rincian'),
          AppCard(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                AppKeyValueRow(
                  label: 'Subtotal',
                  value: order.totalPrice.currencyFormatRp.trim(),
                ),
                AppKeyValueRow(
                  label: 'Total',
                  value: order.totalPrice.currencyFormatRp.trim(),
                  variant: AppKVVariant.big,
                ),
                if (method == PaymentMethod.cash) ...[
                  AppKeyValueRow(
                    label: 'Uang diterima',
                    value: order.nominalBayar.currencyFormatRp.trim(),
                    variant: AppKVVariant.highlight,
                  ),
                  AppKeyValueRow(
                    label: 'Kembalian',
                    value: (order.nominalBayar - order.totalPrice)
                        .currencyFormatRp
                        .trim(),
                    variant: AppKVVariant.accent,
                  ),
                ],
              ],
            ),
          ),
          if (order.isRefunded) ...[
            const _SectionLabel('Refund'),
            _RefundCard(order: order),
          ],
          const _SectionLabel('Aktivitas'),
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActivityLine(
                  text: 'Order dibuat oleh ${order.namaKasir}',
                  time: dt == null ? '-' : dt.toFormattedTime(),
                ),
                _ActivityLine(
                  text: 'Pembayaran ${order.paymentMethod} diterima',
                  time: dt == null ? '-' : dt.toFormattedTime(),
                ),
                if (order.isRefunded)
                  _ActivityLine(
                    text:
                        'Transaksi di-refund (${_reasonLabel(order.refundReason)})',
                    time: _formatRefundTime(order.refundedAt),
                    ok: false,
                  ),
                _ActivityLine(
                  text: order.isSync
                      ? 'Terkirim ke server'
                      : 'Menunggu sinkronisasi',
                  time: order.isSync ? '—' : 'pending',
                  ok: order.isSync,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppStickyFooter(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: AppButton(
                label: order.isRefunded ? 'Refunded' : 'Refund',
                variant: AppButtonVariant.danger,
                onPressed: order.isRefunded
                    ? null
                    : () => _openRefund(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 6,
              child: AppButton(
                label: 'Cetak ulang',
                leadingIcon: Icons.print_outlined,
                onPressed: () => _print(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _print(BuildContext context) async {
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
        order.orders,
        order.totalQuantity,
        order.totalPrice,
        order.paymentMethod,
        order.nominalBayar,
        order.namaKasir,
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

  Future<void> _openRefund(BuildContext context) async {
    final ok = await showRefundSheet(context, order: order);
    if (ok && context.mounted) {
      // Refund posted; close the detail page so the user lands back on the
      // (now refreshed) history list. The snackbar lives on the parent route.
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _showOverflow(BuildContext context) async {
    final action = await showAppActionSheet<String>(
      context: context,
      title: _trxNumber(),
      items: const [
        AppActionItem(
            value: 'export', label: 'Export PDF', icon: Icons.picture_as_pdf),
        AppActionItem(
            value: 'copy', label: 'Salin nomor transaksi', icon: Icons.copy),
      ],
    );
    if (!context.mounted || action == null) return;
    if (action == 'copy') {
      await Clipboard.setData(ClipboardData(text: _trxNumber()));
      if (context.mounted) {
        AppSnackbar.success(context, 'Nomor transaksi disalin');
      }
    } else {
      if (context.mounted) {
        AppSnackbar.info(context, 'Fitur Export PDF segera hadir');
      }
    }
  }
}

class _SuccessHero extends StatelessWidget {
  final OrderModel order;
  final DateTime? dt;
  const _SuccessHero({required this.order, required this.dt});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final refunded = order.isRefunded;
    final accent = refunded ? p.error : p.success;
    final accentBg = refunded ? p.errorContainer : p.successContainer;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(
              refunded ? Icons.undo_rounded : Icons.check_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  refunded ? 'Transaksi di-refund' : 'Pembayaran lunas',
                  style: AppTypography.titleS.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dt == null ? '-' : dt!.toFormattedTime(),
                  style: AppTypography.bodyS
                      .copyWith(color: p.onSurfaceVar, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TOTAL',
                style: AppTypography.labelM.copyWith(
                  color: p.onSurfaceVar,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.totalPrice.currencyFormatRp.trim(),
                style: AppTypography.priceL.copyWith(
                  color: refunded ? p.onSurfaceVar : p.onSurface,
                  fontSize: 18,
                  decoration: refunded
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _reasonLabel(String? key) {
  switch (key) {
    case 'salah_pesan':
      return 'Salah pesan';
    case 'pesanan_tidak_sesuai':
      return 'Pesanan tidak sesuai';
    case 'pelanggan_batal':
      return 'Pelanggan batal';
    case 'item_habis':
      return 'Item habis / tidak tersedia';
    case 'lainnya':
      return 'Lainnya';
    default:
      return key ?? '-';
  }
}

String _formatRefundTime(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final dt = DateTime.tryParse(iso);
  return dt == null ? iso : dt.toFormattedTime();
}

class _RefundCard extends StatelessWidget {
  final OrderModel order;
  const _RefundCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.undo_rounded, color: p.error, size: 18),
              const SizedBox(width: 8),
              Text(
                'Refund diproses',
                style: AppTypography.titleS.copyWith(
                  color: p.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppKeyValueRow(
            label: 'Alasan',
            value: _reasonLabel(order.refundReason),
          ),
          AppKeyValueRow(
            label: 'Waktu',
            value: _formatRefundTime(order.refundedAt),
          ),
          AppKeyValueRow(
            label: 'Jumlah dikembalikan',
            value: order.refundAmount.currencyFormatRp.trim(),
            variant: AppKVVariant.muted,
          ),
          if ((order.refundNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: p.surfaceVariant,
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                order.refundNote!,
                style: AppTypography.bodyS.copyWith(
                  color: p.onSurface,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final Product item;
  final int qty;
  const _ItemRow({required this.item, required this.qty});

  int _hueFor(Product p) => ((p.productId ?? p.id ?? 0) * 47) % 360;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ProductImg(name: item.name, hue: _hueFor(item), size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.name,
                    style: AppTypography.bodyM.copyWith(
                      color: p.onSurface,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(
                  '$qty × ${item.price.currencyFormatRp.trim()}',
                  style: AppTypography.bodyS
                      .copyWith(color: p.onSurfaceVar, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            (qty * item.price).currencyFormatRp.trim(),
            style: AppTypography.bodyM.copyWith(
              color: p.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final PaymentMethod method;
  final String label;
  const _MethodRow({required this.method, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = switch (method) {
      PaymentMethod.cash => AppStatusKind.success,
      PaymentMethod.qris => AppStatusKind.info,
      PaymentMethod.transfer => AppStatusKind.warning,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text('Metode',
                style: AppTypography.bodyM.copyWith(color: p.onSurfaceVar)),
          ),
          Text(
            label.isEmpty ? '-' : label,
            style: AppTypography.bodyM.copyWith(
              color: p.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          AppStatusPill(
            label: switch (method) {
              PaymentMethod.cash => 'CASH',
              PaymentMethod.qris => 'QRIS',
              PaymentMethod.transfer => 'TF',
            },
            kind: color,
          ),
        ],
      ),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  final String text;
  final String time;
  final bool ok;
  const _ActivityLine({
    required this.text,
    required this.time,
    this.ok = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: ok
                  ? p.successContainer
                  : p.warningContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              ok ? Icons.check_rounded : Icons.access_time,
              size: 11,
              color: ok ? p.success : const Color(0xFF7C4A0E),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTypography.bodyM
                    .copyWith(color: p.onSurface, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Text(time,
              style: AppTypography.bodyS
                  .copyWith(color: p.onSurfaceVar, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) =>
      AppSectionLabel(label, margin: const EdgeInsets.only(top: 18, bottom: 8));
}
