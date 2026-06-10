part of 'connectivity_bloc.dart';

@freezed
sealed class ConnectivityEvent with _$ConnectivityEvent {
  /// Subscribe to the connectivity stream + fire one initial check.
  const factory ConnectivityEvent.started() = _Started;

  /// Internal — pushed by the stream listener.
  const factory ConnectivityEvent.resultChanged(
    List<ConnectivityResult> results,
  ) = _ResultChanged;
}
