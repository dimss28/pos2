import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Centred empty-state with optional custom visual, explainer card,
/// primary CTA, and secondary CTA.
///
/// Used by: home-empty, order-detail-empty, draft-order-empty,
/// history-empty, printer (no devices). Customize the [visual] slot for the
/// stacked-receipt / dashed-cards / bar-chart placeholders shown in each
/// screen.
class AppEmptyState extends StatelessWidget {
  final Widget? visual;
  final String title;
  final String? body;
  final Widget? helperCard;
  final AppButton? primaryAction;
  final AppButton? secondaryAction;

  const AppEmptyState({
    super.key,
    required this.title,
    this.visual,
    this.body,
    this.helperCard,
    this.primaryAction,
    this.secondaryAction,
  });

  /// Convenience: full-page error with retry.
  factory AppEmptyState.error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return AppEmptyState(
      title: 'Terjadi kesalahan',
      body: message,
      primaryAction: onRetry == null
          ? null
          : AppButton(
              label: 'Coba lagi',
              variant: AppButtonVariant.primary,
              onPressed: onRetry,
              fullWidth: false,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (visual != null) ...[
              Center(child: visual!),
              const SizedBox(height: AppSpacing.xl),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleL.copyWith(color: p.onSurface),
            ),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyM.copyWith(color: p.onSurfaceVar),
              ),
            ],
            if (helperCard != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surfaceVariant,
                  borderRadius: AppRadius.mdAll,
                ),
                child: helperCard!,
              ),
            ],
            if (primaryAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              primaryAction!,
            ],
            if (secondaryAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              secondaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}
