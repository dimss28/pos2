import 'dart:async';
import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connectivity_bloc.freezed.dart';
part 'connectivity_event.dart';
part 'connectivity_state.dart';

/// App-wide online/offline state. Listens to
/// `Connectivity().onConnectivityChanged` and emits a coarse online flag.
///
/// Side effects (e.g. firing `SyncBloc.pushOrders()` when the connection
/// returns) are handled by a [BlocListener] in the app root — the bloc
/// itself stays pure so it can be tested without [SyncBloc] coupling.
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivityBloc({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const ConnectivityState.unknown()) {
    on<_Started>(_onStarted);
    on<_ResultChanged>(_onResultChanged);
  }

  Future<void> _onStarted(
      _Started event, Emitter<ConnectivityState> emit) async {
    try {
      final initial = await _connectivity.checkConnectivity();
      add(ConnectivityEvent.resultChanged(initial));
      _sub?.cancel();
      _sub = _connectivity.onConnectivityChanged.listen(
        (results) => add(ConnectivityEvent.resultChanged(results)),
        onError: (Object e) {
          if (kDebugMode) dev.log('connectivity stream error: $e');
        },
      );
    } catch (e) {
      if (kDebugMode) dev.log('connectivity init failed: $e');
    }
  }

  void _onResultChanged(
      _ResultChanged event, Emitter<ConnectivityState> emit) {
    final online = _isOnline(event.results);
    final wasOnline = state.maybeWhen(
      online: () => true,
      offline: () => false,
      orElse: () => null,
    );
    if (online && wasOnline == false) {
      emit(const ConnectivityState.restored());
    } else if (online) {
      emit(const ConnectivityState.online());
    } else {
      emit(const ConnectivityState.offline());
    }
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    // Anything other than `none` counts as online (wifi / mobile / vpn / ethernet).
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
