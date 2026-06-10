import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

enum ChecklistStatus { ok, warn }

/// Row in the "Cek persiapan" card on BukaKasirPage. Maps to `ChecklistRow`
/// in `.claude/new-design/screens/buka-kasir.jsx:223`.
class ChecklistRow extends StatelessWidget {
  final String title;
  final String detail;
  final ChecklistStatus status;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool last;

  const ChecklistRow({
    super.key,
    required this.title,
    required this.detail,
    required this.status,
    this.actionLabel,
    this.onAction,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ok = status == ChecklistStatus.ok;
    final dotBg = ok ? p.successContainer : p.warningContainer;
    final dotFg = ok ? p.success : const Color(0xFF7C4A0E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: p.outlineSoft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: dotBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(
              ok ? Icons.check_rounded : Icons.error_outline,
              size: 16,
              color: dotFg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyL.copyWith(
                    color: p.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  detail,
                  style: AppTypography.bodyS.copyWith(
                    color: p.onSurfaceVar,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onAction,
              borderRadius: AppRadius.smAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.smAll,
                  border: Border.all(color: p.outline),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.labelL.copyWith(
                    color: p.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
