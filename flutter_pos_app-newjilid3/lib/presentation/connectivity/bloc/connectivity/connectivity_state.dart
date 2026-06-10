part of 'connectivity_bloc.dart';

@freezed
sealed class ConnectivityState with _$ConnectivityState {
  /// Pre-check (before [ConnectivityEvent.started] fires). UI should treat
  /// as "assume online" so it doesn't show stale offline banners on cold start.
  const factory ConnectivityState.unknown() = _Unknown;

  const factory ConnectivityState.online() = _Online;
  const factory ConnectivityState.offline() = _Offline;

  /// Transition state — emitted exactly once when going offline → online.
  /// Listeners use this to trigger background sync (push pending orders,
  /// refresh promo catalog, etc.).
  const factory ConnectivityState.restored() = _Restored;
}
