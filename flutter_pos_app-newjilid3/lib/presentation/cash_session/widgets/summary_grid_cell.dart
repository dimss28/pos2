import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

/// One cell in the 2×2 metrics grid on TutupKasirPage.
/// `accent` swaps surface → onSurface inverse (used for "Total Pendapatan").
///
/// Maps to `SummaryCellCK` in `.claude/new-design/screens/close-kasir.jsx:184`.
class SummaryGridCell extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const SummaryGridCell({
    super.key,
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = accent ? p.onSurface : Colors.white;
    final labelColor = accent ? p.surface.withValues(alpha: 0.66) : p.onSurfaceVar;
    final valueColor = accent ? p.surface : p.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdAll,
        border: accent ? null : Border.all(color: p.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelM.copyWith(
              color: labelColor,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.displayM.copyWith(
              fontSize: accent ? 26 : 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
