import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_chip.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/app_money_text_field.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/order/order_bloc.dart';
import '../models/order_summary.dart';
import 'payment_success_sheet.dart';

/// Cash confirmation sheet — replaces the legacy [AlertDialog] flow.
/// Reads the current [OrderSummary] from [OrderBloc], lets the cashier
/// enter cash received, shows live change, then dispatches
/// [OrderEvent.persistLocal] to save the order.
///
/// Maps to `PaymentConfirmSheet` in `.claude/new-design/screens/payment-flow.jsx`.
Future<void> showPaymentConfirmSheet(
  BuildContext context, {
  required OrderSummary summary,
}) {
  return showAppBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    headerBuilder: (ctx) {
      final p = ctx.palette;
      return Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.primaryContainer,
              borderRadius: AppRadius.smAll,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.payments_outlined,
                color: p.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pembayaran Tunai',
                    style:
                        AppTypography.titleM.copyWith(color: p.onSurface)),
                Text('Hitung uang dari pelanggan',
                    style: AppTypography.bodyS
                        .copyWith(color: p.onSurfaceVar)),
              ],
            ),
          ),
        ],
      );
    },
    child: _PaymentConfirmBody(summary: summary),
  );
}

class _PaymentConfirmBody extends StatefulWidget {
  final OrderSummary summary;
  const _PaymentConfirmBody({required this.summary});

  @override
  State<_PaymentConfirmBody> createState() => _PaymentConfirmBodyState();
}

class _PaymentConfirmBodyState extends State<_PaymentConfirmBody> {
  late int _received;

  @override
  void initState() {
    super.initState();
    _received = widget.summary.totalPrice;
  }

  int get _change => _received - widget.summary.totalPrice;
  bool get _isUnderpaid => _received < widget.summary.totalPrice;

  void _addQuickAmount(int delta) {
    setState(() {
      _received = delta == -1
          ? widget.summary.totalPrice
          : _received + delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = widget.summary.totalPrice;

    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) async {
        state.maybeWhen(
          persisted: (id, summary) async {
            Navigator.of(context).pop(); // close confirm sheet
            await showPaymentSuccessSheet(context, summary: summary);
          },
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: p.error),
            );
          },
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.onSurface,
                borderRadius: AppRadius.mdAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL TAGIHAN',
                    style: AppTypography.labelM.copyWith(
                      color: p.surface.withValues(alpha: 0.66),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    total.currencyFormatRp.trim(),
                    style: AppTypography.displayM.copyWith(
                      color: p.surface,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text('Uang diterima',
                  style: AppTypography.titleS.copyWith(color: p.onSurface)),
            ),
            const SizedBox(height: 8),
            AppMoneyTextField(
              initialValue: _received,
              onChanged: (v) => setState(() => _received = v),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChip(
                  label: 'Pas',
                  variant: AppChipVariant.primary,
                  active: _received == total,
                  onTap: () => _addQuickAmount(-1),
                ),
                for (final delta in const [5000, 10000, 20000, 50000])
                  AppChip(
                    label: '+${(delta ~/ 1000)}rb',
                    variant: AppChipVariant.primary,
                    onTap: () => _addQuickAmount(delta),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppKeyValueRow(
                label: 'Kembalian',
                value: _change >= 0
                    ? _change.currencyFormatRp.trim()
                    : '−${_change.abs().currencyFormatRp.trim()}',
                variant: _isUnderpaid
                    ? AppKVVariant.muted
                    : AppKVVariant.accent,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Batal',
                    variant: AppButtonVariant.outline,
                    onPressed: loading
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'Konfirmasi Bayar',
                    loading: loading,
                    onPressed: (loading || _isUnderpaid)
                        ? null
                        : () {
                            // Set the received amount, then persist locally.
                            context
                                .read<OrderBloc>()
                                .add(OrderEvent.addNominalBayar(_received));
                            context
                                .read<OrderBloc>()
                                .add(const OrderEvent.persistLocal());
                          },
                  ),
                ),
              ],
            ),
            if (_isUnderpaid) ...[
              const SizedBox(height: 8),
              Text(
                'Uang diterima kurang dari total tagihan',
                style: AppTypography.bodyS
                    .copyWith(color: p.error, fontSize: 11),
              ),
            ],
          ],
        );
      },
    );
  }
}

