import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppBadgeKind { stockLow, stockOut, qty, neutral }

/// Compact rectangular badge for stock and quantity hints.
///
/// Maps to: stock badges in `.claude/new-design/screens/home.jsx:59-68`,
/// in-cart qty badges in `.claude/new-design/screens/home-loaded.jsx:178-187`.
class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeKind kind;
  final IconData? leadingIcon;

  const AppBadge({
    super.key,
    required this.label,
    this.kind = AppBadgeKind.neutral,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg) = switch (kind) {
      AppBadgeKind.stockLow =>
        (p.warningContainer, const Color(0xFF92400E)),
      AppBadgeKind.stockOut => (p.errorContainer, p.error),
      AppBadgeKind.qty => (p.primary, p.onPrimary),
      AppBadgeKind.neutral => (p.surfaceVariant, p.onSurfaceVar),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelM.copyWith(color: fg, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Floating circular counter for cart-item dots and nav badges.
class AppCountBadge extends StatelessWidget {
  final int count;
  final Color? background;
  final Color? foreground;
  final Color? border;

  const AppCountBadge({
    super.key,
    required this.count,
    this.background,
    this.foreground,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = background ?? p.primary;
    final fg = foreground ?? p.onPrimary;

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        border: border != null ? Border.all(color: border!, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTypography.labelM.copyWith(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
