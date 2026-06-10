part of 'cash_session_bloc.dart';

@freezed
class CashSessionState with _$CashSessionState {
  const factory CashSessionState.initial() = _Initial;
  const factory CashSessionState.loading() = _Loading;

  /// No open shift exists for the current user. [lastClosed] is the most
  /// recent closed session (any user) — used to render the recap card on
  /// BukaKasirPage.
  const factory CashSessionState.noSession([CashSessionModel? lastClosed]) =
      _NoSession;

  /// Active shift. [current.id] is non-null at this point.
  const factory CashSessionState.open(CashSessionModel current) = _Active;

  const factory CashSessionState.error(String message) = _Error;
}
