import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

enum AppIconButtonVariant { transparent, surfaceVariant, surface }

/// 44×44 square icon button. Used for back arrows, calendar, share, dots.
///
/// Maps to: the recurring `IconButton` chrome across every screen
/// (see `.claude/new-design/screens/history-loaded.jsx` AppBar trailing).
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.transparent,
    this.size = 44,
    this.iconSize = 22,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = switch (variant) {
      AppIconButtonVariant.transparent => Colors.transparent,
      AppIconButtonVariant.surfaceVariant => p.surfaceVariant,
      AppIconButtonVariant.surface => Colors.white,
    };
    final fg = iconColor ?? p.onSurface;

    final btn = Material(
      color: bg,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.smAll,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: fg),
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}
