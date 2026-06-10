import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppStepperSize { sm, md }

/// Quantity stepper used in cart rows.
///
/// Maps to: `.claude/new-design/screens/order-detail.jsx` line items,
/// `.claude/new-design/screens/home-loaded.jsx:285`.
class AppStepper extends StatelessWidget {
  final int qty;
  final int min;
  final int? max;
  final ValueChanged<int> onChanged;
  final AppStepperSize size;

  const AppStepper({
    super.key,
    required this.qty,
    required this.onChanged,
    this.min = 0,
    this.max,
    this.size = AppStepperSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final sm = size == AppStepperSize.sm;
    final h = sm ? 32.0 : 40.0;
    final btn = sm ? 28.0 : 36.0;
    final iconSize = sm ? 16.0 : 18.0;
    final canDec = qty > min;
    final canInc = max == null || qty < max!;

    return Container(
      height: h,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: p.primaryContainer,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            size: btn,
            iconSize: iconSize,
            icon: Icons.remove,
            color: canDec ? p.primary : p.primary.withValues(alpha: 0.35),
            onTap: canDec ? () => onChanged(qty - 1) : null,
          ),
          SizedBox(
            width: sm ? 22 : 28,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: AppTypography.labelL.copyWith(
                color: p.onPrimaryContainer,
                fontSize: sm ? 13 : 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _Btn(
            size: btn,
            iconSize: iconSize,
            icon: Icons.add,
            color: canInc ? p.primary : p.primary.withValues(alpha: 0.35),
            onTap: canInc ? () => onChanged(qty + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final double size;
  final double iconSize;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _Btn({
    required this.size,
    required this.iconSize,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: color),
        ),
      ),
    );
  }
}
