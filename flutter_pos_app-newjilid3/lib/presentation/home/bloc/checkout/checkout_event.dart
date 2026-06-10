part of 'checkout_bloc.dart';

@freezed
sealed class CheckoutEvent with _$CheckoutEvent {
  const factory CheckoutEvent.started() = _Started;
  const factory CheckoutEvent.addCheckout(Product product) = _AddCheckout;
  const factory CheckoutEvent.removeCheckout(Product product) = _RemoveCheckout;
  const factory CheckoutEvent.removeProduct(Product product) = _RemoveProduct;

  /// Save the current cart as a draft. [tableLabel] is a free-text label
  /// ("Meja 4", "Takeaway", "Bar 2"); [customerName] is optional.
  /// Legacy `tableNumber` positional fallback kept for back-compat with old
  /// callers — new code should pass the named params.
  const factory CheckoutEvent.saveDraftOrder({
    @Default('') String tableLabel,
    @Default('') String customerName,
    @Default(0) int tableNumber,
  }) = _SaveDraftOrder;

  const factory CheckoutEvent.loadDraftOrder(DraftOrderModel data) =
      _LoadDraftOrder;
}
