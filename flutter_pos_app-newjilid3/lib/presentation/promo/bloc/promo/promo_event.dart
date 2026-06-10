part of 'promo_bloc.dart';

@freezed
sealed class PromoEvent with _$PromoEvent {
  /// Hydrate from local cache (no network).
  const factory PromoEvent.loadFromCache() = _LoadFromCache;

  /// Force re-pull from BE, then mirror to cache.
  const factory PromoEvent.refreshFromRemote() = _RefreshFromRemote;

  /// Flip `active` on the given promo.
  const factory PromoEvent.toggle(int id) = _Toggle;

  /// Create or update (id-driven).
  const factory PromoEvent.save(PromoModel promo) = _Save;

  /// Delete a promo by id.
  const factory PromoEvent.delete(int id) = _Delete;
}
