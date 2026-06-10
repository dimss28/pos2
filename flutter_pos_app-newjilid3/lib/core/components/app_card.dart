import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

/// White surface card with 1px [AppPalette.outlineSoft] border.
/// The redesign avoids drop shadows on cards; this is the standard chrome.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final BorderRadius radius;
  final Border? border;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.background,
    this.radius = AppRadius.mdAll,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: radius,
        border: border ?? Border.all(color: p.outlineSoft),
      ),
      child: child,
    );
    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: container,
      ),
    );
  }
}
