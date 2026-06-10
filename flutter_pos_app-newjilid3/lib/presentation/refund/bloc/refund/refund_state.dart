part of 'refund_bloc.dart';

@freezed
class RefundState with _$RefundState {
  const factory RefundState.initial() = _Initial;
  const factory RefundState.loading() = _Loading;
  const factory RefundState.success() = _Success;
  const factory RefundState.successWithRemoteWarning(String warning) =
      _SuccessWithRemoteWarning;
  const factory RefundState.error(String message) = _Error;
}
