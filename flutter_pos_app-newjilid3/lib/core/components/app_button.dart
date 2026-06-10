import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, primaryWithArrow, outline, ghost, danger }

enum AppButtonSize { sm, md, lg }

/// Primary button atom for every CTA in the redesign.
///
/// `primaryWithArrow` adds a trailing 40×40 chip with an arrow — used on
/// sticky footers like "Bayar →" and "Mulai Shift Siang →".
///
/// Maps to: `PrimaryButton` in `.claude/new-design/screens/login.jsx:57`.
class AppButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool fullWidth;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.onPressed,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.size = AppButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.onPressed,
  }) : variant = AppButtonVariant.primary;

  const AppButton.primaryWithArrow({
    super.key,
    required this.label,
    this.leadingIcon,
    this.size = AppButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.onPressed,
  })  : variant = AppButtonVariant.primaryWithArrow,
        trailingIcon = null;

  const AppButton.outline({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.size = AppButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.onPressed,
  }) : variant = AppButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.size = AppButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.onPressed,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.size = AppButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.onPressed,
  }) : variant = AppButtonVariant.danger;

  double get _height => switch (size) {
        AppButtonSize.sm => 40,
        AppButtonSize.md => 48,
        AppButtonSize.lg => 56,
      };

  double get _iconSize => switch (size) {
        AppButtonSize.sm => 18,
        AppButtonSize.md => 20,
        AppButtonSize.lg => 22,
      };

  double get _fontSize => switch (size) {
        AppButtonSize.sm => 13,
        AppButtonSize.md => 15,
        AppButtonSize.lg => 16,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onPressed != null && !loading;

    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadow;

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.primaryWithArrow:
        bg = p.primary;
        fg = p.onPrimary;
        shadow = enabled
            ? [
                BoxShadow(
                  color: p.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = p.onSurface;
        border = Border.all(color: p.outline, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = p.primary;
        break;
      case AppButtonVariant.danger:
        bg = Colors.transparent;
        fg = p.error;
        border = Border.all(color: p.error.withValues(alpha: 0.55), width: 1.5);
        break;
    }

    final textStyle = AppTypography.labelL.copyWith(
      color: fg,
      fontSize: _fontSize,
      fontWeight: FontWeight.w700,
    );

    Widget content;
    if (loading) {
      content = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: fg,
        ),
      );
    } else {
      content = Row(
        mainAxisAlignment: variant == AppButtonVariant.primaryWithArrow
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (variant == AppButtonVariant.primaryWithArrow)
            const SizedBox(width: 40)
          else if (leadingIcon != null) ...[
            Icon(leadingIcon, size: _iconSize, color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (variant == AppButtonVariant.primaryWithArrow)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: fg.withValues(alpha: 0.18),
                borderRadius: AppRadius.mdAll,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.arrow_forward_rounded, size: 20, color: fg),
            )
          else if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: _iconSize, color: fg),
          ],
        ],
      );
    }

    final hPadding = variant == AppButtonVariant.primaryWithArrow ? 6.0 : 16.0;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: AppRadius.mdAll,
          child: Container(
            height: _height,
            width: fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.mdAll,
              border: border,
              boxShadow: shadow,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
