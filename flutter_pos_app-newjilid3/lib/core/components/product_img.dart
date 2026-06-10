import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Product image with three rendering modes:
/// 1. [imageUrl] given → loads via [CachedNetworkImage].
/// 2. [imageUrl] null → falls back to a hue-tinted initial-letter tile
///    (matches the placeholder pattern in the new-design JSX).
/// 3. While the network image is loading, shows the initial-letter tile.
class ProductImg extends StatelessWidget {
  final String name;

  /// Determinstic-ish hue 0–360. Pick from the product id with `id * 47 % 360`
  /// when migrating existing models. Defaults to 28 (warm orange).
  final int hue;
  final String? imageUrl;
  final double size;
  final BorderRadius radius;

  const ProductImg({
    super.key,
    required this.name,
    this.hue = 28,
    this.imageUrl,
    this.size = 56,
    this.radius = AppRadius.smAll,
  });

  Color get _bg => HSLColor.fromAHSL(1, hue.toDouble(), 0.35, 0.88).toColor();
  Color get _fg => HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.32).toColor();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    Widget buildFallback(double tileSize) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: _bg, borderRadius: radius),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTypography.titleM.copyWith(
              color: _fg,
              fontSize: tileSize * 0.42,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

    Widget withResolvedSize(Widget Function(double resolved) builder) {
      if (size.isFinite) return builder(size);
      return LayoutBuilder(
        builder: (_, c) {
          final maxSide = [c.maxWidth, c.maxHeight]
              .where((v) => v.isFinite)
              .fold<double>(56, (a, b) => b > a ? b : a);
          return builder(maxSide);
        },
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return withResolvedSize(buildFallback);
    }

    return withResolvedSize(
      (resolved) => ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: size,
          height: size,
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => buildFallback(resolved),
            errorWidget: (_, __, ___) => buildFallback(resolved),
          ),
        ),
      ),
    );
  }
}
