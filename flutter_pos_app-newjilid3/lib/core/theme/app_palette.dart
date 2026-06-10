import 'package:flutter/material.dart';

/// Semantic color tokens beyond the Material 3 [ColorScheme].
///
/// Three palettes ship: caramel (default), espresso, matcha.
/// Source: `.claude/new-design/theme.jsx`.
///
/// Access in widgets:
/// ```dart
/// final p = Theme.of(context).extension<AppPalette>()!;
/// Container(color: p.surface, ...);
/// ```
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final String name;

  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color secondary;

  final Color surface;
  final Color surfaceVariant;
  final Color surfaceDim;

  final Color outline;
  final Color outlineSoft;

  final Color onSurface;
  final Color onSurfaceVar;

  final Color success;
  final Color successContainer;

  final Color warning;
  final Color warningContainer;

  final Color error;
  final Color errorContainer;

  const AppPalette({
    required this.name,
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceDim,
    required this.outline,
    required this.outlineSoft,
    required this.onSurface,
    required this.onSurfaceVar,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.error,
    required this.errorContainer,
  });

  // ──────────────────────────────────────────────────────────
  // Palette presets (mirrors theme.jsx exactly)
  // ──────────────────────────────────────────────────────────

  static const AppPalette caramel = AppPalette(
    name: 'Caramel Latte',
    primary: Color(0xFFB8743D),
    primaryDark: Color(0xFF8A5527),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF8E6D0),
    onPrimaryContainer: Color(0xFF4A2810),
    secondary: Color(0xFF1F1812),
    surface: Color(0xFFFBF6EE),
    surfaceVariant: Color(0xFFEFE4D2),
    surfaceDim: Color(0xFFDECDB2),
    outline: Color(0xFFC9B59A),
    outlineSoft: Color(0xFFEBDFCB),
    onSurface: Color(0xFF241B12),
    onSurfaceVar: Color(0xFF6E5E48),
    success: Color(0xFF5A7A3A),
    successContainer: Color(0xFFE3EFD0),
    warning: Color(0xFFB87A1E),
    warningContainer: Color(0xFFF8E6C2),
    error: Color(0xFFA8392E),
    errorContainer: Color(0xFFF5D7D3),
  );

  static const AppPalette espresso = AppPalette(
    name: 'Espresso',
    primary: Color(0xFF5C3A21),
    primaryDark: Color(0xFF3E2613),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF1E4D4),
    onPrimaryContainer: Color(0xFF3E2613),
    secondary: Color(0xFF2A1F14),
    surface: Color(0xFFFAF5EE),
    surfaceVariant: Color(0xFFECE0D0),
    surfaceDim: Color(0xFFD9CAB6),
    outline: Color(0xFFC8B89E),
    outlineSoft: Color(0xFFE8DCC8),
    onSurface: Color(0xFF2A1F14),
    onSurfaceVar: Color(0xFF6B5C4A),
    success: Color(0xFF5A7A3A),
    successContainer: Color(0xFFE3EFD0),
    warning: Color(0xFFB87A1E),
    warningContainer: Color(0xFFF8E6C2),
    error: Color(0xFFA8392E),
    errorContainer: Color(0xFFF5D7D3),
  );

  static const AppPalette matcha = AppPalette(
    name: 'Matcha',
    primary: Color(0xFF6B8E3D),
    primaryDark: Color(0xFF4F6B2A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE4ECCD),
    onPrimaryContainer: Color(0xFF2A3815),
    secondary: Color(0xFF1B2014),
    surface: Color(0xFFF8FAF0),
    surfaceVariant: Color(0xFFE8ECD8),
    surfaceDim: Color(0xFFD2D9BD),
    outline: Color(0xFFBAC3A0),
    outlineSoft: Color(0xFFE2E8CF),
    onSurface: Color(0xFF1C2114),
    onSurfaceVar: Color(0xFF5E6650),
    success: Color(0xFF5A7A3A),
    successContainer: Color(0xFFE4ECCD),
    warning: Color(0xFFB87A1E),
    warningContainer: Color(0xFFF8E6C2),
    error: Color(0xFFA8392E),
    errorContainer: Color(0xFFF5D7D3),
  );

  /// Resolve a palette by its key. Falls back to [caramel].
  static AppPalette byKey(String? key) {
    switch (key) {
      case 'espresso':
        return espresso;
      case 'matcha':
        return matcha;
      case 'caramel':
      default:
        return caramel;
    }
  }

  /// Inverse of [byKey].
  static String keyOf(AppPalette p) {
    if (identical(p, espresso) || p.name == espresso.name) return 'espresso';
    if (identical(p, matcha) || p.name == matcha.name) return 'matcha';
    return 'caramel';
  }

  @override
  AppPalette copyWith({
    String? name,
    Color? primary,
    Color? primaryDark,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceDim,
    Color? outline,
    Color? outlineSoft,
    Color? onSurface,
    Color? onSurfaceVar,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? error,
    Color? errorContainer,
  }) {
    return AppPalette(
      name: name ?? this.name,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      outline: outline ?? this.outline,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVar: onSurfaceVar ?? this.onSurfaceVar,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      name: t < 0.5 ? name : other.name,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVar: Color.lerp(onSurfaceVar, other.onSurfaceVar, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
    );
  }
}

/// Short accessor: `context.palette.primary`.
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.caramel;
}
