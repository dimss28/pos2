import 'package:flutter/material.dart';

import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Single row inside the "Pendapatan per Metode" card.
/// 2-letter method tile on primaryContainer + method name + transaction
/// count + total amount.
///
/// Maps to `PaymentRow` in `.claude/new-design/screens/close-kasir.jsx:208`.
class PaymentBreakdownRow extends StatelessWidget {
  final String method;
  final int count;
  final int amount;
  final bool last;

  const PaymentBreakdownRow({
    super.key,
    required this.method,
    required this.count,
    required this.amount,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initials = method.length >= 2
        ? method.substring(0, 2).toUpperCase()
        : method.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: p.outlineSoft)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.primaryContainer,
              borderRadius: AppRadius.smAll,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTypography.labelM.copyWith(
                color: p.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  method,
                  style: AppTypography.bodyL.copyWith(
                    color: p.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$count transaksi',
                  style: AppTypography.bodyS.copyWith(
                    color: p.onSurfaceVar,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount.currencyFormatRp.trim(),
            style: AppTypography.titleM.copyWith(
              color: p.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
