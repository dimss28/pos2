part of 'sync_bloc.dart';

/// All sync UI reads from one [SyncSnapshot] — single source of truth for
/// per-domain counts, last-sync timestamps, in-progress domain, and the
/// latest error per domain (if any).
@freezed
abstract class SyncSnapshot with _$SyncSnapshot {
  const factory SyncSnapshot({
    @Default(0) int productCount,
    @Default(0) int categoryCount,
    @Default(0) int promoCount,
    @Default(0) int pendingOrderCount,
    DateTime? lastSyncProductsAt,
    DateTime? lastSyncCategoriesAt,
    DateTime? lastSyncPromosAt,
    DateTime? lastSyncOrdersAt,

    /// Non-null while a sync is in flight. Value is the domain key:
    /// `'products' | 'categories' | 'promos' | 'orders'`.
    String? inProgress,

    /// Last error per domain. Empty map = everything clean.
    @Default(<String, String>{}) Map<String, String> errors,
  }) = _SyncSnapshot;
}

@freezed
abstract class SyncState with _$SyncState {
  /// Pre-bootstrap. Should be replaced by `ready` on the first
  /// `SyncBloc` event (typically `bootstrap` or `refreshSnapshot`).
  const factory SyncState.initial() = _Initial;

  const factory SyncState.ready(SyncSnapshot snapshot) = _Ready;
}
