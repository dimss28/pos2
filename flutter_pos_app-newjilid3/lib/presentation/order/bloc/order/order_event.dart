part of 'order_bloc.dart';

@freezed
sealed class OrderEvent with _$OrderEvent {
  const factory OrderEvent.started() = _Started;

  /// Set the chosen payment method and cart items. Triggered when the
  /// user taps "Cash" / "QRIS" / "Transfer" on the OrderPage.
  /// `cashSessionId` is read from the open shift and carried through to
  /// `persistLocal` so the BE can attribute revenue.
  const factory OrderEvent.addPaymentMethod({
    required String paymentMethod,
    required List<OrderItem> orders,
    required String customerName,
    required int? cashSessionId,
  }) = _AddPaymentMethod;

  /// Set the cash received from the customer (cash flow only).
  const factory OrderEvent.addNominalBayar(int nominal) = _AddNominalBayar;

  /// Apply a discount to the current order. Recomputes totalPrice.
  const factory OrderEvent.applyDiscount(AppliedDiscount discount) =
      _ApplyDiscount;

  /// Remove the active discount (reverts totalPrice to subtotal).
  const factory OrderEvent.clearDiscount() = _ClearDiscount;

  /// Persist the current order summary to the local SQLite `orders` table
  /// with `is_sync = 0`. After success the bloc emits [OrderState.persisted].
  /// Subsequent push to the backend is handled by [SyncBloc.pushOrders].
  const factory OrderEvent.persistLocal() = _PersistLocal;

  /// Reset to a clean cart (clears the OrderSummary).
  const factory OrderEvent.reset() = _Reset;
}
