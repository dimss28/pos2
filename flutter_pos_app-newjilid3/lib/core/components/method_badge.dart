import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum PaymentMethod { cash, qris, transfer }

/// 40×40 color-coded square that identifies the payment method in
/// history list rows.
///
/// Cash = success / QRIS = primary / Transfer = warning.
/// Maps to: `MethodBadge` in `.claude/new-design/screens/history-loaded.jsx:243`.
class MethodBadge extends StatelessWidget {
  final PaymentMethod method;
  final double size;

  const MethodBadge({
    super.key,
    required this.method,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg, label, icon) = switch (method) {
      PaymentMethod.cash => (
        p.successContainer,
        p.success,
        'CASH',
        Icons.payments_outlined,
      ),
      PaymentMethod.qris => (
        p.primaryContainer,
        p.primary,
        'QRIS',
        Icons.qr_code_2,
      ),
      PaymentMethod.transfer => (
        p.warningContainer,
        const Color(0xFF7C4A0E),
        'TF',
        Icons.account_balance_outlined,
      ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.smAll),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size * 0.42, color: fg),
          Text(
            label,
            style: AppTypography.labelM.copyWith(
              color: fg,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
