part of 'checkout_bloc.dart';

@freezed
sealed class CheckoutState with _$CheckoutState {
  const factory CheckoutState.initial() = _Initial;
  const factory CheckoutState.loading() = _Loading;

  /// Cart state. [summary] carries the (immutable) list of items, derived
  /// totals, and an optional draft label. Replaces the legacy 4-positional
  /// `_Success(products, qty, price, draftName)`.
  const factory CheckoutState.success(CheckoutSummary summary) = _Success;

  const factory CheckoutState.error(String message) = _Error;
  const factory CheckoutState.savedDraftOrder() = _SavedDraftOrder;
}
