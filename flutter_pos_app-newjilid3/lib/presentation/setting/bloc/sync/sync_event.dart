part of 'sync_bloc.dart';

@freezed
abstract class SyncEvent with _$SyncEvent {
  /// Initial sync fired by SplashPage right after a successful auth gate.
  /// Pulls products + categories + best-effort push of pending orders.
  const factory SyncEvent.bootstrap() = _Bootstrap;

  /// Manual "Sinkronkan semua" CTA on Sinkronisasi Data page.
  const factory SyncEvent.syncAll() = _SyncAll;

  /// Per-domain manual triggers.
  const factory SyncEvent.pullProducts() = _PullProducts;
  const factory SyncEvent.pullCategories() = _PullCategories;
  const factory SyncEvent.pullPromos() = _PullPromos;
  const factory SyncEvent.pushOrders() = _PushOrders;

  /// Re-read counts from local DB without touching the network.
  /// Call after saving a new local order so pending-count stays accurate.
  const factory SyncEvent.refreshSnapshot() = _RefreshSnapshot;
}
