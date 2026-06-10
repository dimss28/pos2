part of 'history_bloc.dart';

@freezed
sealed class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = _Initial;
  const factory HistoryState.loading() = _Loading;

  /// Loaded state. [all] holds every order from local DB; [filtered] is the
  /// post-filter slice; [range] is the active filter.
  const factory HistoryState.success({
    required List<OrderModel> all,
    required List<OrderModel> filtered,
    @Default(HistoryDateRange.today) HistoryDateRange range,
    DateTime? customFrom,
    DateTime? customTo,
  }) = _Success;

  const factory HistoryState.error(String message) = _Error;
}
