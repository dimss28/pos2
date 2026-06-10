import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../cash_session/bloc/cash_session/cash_session_bloc.dart';
import '../../history/bloc/history/history_bloc.dart';
import '../../order/models/order_model.dart';
import '../bloc/refund/refund_bloc.dart';

/// Controlled vocab of refund reasons + display label.
const _reasons = <(String, String)>[
  ('salah_pesan', 'Salah pesan'),
  ('pesanan_tidak_sesuai', 'Pesanan tidak sesuai'),
  ('pelanggan_batal', 'Pelanggan batal'),
  ('item_habis', 'Item habis / tidak tersedia'),
  ('lainnya', 'Lainnya (jelaskan di catatan)'),
];

Future<bool> showRefundSheet(
  BuildContext context, {
  required OrderModel order,
}) async {
  // Reset bloc so a previously-fired success/error doesn't auto-trigger.
  context.read<RefundBloc>().add(const RefundEvent.reset());
  final ok = await showAppBottomSheet<bool>(
    context: context,
    title: 'Refund Transaksi',
    subtitle: 'Pengembalian penuh — tidak dapat dibatalkan',
    isDismissible: false,
    enableDrag: false,
    child: _RefundBody(order: order),
  );
  return ok == true;
}

class _RefundBody extends StatefulWidget {
  final OrderModel order;
  const _RefundBody({required this.order});

  @override
  State<_RefundBody> createState() => _RefundBodyState();
}

class _RefundBodyState extends State<_RefundBody> {
  String? _reasonKey;
  final _noteCtrl = TextEditingController();
  String? _reasonError;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _shiftMatchesOrder {
    final shiftState = context.read<CashSessionBloc>().state;
    final openId = shiftState.maybeWhen(
      open: (s) => s.id,
      orElse: () => null,
    );
    if (openId == null) return false;
    if (widget.order.cashSessionId == null) return false;
    return widget.order.cashSessionId == openId;
  }

  Future<void> _submit() async {
    if (_reasonKey == null) {
      setState(() => _reasonError = 'Pilih alasan refund');
      return;
    }
    FocusScope.of(context).unfocus();

    final reasonLabel =
        _reasons.firstWhere((r) => r.$1 == _reasonKey!).$2;
    final amountStr = widget.order.totalPrice.currencyFormatRp.trim();
    final ok = await AppConfirm.show(
      context,
      title: 'Konfirmasi Refund',
      body:
          'Refund akan memproses:\n\n• Pengembalian $amountStr ke pelanggan\n• Stock item dikembalikan ke katalog\n• Tercatat sebagai pengeluaran kas shift\n\nAlasan: $reasonLabel\n\nAksi ini tidak bisa dibatalkan. Lanjutkan?',
      confirmLabel: 'Ya, Refund',
      cancelLabel: 'Batal',
      destructive: true,
    );
    if (!ok || !mounted) return;

    context.read<RefundBloc>().add(
          RefundEvent.submit(
            localOrderId: widget.order.id ?? 0,
            serverOrderId: widget.order.id,
            reason: _reasonKey!,
            note: _noteCtrl.text.trim().isEmpty
                ? null
                : _noteCtrl.text.trim(),
            amount: widget.order.totalPrice,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final blockReason = _shiftMatchesOrder
        ? null
        : 'Refund hanya bisa dilakukan saat shift yang membuat transaksi ini masih buka.';

    return BlocConsumer<RefundBloc, RefundState>(
      listener: (context, state) {
        state.maybeWhen(
          success: () {
            context
                .read<HistoryBloc>()
                .add(const HistoryEvent.refresh());
            Navigator.of(context).pop(true);
            AppSnackbar.success(context, 'Refund berhasil diproses');
          },
          successWithRemoteWarning: (warning) {
            context
                .read<HistoryBloc>()
                .add(const HistoryEvent.refresh());
            Navigator.of(context).pop(true);
            AppSnackbar.info(
              context,
              'Refund tersimpan lokal. Server akan disinkronkan: $warning',
            );
          },
          error: (msg) =>
              AppSnackbar.error(context, 'Gagal refund: $msg'),
          orElse: () {},
        );
      },
      builder: (context, state) {
        final loading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (blockReason != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.warningContainer,
                  borderRadius: AppRadius.smAll,
                  border: Border.all(
                    color: p.warning.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline, color: p.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        blockReason,
                        style: AppTypography.bodyS.copyWith(
                          color: p.onSurface,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Recap
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSAKSI',
                    style: AppTypography.labelM.copyWith(
                      color: p.onSurfaceVar,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${widget.order.id ?? '-'}',
                    style: AppTypography.titleM.copyWith(
                      color: p.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total yang dikembalikan',
                        style: AppTypography.bodyS
                            .copyWith(color: p.onSurfaceVar),
                      ),
                      Text(
                        widget.order.totalPrice.currencyFormatRp.trim(),
                        style: AppTypography.priceM.copyWith(
                          color: p.error,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.order.totalQuantity} item · ${widget.order.paymentMethod} · ${widget.order.namaKasir}',
                    style: AppTypography.bodyS.copyWith(
                      color: p.onSurfaceVar,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Alasan refund',
              style: AppTypography.titleS.copyWith(color: p.onSurface),
            ),
            const SizedBox(height: 6),
            for (final r in _reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _ReasonTile(
                  label: r.$2,
                  selected: _reasonKey == r.$1,
                  onTap: blockReason != null
                      ? null
                      : () => setState(() {
                            _reasonKey = r.$1;
                            _reasonError = null;
                          }),
                ),
              ),
            if (_reasonError != null) ...[
              const SizedBox(height: 4),
              Text(
                _reasonError!,
                style: AppTypography.bodyS
                    .copyWith(color: p.error, fontSize: 11),
              ),
            ],

            const SizedBox(height: 14),
            AppTextField(
              label: 'Catatan tambahan (opsional)',
              hint: 'cth. minuman tumpah, salah racik',
              controller: _noteCtrl,
              maxLines: 3,
              minLines: 2,
            ),

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.errorContainer.withValues(alpha: 0.55),
                borderRadius: AppRadius.smAll,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: p.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Setelah refund: stock dikembalikan otomatis, dan total ini tercatat sebagai pengeluaran kas di shift saat ini.',
                      style: AppTypography.bodyS.copyWith(
                        color: p.onSurface,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Batal',
                    variant: AppButtonVariant.outline,
                    onPressed: loading
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label:
                        'Refund ${widget.order.totalPrice.currencyFormatRp.trim()}',
                    variant: AppButtonVariant.danger,
                    loading: loading,
                    onPressed: (blockReason != null || loading)
                        ? null
                        : _submit,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? p.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: AppRadius.smAll,
          border: Border.all(
            color: selected ? p.primary : p.outlineSoft,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? p.primary : p.outline,
                  width: 1.5,
                ),
                color: selected ? p.primary : Colors.transparent,
              ),
              child: selected
                  ? Icon(Icons.check, color: p.onPrimary, size: 12)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyM.copyWith(
                  color: disabled
                      ? p.onSurfaceVar
                      : (selected ? p.onSurface : p.onSurface),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
