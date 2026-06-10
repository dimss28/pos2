import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// 52px stepper tile used in forms (e.g. Stok field on Add Product).
/// Larger and more prominent than [AppStepper] — designed for one-handed
/// form input rather than rapid cart tweaking.
///
/// Maps to: `StepperField` in `.claude/new-design/screens/product.jsx`.
class AppStepperField extends StatelessWidget {
  final int value;
  final int min;
  final int? max;
  final ValueChanged<int> onChanged;

  const AppStepperField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final canDec = value > min;
    final canInc = max == null || value < max!;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: p.outline, width: 1.5),
      ),
      child: Row(
        children: [
          _SquareBtn(
            icon: Icons.remove,
            color: canDec ? p.onSurface : p.onSurfaceVar.withValues(alpha: 0.4),
            onTap: canDec ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: AppTypography.titleM.copyWith(color: p.onSurface),
              ),
            ),
          ),
          _SquareBtn(
            icon: Icons.add,
            color: canInc ? p.primary : p.primary.withValues(alpha: 0.4),
            onTap: canInc ? () => onChanged(value + 1) : null,
            highlighted: true,
            bg: canInc ? p.primaryContainer : p.surfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _SquareBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool highlighted;
  final Color? bg;

  const _SquareBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.highlighted = false,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg ?? Colors.transparent,
      borderRadius: const BorderRadius.horizontal(
        right: Radius.circular(12),
      ).copyWith(
        topLeft: highlighted ? Radius.zero : const Radius.circular(12),
        bottomLeft: highlighted ? Radius.zero : const Radius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}
