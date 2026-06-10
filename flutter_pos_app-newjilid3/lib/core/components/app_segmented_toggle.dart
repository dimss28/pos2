import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class AppSegmentOption<T> {
  final T value;
  final String label;
  final String? subtitle;

  const AppSegmentOption({
    required this.value,
    required this.label,
    this.subtitle,
  });
}

/// Segmented toggle. Active segment uses white surface + soft shadow,
/// matching `EnvTab` in `.claude/new-design/screens/server-key.jsx` and
/// `TypeToggle` in `.claude/new-design/screens/promo.jsx`.
class AppSegmentedToggle<T> extends StatelessWidget {
  final List<AppSegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  const AppSegmentedToggle({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surfaceVariant,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        children: [
          for (final opt in options)
            Expanded(
              child: _Segment(
                option: opt,
                active: opt.value == value,
                onTap: () => onChanged(opt.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  final AppSegmentOption<T> option;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.option,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: p.onSurface.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: AppTypography.labelL.copyWith(
                color: active ? p.onSurface : p.onSurfaceVar,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            if (option.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                option.subtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
