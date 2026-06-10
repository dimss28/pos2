import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/response/table_order_model.dart';

Future<void> showTableOrderDetailSheet(
  BuildContext context, {
  required TableOrderModel order,
  required VoidCallback onReject,
  required void Function(String status) onAdvance,
}) {
  return showAppBottomSheet<void>(
    context: context,
    title: order.tableLabel ?? 'Pesanan Meja',
    subtitle: order.orderNumber ?? 'Detail pesanan',
    maxHeightFactor: 0.94,
    bottomActions: _TableOrderActions(
      order: order,
      onReject: onReject,
      onAdvance: onAdvance,
    ),
    child: _TableOrderDetailBody(order: order),
  );
}

class _TableOrderDetailBody extends StatelessWidget {
  final TableOrderModel order;

  const _TableOrderDetailBody({required this.order});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppStatusPill(
              label: order.statusLabel ?? order.status,
              kind: AppStatusKind.info,
            ),
            const Spacer(),
            Text(
              order.paymentMethod.toUpperCase(),
              style: AppTypography.labelM.copyWith(color: p.onSurfaceVar),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Item pesanan', style: AppTypography.labelM.copyWith(color: p.onSurfaceVar)),
        const SizedBox(height: 8),
        if (order.items.isEmpty)
          Text(
            'Memuat item...',
            style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
          )
        else
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.productName,
                      style: AppTypography.bodyM.copyWith(color: p.onSurface),
                    ),
                  ),
                  Text(
                    '${item.quantity}x',
                    style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.totalPrice.currencyFormatRp.trim(),
                    style: AppTypography.bodyM.copyWith(
                      color: p.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const Divider(height: 24),
        Row(
          children: [
            Text('Total', style: AppTypography.titleM.copyWith(fontSize: 15)),
            const Spacer(),
            Text(
              order.totalPrice.currencyFormatRp.trim(),
              style: AppTypography.titleM.copyWith(
                fontSize: 16,
                color: p.primary,
              ),
            ),
          ],
        ),
        if (order.customerName != null && order.customerName!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoRow(label: 'Pelanggan', value: order.customerName!),
        ],
        if (order.customerWhatsapp != null &&
            order.customerWhatsapp!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _InfoRow(label: 'WhatsApp', value: order.customerWhatsapp!),
        ],
        if (order.notes != null && order.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _InfoRow(label: 'Catatan', value: order.notes!),
        ],
        if (order.hasPaymentProof) ...[
          const SizedBox(height: 20),
          Text(
            'Bukti transfer',
            style: AppTypography.labelM.copyWith(color: p.onSurfaceVar),
          ),
          const SizedBox(height: 8),
          _PaymentProofPreview(url: order.paymentProofUrl!),
        ] else if (order.paymentMethod == 'transfer') ...[
          const SizedBox(height: 16),
          Text(
            'Belum ada bukti transfer.',
            style: AppTypography.bodyS.copyWith(color: p.warning),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyM.copyWith(color: p.onSurface),
          ),
        ),
      ],
    );
  }
}

class _PaymentProofPreview extends StatelessWidget {
  final String url;

  const _PaymentProofPreview({required this.url});

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _PaymentProofFullscreen(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surfaceVariant,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openFullscreen(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, __) => Center(
                  child: CircularProgressIndicator(color: p.primary),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined, color: p.error),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat gambar',
                        style: AppTypography.bodyS.copyWith(color: p.error),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: p.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.zoom_in, size: 18, color: p.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    'Ketuk untuk perbesar',
                    style: AppTypography.labelM.copyWith(
                      color: p.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentProofFullscreen extends StatelessWidget {
  final String url;

  const _PaymentProofFullscreen({required this.url});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Bukti transfer'),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (_, __) =>
                CircularProgressIndicator(color: p.primary),
            errorWidget: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

class _TableOrderActions extends StatelessWidget {
  final TableOrderModel order;
  final VoidCallback onReject;
  final void Function(String status) onAdvance;

  const _TableOrderActions({
    required this.order,
    required this.onReject,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    if (order.status == 'awaiting_payment') {
      return Text(
        'Menunggu pelanggan bayar QRIS',
        textAlign: TextAlign.center,
        style: AppTypography.bodyS.copyWith(color: context.palette.onSurfaceVar),
      );
    }
    if (order.status == 'paid' || order.status == 'awaiting_confirmation') {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Diproses',
              onPressed: () {
                Navigator.of(context).pop();
                onAdvance('preparing');
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              label: 'Tolak',
              variant: AppButtonVariant.danger,
              onPressed: () {
                Navigator.of(context).pop();
                onReject();
              },
            ),
          ),
        ],
      );
    }
    if (order.status == 'preparing' || order.status == 'ready') {
      return AppButton(
        label: 'Selesai',
        onPressed: () {
          Navigator.of(context).pop();
          onAdvance('completed');
        },
      );
    }
    return const SizedBox.shrink();
  }
}
