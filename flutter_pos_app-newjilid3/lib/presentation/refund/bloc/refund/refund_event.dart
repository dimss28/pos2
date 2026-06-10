part of 'refund_bloc.dart';

@freezed
class RefundEvent with _$RefundEvent {
  const factory RefundEvent.submit({
    required int localOrderId,
    int? serverOrderId,
    required String reason,
    String? note,
    required int amount,
  }) = _Submit;

  const factory RefundEvent.reset() = _Reset;
}
