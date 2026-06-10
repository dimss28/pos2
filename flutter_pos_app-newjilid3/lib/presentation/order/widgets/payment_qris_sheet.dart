import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/qr_view.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/order/order_bloc.dart';
import '../bloc/qris/qris_bloc.dart';
import '../models/order_summary.dart';
import 'payment_success_sheet.dart';

/// QRIS payment sheet. Generates a Midtrans QR, polls every 5s for
/// settlement, then triggers [OrderEvent.persistLocal] + opens the
/// [showPaymentSuccessSheet] handoff.
///
/// Reskins `payment_qris_dialog.dart` per
/// `.claude/new-design/screens/payment-qris.jsx`.
Future<void> showPaymentQrisSheet(
  BuildContext context, {
  required OrderSummary summary,
}) {
  final orderId = DateTime.now().millisecondsSinceEpoch.toString();
  context.read<QrisBloc>().add(
        QrisEvent.generateQRCode(orderId, summary.totalPrice),
      );
  return showAppBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    headerBuilder: (ctx) => const _Header(),
    child: _Body(summary: summary, orderId: orderId),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
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
          child: Icon(Icons.qr_code_2, color: p.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pembayaran QRIS',
                  style: AppTypography.titleM.copyWith(color: p.onSurface)),
              Text('Pelanggan scan dengan e-wallet apapun',
                  style: AppTypography.bodyS
                      .copyWith(color: p.onSurfaceVar)),
            ],
          ),
        ),
        const AppStatusPill(
          label: 'MENUNGGU',
          kind: AppStatusKind.warning,
          showDot: true,
          pulse: true,
        ),
      ],
    );
  }
}

class _Body extends StatefulWidget {
  final OrderSummary summary;
  final String orderId;
  const _Body({required this.summary, required this.orderId});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  Timer? _poll;
  Timer? _countdown;
  Duration _remaining = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 0) {
        _countdown?.cancel();
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      context
          .read<QrisBloc>()
          .add(QrisEvent.checkPaymentStatus(widget.orderId));
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  String _formatRemaining() {
    final m = _remaining.inMinutes;
    final s = _remaining.inSeconds - m * 60;
    return '$m menit ${s.toString().padLeft(2, '0')} detik';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return MultiBlocListener(
      listeners: [
        BlocListener<QrisBloc, QrisState>(
          listener: (context, state) {
            state.maybeWhen(
              qrisResponse: (_) => _startPolling(),
              success: (_) async {
                _poll?.cancel();
                _countdown?.cancel();
                context
                    .read<OrderBloc>()
                    .add(const OrderEvent.persistLocal());
              },
              error: (msg) => AppSnackbar.error(context, msg),
              orElse: () {},
            );
          },
        ),
        BlocListener<OrderBloc, OrderState>(
          listener: (context, state) async {
            state.maybeWhen(
              persisted: (id, summary) async {
                Navigator.of(context).pop(); // close qris sheet
                await showPaymentSuccessSheet(context, summary: summary);
              },
              error: (msg) => AppSnackbar.error(context, msg),
              orElse: () {},
            );
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QRIS',
                      style: AppTypography.titleM.copyWith(
                        color: const Color(0xFFC8102E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'NMID: ID${widget.orderId.substring(widget.orderId.length - 6)}',
                      style: AppTypography.labelM.copyWith(
                        color: p.onSurfaceVar,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<QrisBloc, QrisState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      qrisResponse: (data) {
                        final url = data.actions?.firstOrNull?.url ?? '';
                        if (url.isEmpty) {
                          return AppQrView(
                            data: widget.orderId,
                            size: 200,
                            brandLetter: 'K',
                          );
                        }
                        return SizedBox(
                          width: 220,
                          height: 220,
                          child: Image.network(
                            url,
                            errorBuilder: (_, __, ___) => AppQrView(
                              data: widget.orderId,
                              size: 200,
                              brandLetter: 'K',
                            ),
                          ),
                        );
                      },
                      error: (msg) => SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(
                          child: Text(
                            msg,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyS.copyWith(color: p.error),
                          ),
                        ),
                      ),
                      orElse: () => const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                AppKeyValueRow(
                  label: 'Total bayar',
                  value: widget.summary.totalPrice.currencyFormatRp.trim(),
                  variant: AppKVVariant.big,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: p.surfaceVariant,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: p.onSurfaceVar, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _remaining.inSeconds > 0
                        ? 'QR berlaku ${_formatRemaining()} lagi'
                        : 'QR sudah expired, batalkan dan ulangi',
                    style:
                        AppTypography.bodyS.copyWith(color: p.onSurface),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cek Status',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context
                      .read<QrisBloc>()
                      .add(QrisEvent.checkPaymentStatus(widget.orderId)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Batalkan',
                  variant: AppButtonVariant.danger,
                  onPressed: () {
                    _poll?.cancel();
                    _countdown?.cancel();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
