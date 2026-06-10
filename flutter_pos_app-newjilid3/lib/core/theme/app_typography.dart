import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Quicksand type scale. Source: `.claude/new-design/theme.jsx` TYPE.
///
/// Each style uses [GoogleFonts.quicksand] so the font is fetched once and
/// cached. For offline-first guarantees, bundle the .ttf files under
/// `assets/fonts/` and switch to a static [TextStyle] table.
class AppTypography {
  AppTypography._();

  static TextStyle _t({
    required double size,
    required FontWeight weight,
    required double lh,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.quicksand(
      fontSize: size,
      fontWeight: weight,
      height: lh / size,
      letterSpacing: letterSpacing,
    );
  }

  static final TextStyle displayL =
      _t(size: 32, weight: FontWeight.w700, lh: 40, letterSpacing: -0.5);
  static final TextStyle displayM =
      _t(size: 26, weight: FontWeight.w700, lh: 32, letterSpacing: -0.3);
  static final TextStyle titleL =
      _t(size: 22, weight: FontWeight.w700, lh: 28, letterSpacing: -0.2);
  static final TextStyle titleM =
      _t(size: 18, weight: FontWeight.w600, lh: 24);
  static final TextStyle titleS =
      _t(size: 15, weight: FontWeight.w600, lh: 20);
  static final TextStyle bodyL =
      _t(size: 16, weight: FontWeight.w500, lh: 24);
  static final TextStyle bodyM =
      _t(size: 14, weight: FontWeight.w500, lh: 20);
  static final TextStyle bodyS =
      _t(size: 12, weight: FontWeight.w500, lh: 16);
  static final TextStyle labelL =
      _t(size: 14, weight: FontWeight.w600, lh: 18, letterSpacing: 0.1);
  static final TextStyle labelM =
      _t(size: 12, weight: FontWeight.w600, lh: 16, letterSpacing: 0.3);
  static final TextStyle priceL =
      _t(size: 22, weight: FontWeight.w700, lh: 26, letterSpacing: -0.2);
  static final TextStyle priceM =
      _t(size: 17, weight: FontWeight.w700, lh: 22);

  /// Bridges to [TextTheme] for Material widgets that read it directly
  /// (e.g. AppBarTheme title). Mapping is approximate.
  static TextTheme textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: displayL.copyWith(color: onSurface),
      displayMedium: displayM.copyWith(color: onSurface),
      headlineLarge: displayM.copyWith(color: onSurface),
      headlineMedium: titleL.copyWith(color: onSurface),
      headlineSmall: titleM.copyWith(color: onSurface),
      titleLarge: titleL.copyWith(color: onSurface),
      titleMedium: titleM.copyWith(color: onSurface),
      titleSmall: titleS.copyWith(color: onSurface),
      bodyLarge: bodyL.copyWith(color: onSurface),
      bodyMedium: bodyM.copyWith(color: onSurface),
      bodySmall: bodyS.copyWith(color: onSurface),
      labelLarge: labelL.copyWith(color: onSurface),
      labelMedium: labelM.copyWith(color: onSurface),
      labelSmall: labelM.copyWith(color: onSurface),
    );
  }
}
