part of 'cash_session_summary_bloc.dart';

@freezed
class CashSessionSummaryEvent with _$CashSessionSummaryEvent {
  /// Initial fetch for a given session id. Fired once from `initState`.
  const factory CashSessionSummaryEvent.load(int sessionId) = _Load;

  /// Re-fetch using the previously-loaded session id. Use after pushing
  /// pending orders so the cash_revenue figure updates.
  const factory CashSessionSummaryEvent.refresh() = _Refresh;
}
