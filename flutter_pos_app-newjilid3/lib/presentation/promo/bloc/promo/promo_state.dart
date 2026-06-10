part of 'promo_bloc.dart';

@freezed
sealed class PromoState with _$PromoState {
  const factory PromoState.initial() = _Initial;
  const factory PromoState.loading() = _Loading;
  const factory PromoState.success(List<PromoModel> promos) = _Success;
  const factory PromoState.error(String message) = _Error;
}
