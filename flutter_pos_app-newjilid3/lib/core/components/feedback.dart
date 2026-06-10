import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';
import 'app_icon_button.dart';

/// Project-wide feedback helpers.
///
/// Use [AppSnackbar] for transient toasts, [AppConfirm.show] for yes/no
/// prompts (returns [bool]), and [AppLoadingDialog] for blocking spinners.

class AppSnackbar {
  AppSnackbar._();

  static void _show(BuildContext context, String message, Color bg, Color fg,
      {IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
          margin: const EdgeInsets.all(16),
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyM.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    final p = Theme.of(context).extension<AppPalette>() ?? AppPalette.caramel;
    _show(context, message, p.success, Colors.white,
        icon: Icons.check_circle_outline);
  }

  static void error(BuildContext context, String message) {
    final p = Theme.of(context).extension<AppPalette>() ?? AppPalette.caramel;
    _show(context, message, p.error, Colors.white,
        icon: Icons.error_outline);
  }

  static void info(BuildContext context, String message) {
    final p = Theme.of(context).extension<AppPalette>() ?? AppPalette.caramel;
    _show(context, message, p.onSurface, p.surface,
        icon: Icons.info_outline);
  }
}

class AppConfirm {
  AppConfirm._();

  /// Yes/no confirmation dialog. Returns `true` on confirm, `false` on cancel
  /// or barrier dismiss.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    String confirmLabel = 'Lanjut',
    String cancelLabel = 'Batal',
    bool destructive = false,
  }) async {
    final p = Theme.of(context).extension<AppPalette>() ?? AppPalette.caramel;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: p.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: AppTypography.titleM.copyWith(color: p.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: AppTypography.bodyM.copyWith(color: p.onSurfaceVar),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: cancelLabel,
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.md,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: confirmLabel,
                      variant: destructive
                          ? AppButtonVariant.danger
                          : AppButtonVariant.primary,
                      size: AppButtonSize.md,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }
}

class AppLoadingDialog {
  AppLoadingDialog._();

  static bool _showing = false;

  /// Show a non-dismissible spinner. Pair every [show] with [hide].
  static void show(BuildContext context, {String? message}) {
    if (_showing) return;
    _showing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final p = Theme.of(ctx).extension<AppPalette>() ?? AppPalette.caramel;
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: AppRadius.lgAll,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: p.primary),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style:
                          AppTypography.bodyM.copyWith(color: p.onSurface),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    if (!_showing) return;
    _showing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Simple action menu helper for the AppBar overflow ("⋯") on
/// transaction-detail and similar pages. Returns the picked value or null.
Future<T?> showAppActionSheet<T>({
  required BuildContext context,
  required List<AppActionItem<T>> items,
  String? title,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final p = Theme.of(ctx).extension<AppPalette>() ?? AppPalette.caramel;
      return SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: AppRadius.lgAll,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: AppTypography.titleS
                          .copyWith(color: p.onSurfaceVar),
                    ),
                  ),
                ),
              ],
              for (final item in items)
                InkWell(
                  onTap: () => Navigator.of(ctx).pop(item.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            size: 20,
                            color: item.destructive ? p.error : p.onSurface,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppTypography.bodyL.copyWith(
                              color:
                                  item.destructive ? p.error : p.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: AppIconButton(
                  icon: Icons.close_rounded,
                  variant: AppIconButtonVariant.surfaceVariant,
                  size: 40,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class AppActionItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool destructive;

  const AppActionItem({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
  });
}
