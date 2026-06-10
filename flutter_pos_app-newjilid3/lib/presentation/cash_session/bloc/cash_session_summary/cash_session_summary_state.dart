part of 'cash_session_summary_bloc.dart';

@freezed
class CashSessionSummaryState with _$CashSessionSummaryState {
  const factory CashSessionSummaryState.initial() = _Initial;
  const factory CashSessionSummaryState.loading() = _Loading;
  const factory CashSessionSummaryState.loaded(
    int sessionId,
    Map<String, dynamic> summary,
  ) = _Loaded;
  const factory CashSessionSummaryState.error(String message) = _Error;
}
