import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standard bottom sheet shell used by every modal in the redesign.
/// Provides 24px top corners, a 40×4 drag handle, 20px horizontal padding,
/// and an optional sticky bottom action row.
///
/// The header row is built from `title` + optional `subtitle`. To insert a
/// richer header (e.g. icon + status pill in payment-qris), pass a custom
/// [headerBuilder] instead.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  String? subtitle,
  Widget Function(BuildContext context)? headerBuilder,
  Widget? bottomActions,
  double maxHeightFactor = 0.92,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AppBottomSheetShell(
      title: title,
      subtitle: subtitle,
      headerBuilder: headerBuilder,
      bottomActions: bottomActions,
      maxHeightFactor: maxHeightFactor,
      child: child,
    ),
  );
}

class _AppBottomSheetShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget Function(BuildContext context)? headerBuilder;
  final Widget? bottomActions;
  final double maxHeightFactor;

  const _AppBottomSheetShell({
    required this.child,
    required this.maxHeightFactor,
    this.title,
    this.subtitle,
    this.headerBuilder,
    this.bottomActions,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final maxH = MediaQuery.of(context).size.height * maxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: p.onSurface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (headerBuilder != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.md),
              child: headerBuilder!(context),
            )
          else if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style:
                        AppTypography.titleM.copyWith(color: p.onSurface),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyS
                          .copyWith(color: p.onSurfaceVar),
                    ),
                  ],
                ],
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
          ),
          if (bottomActions != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: p.surface,
                border: Border(top: BorderSide(color: p.outlineSoft)),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(0)),
              ),
              child: bottomActions!,
            ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
