import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

enum AppKVVariant {
  /// Default: onSurfaceVar label, onSurface value.
  regular,

  /// Big totals (e.g. "Total" in order summary).
  big,

  /// Value rendered in `success` (e.g. "Kembalian").
  accent,

  /// Value muted (`onSurfaceVar`) — e.g. discount amount.
  muted,

  /// Row preceded by a 1px top border + bolder text (e.g. "Estimasi kas akhir").
  highlight,
}

/// Label / value row used in every summary block.
///
/// Maps to: order summary, kembalian, close-kasir recon rows,
/// payment-success details, transaction-detail breakdown.
class AppKeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final AppKVVariant variant;
  final EdgeInsetsGeometry padding;

  const AppKeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.variant = AppKVVariant.regular,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    TextStyle labelStyle;
    TextStyle valueStyle;

    switch (variant) {
      case AppKVVariant.regular:
        labelStyle = AppTypography.bodyM.copyWith(color: p.onSurfaceVar);
        valueStyle = AppTypography.bodyM.copyWith(
          color: p.onSurface,
          fontWeight: FontWeight.w600,
        );
        break;
      case AppKVVariant.big:
        labelStyle = AppTypography.bodyL.copyWith(
          color: p.onSurface,
          fontWeight: FontWeight.w700,
        );
        valueStyle = AppTypography.priceL.copyWith(color: p.onSurface);
        break;
      case AppKVVariant.accent:
        labelStyle = AppTypography.bodyM.copyWith(color: p.onSurfaceVar);
        valueStyle = AppTypography.bodyM.copyWith(
          color: p.success,
          fontWeight: FontWeight.w700,
        );
        break;
      case AppKVVariant.muted:
        labelStyle = AppTypography.bodyM.copyWith(color: p.onSurfaceVar);
        valueStyle = AppTypography.bodyM.copyWith(color: p.onSurfaceVar);
        break;
      case AppKVVariant.highlight:
        labelStyle = AppTypography.bodyM.copyWith(
          color: p.onSurface,
          fontWeight: FontWeight.w700,
        );
        valueStyle = AppTypography.bodyM.copyWith(
          color: p.onSurface,
          fontWeight: FontWeight.w700,
        );
        break;
    }

    final row = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 12),
          Text(value, style: valueStyle),
        ],
      ),
    );

    if (variant == AppKVVariant.highlight) {
      return Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.outlineSoft)),
        ),
        child: row,
      );
    }
    return row;
  }
}
