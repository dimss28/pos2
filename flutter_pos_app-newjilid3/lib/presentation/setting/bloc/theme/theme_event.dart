part of 'theme_bloc.dart';

@freezed
class ThemeEvent with _$ThemeEvent {
  /// Read the persisted palette key from SharedPreferences.
  const factory ThemeEvent.loaded() = _Loaded;

  /// Persist a new palette key and emit immediately.
  const factory ThemeEvent.changed(String paletteKey) = _Changed;
}
