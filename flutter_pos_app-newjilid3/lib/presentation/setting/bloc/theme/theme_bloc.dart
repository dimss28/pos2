import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_palette.dart';

part 'theme_bloc.freezed.dart';
part 'theme_event.dart';
part 'theme_state.dart';

/// Persists the user's palette choice in SharedPreferences and emits the
/// resolved [AppPalette] for the app to rebuild against.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _prefsKey = 'palette';

  ThemeBloc() : super(const ThemeState(paletteKey: 'caramel')) {
    on<_Loaded>(_onLoaded);
    on<_Changed>(_onChanged);
  }

  Future<void> _onLoaded(_Loaded event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_prefsKey) ?? 'caramel';
    emit(ThemeState(paletteKey: key));
  }

  Future<void> _onChanged(_Changed event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, event.paletteKey);
    emit(ThemeState(paletteKey: event.paletteKey));
  }
}
