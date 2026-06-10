import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

/// Tiny uppercase label that introduces a section.
/// 11px, letterSpacing 1.2, `onSurfaceVar`. Default margins 18 top / 8 bottom.
///
/// Maps to: section headers across all screens (Settings groups, Order
/// summary, Recon, Detail Transaksi, etc.).
class AppSectionLabel extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry margin;

  const AppSectionLabel(
    this.label, {
    super.key,
    this.margin = const EdgeInsets.only(top: 18, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: margin,
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelM.copyWith(
          color: p.onSurfaceVar,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
