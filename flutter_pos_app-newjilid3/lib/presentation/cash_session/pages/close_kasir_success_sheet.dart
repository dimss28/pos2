import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/response/cash_session_model.dart';

/// Confirmation sheet shown after [CashSessionBloc.close] succeeds.
/// Renders the BE's authoritative variance + expected_cash so the cashier
/// has a clean handoff. Two outcomes:
///   - confirm logout → resolves [true]   → caller logs out + returns to login
///   - dismiss / "Tetap login" → [false]  → caller returns to Splash/Buka
class CloseKasirSuccessSheet {
  CloseKasirSuccessSheet._();

  static Future<bool?> show(
    BuildContext context, {
    required CashSessionModel closed,
    bool printSlip = false,
  }) {
    return showAppBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      headerBuilder: (ctx) => _Header(closed: closed),
      bottomActions: _Actions(closed: closed),
      child: _Body(closed: closed, printSlip: printSlip),
    );
  }
}

class _Header extends StatelessWidget {
  final CashSessionModel closed;
  const _Header({required this.closed});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final balanced = closed.isBalanced;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: balanced ? p.success : p.warning,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (balanced ? p.success : p.warning)
                    .withValues(alpha: 0.30),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            balanced ? Icons.check_rounded : Icons.warning_amber_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Shift ditutup',
                style: AppTypography.titleM.copyWith(color: p.onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                'Shift ${closed.shiftLabel}',
                style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
              ),
            ],
          ),
        ),
        AppStatusPill(
          label: balanced ? 'BALANCED' : 'SELISIH',
          kind: balanced ? AppStatusKind.success : AppStatusKind.warning,
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final CashSessionModel closed;
  final bool printSlip;

  const _Body({required this.closed, required this.printSlip});

  static final _dfFull = DateFormat('d MMM yyyy · HH:mm', 'id');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final variance = closed.variance ?? 0;
    final expected = closed.expectedCash ?? 0;
    final physical = closed.physicalCount ?? 0;
    final isShort = variance < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero variance card (mirrors the variance banner styling)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: variance == 0
                ? p.successContainer
                : p.warningContainer,
            borderRadius: AppRadius.mdAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                variance == 0
                    ? 'Tidak ada selisih'
                    : 'Selisih ${isShort ? "kurang" : "lebih"}',
                style: AppTypography.labelL.copyWith(
                  color: variance == 0 ? p.success : const Color(0xFF7C4A0E),
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                variance == 0
                    ? 'Rp 0'
                    : variance.abs().currencyFormatRp.trim(),
                style: AppTypography.displayM.copyWith(
                  color: variance == 0 ? p.success : const Color(0xFF7C4A0E),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              AppKeyValueRow(
                label: 'Kas fisik di laci',
                value: physical.currencyFormatRp.trim(),
              ),
              AppKeyValueRow(
                label: 'Estimasi kas akhir',
                value: expected.currencyFormatRp.trim(),
              ),
              AppKeyValueRow(
                label: 'Modal awal',
                value: closed.openingFloat.currencyFormatRp.trim(),
                variant: AppKVVariant.muted,
              ),
              AppKeyValueRow(
                label: 'Ditutup',
                value: closed.closedAt == null
                    ? '-'
                    : _dfFull.format(closed.closedAt!),
                variant: AppKVVariant.muted,
              ),
            ],
          ),
        ),
        if (printSlip) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.surfaceVariant,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Icon(Icons.print_outlined, color: p.onSurfaceVar, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cetak struk closing akan dijalankan setelah keluar (kalau printer terpasang).',
                    style: AppTypography.bodyS
                        .copyWith(color: p.onSurfaceVar, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final CashSessionModel closed;
  const _Actions({required this.closed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Tetap login',
            variant: AppButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: AppButton.primaryWithArrow(
            label: 'Logout & Selesai',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
      ],
    );
  }
}
