part of 'theme_bloc.dart';

@freezed
abstract class ThemeState with _$ThemeState {
  /// `paletteKey` is one of: `'caramel'`, `'espresso'`, `'matcha'`.
  /// Use [AppPalette.byKey] to resolve to the actual palette.
  const factory ThemeState({
    required String paletteKey,
  }) = _ThemeState;
}
