import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppChipVariant {
  /// Default active = `onSurface` inverse (filter chips).
  filter,

  /// Active = `primaryContainer` (money quick-amount).
  primary,

  /// Outlined idle, transparent.
  outline,
}

/// Pill-shaped chip used for filters, categories, quick-amount selectors.
///
/// Maps to: filter chips in `.claude/new-design/screens/history-empty.jsx`,
/// quick-amount chips in `.claude/new-design/screens/order-detail.jsx`.
class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final IconData? leadingIcon;
  final AppChipVariant variant;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.active = false,
    this.leadingIcon,
    this.variant = AppChipVariant.filter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Color bg;
    Color fg;
    Color borderColor;

    if (active) {
      switch (variant) {
        case AppChipVariant.filter:
          bg = p.onSurface;
          fg = p.surface;
          borderColor = Colors.transparent;
          break;
        case AppChipVariant.primary:
          bg = p.primaryContainer;
          fg = p.onPrimaryContainer;
          borderColor = Colors.transparent;
          break;
        case AppChipVariant.outline:
          bg = Colors.transparent;
          fg = p.primary;
          borderColor = p.primary;
          break;
      }
    } else {
      bg = Colors.transparent;
      fg = p.onSurface;
      borderColor = p.outline;
    }

    return Material(
      color: bg,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillAll,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.labelL.copyWith(
                  color: fg,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
