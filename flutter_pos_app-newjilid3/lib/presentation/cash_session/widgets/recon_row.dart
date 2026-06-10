import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';

/// Row in the Rekonsiliasi Kas card. `highlight=true` adds a thin top
/// divider and renders both label + value in bold (used for the
/// "Estimasi kas akhir" totals row).
///
/// Maps to `ReconRow` in `.claude/new-design/screens/close-kasir.jsx:235`.
class ReconRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool last;

  const ReconRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.only(top: highlight ? 12 : 10, bottom: 10),
      margin: EdgeInsets.only(top: highlight ? 4 : 0),
      decoration: BoxDecoration(
        border: Border(
          top: highlight
              ? BorderSide(color: p.onSurface.withValues(alpha: 0.13), width: 1.5)
              : BorderSide.none,
          bottom: (highlight || last)
              ? BorderSide.none
              : BorderSide(color: p.outlineSoft),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(
                color: highlight ? p.onSurface : p.onSurfaceVar,
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.titleM.copyWith(
              color: p.onSurface,
              fontSize: highlight ? 16 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
