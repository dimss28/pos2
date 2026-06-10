import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppBannerKind { success, warning, error, info, primary }

/// Inline notice card with a tinted background and matching border.
/// Layout: [leadingIcon] (in a 36px tinted tile) → title + optional body →
/// optional [trailing] (e.g. an action button or pill).
///
/// Maps to: home-empty warning, printer warning, sync-data success,
/// transaction-detail "Pembayaran lunas" hero.
class AppBanner extends StatelessWidget {
  final AppBannerKind kind;
  final String title;
  final String? body;
  final IconData? leadingIcon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const AppBanner({
    super.key,
    required this.title,
    this.body,
    this.kind = AppBannerKind.info,
    this.leadingIcon,
    this.trailing,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final (bg, border, fg, accent) = switch (kind) {
      AppBannerKind.success => (
        p.successContainer,
        p.success.withValues(alpha: 0.25),
        p.onSurface,
        p.success,
      ),
      AppBannerKind.warning => (
        p.warningContainer,
        p.warning.withValues(alpha: 0.25),
        const Color(0xFF7C4A0E),
        p.warning,
      ),
      AppBannerKind.error => (
        p.errorContainer,
        p.error.withValues(alpha: 0.25),
        p.onSurface,
        p.error,
      ),
      AppBannerKind.info => (
        p.surfaceVariant,
        p.outlineSoft,
        p.onSurface,
        p.primary,
      ),
      AppBannerKind.primary => (
        p.primary,
        Colors.transparent,
        p.onPrimary,
        p.onPrimary,
      ),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kind == AppBannerKind.primary
                    ? fg.withValues(alpha: 0.18)
                    : accent.withValues(alpha: 0.15),
                borderRadius: AppRadius.smAll,
              ),
              alignment: Alignment.center,
              child: Icon(leadingIcon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyM.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    body!,
                    style: AppTypography.bodyS.copyWith(
                      color: kind == AppBannerKind.primary
                          ? fg.withValues(alpha: 0.85)
                          : fg.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
