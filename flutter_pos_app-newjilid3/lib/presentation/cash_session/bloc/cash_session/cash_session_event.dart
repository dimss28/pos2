part of 'cash_session_bloc.dart';

@freezed
class CashSessionEvent with _$CashSessionEvent {
  /// Hydrate state at app boot — checks if an open session exists.
  const factory CashSessionEvent.loaded() = _Loaded;

  /// Open a new shift with the given parameters.
  const factory CashSessionEvent.open({
    required String shiftLabel,
    required int openingFloat,
    String? note,
  }) = _Open;

  /// Close the current open shift. Variance is computed server-side from
  /// the recorded cash revenue; the client only provides the counts.
  const factory CashSessionEvent.close({
    required int physicalCount,
    int? cashIn,
    int? cashOut,
    String? note,
  }) = _Close;

  /// Force-reset state to `initial`. Use on logout.
  const factory CashSessionEvent.reset() = _Reset;
}
