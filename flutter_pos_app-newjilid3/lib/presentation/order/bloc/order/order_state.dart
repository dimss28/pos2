part of 'order_bloc.dart';

@freezed
sealed class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  const factory OrderState.loading() = _Loading;

  /// Working order state. The wrapped [OrderSummary] holds line items,
  /// totals, payment metadata, cashier id+name, and cash_session_id.
  const factory OrderState.success(OrderSummary summary) = _Success;

  /// Emitted after [OrderEvent.persistLocal] completes successfully.
  /// Carries the local DB row id of the saved order.
  const factory OrderState.persisted(int localOrderId, OrderSummary summary) =
      _Persisted;

  const factory OrderState.error(String message) = _Error;
}
