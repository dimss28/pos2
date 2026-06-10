import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Builds the project-wide [ThemeData] from an [AppPalette].
///
/// Material 3 is enabled. The Material [ColorScheme] is derived from the
/// palette's [AppPalette.primary] via [ColorScheme.fromSeed] so built-in
/// widgets (TextField, Switch, Slider, etc.) inherit the new look. Semantic
/// tokens not covered by [ColorScheme] (success, warning, onSurfaceVar, etc.)
/// are exposed via the [AppPalette] ThemeExtension.
class AppTheme {
  AppTheme._();

  static ThemeData fromPalette(AppPalette p) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: Brightness.light,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      surface: p.surface,
      onSurface: p.onSurface,
      surfaceContainerHighest: p.surfaceVariant,
      outline: p.outline,
      outlineVariant: p.outlineSoft,
      error: p.error,
      onError: Colors.white,
      errorContainer: p.errorContainer,
    );

    final textTheme = AppTypography.textTheme(p.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.surface,
      canvasColor: p.surface,
      dividerColor: p.outlineSoft,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[p],
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleL.copyWith(color: p.onSurface),
        iconTheme: IconThemeData(color: p.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: p.surface,
        modalBackgroundColor: p.surface,
        modalBarrierColor: Colors.black.withValues(alpha: 0.45),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: p.outlineSoft),
        ),
      ),
      // Default to a neutral, chrome-less InputDecoration so widgets that
      // provide their own outer container (AppTextField, the search bar, etc.)
      // don't render a duplicate fill+border inside. Pages that want a
      // standalone outlined TextField can opt in via local InputDecoration.
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTypography.bodyM.copyWith(color: p.onSurfaceVar),
        labelStyle: AppTypography.titleS.copyWith(color: p.onSurface),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppTypography.labelL.copyWith(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.onSurface,
          side: BorderSide(color: p.outline, width: 1.5),
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppTypography.labelL.copyWith(fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: AppTypography.labelL,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.onPrimary
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.primary
              : p.surfaceDim,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.onSurface,
        contentTextStyle:
            AppTypography.bodyM.copyWith(color: p.surface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      dividerTheme: DividerThemeData(
        color: p.outlineSoft,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
