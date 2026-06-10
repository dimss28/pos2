part of 'history_bloc.dart';

enum HistoryDateRange { today, week, month, custom }

@freezed
sealed class HistoryEvent with _$HistoryEvent {
  const factory HistoryEvent.started() = _Started;

  /// Initial load. Tries remote first (so orders from other devices show up);
  /// falls back to local-only if the API call fails. Subsequent filter events
  /// operate on the cached merged list.
  const factory HistoryEvent.fetch() = _Fetch;

  /// Pull-to-refresh. Re-runs the remote pull and merges with local; preserves
  /// the active filter so the user doesn't lose their place.
  const factory HistoryEvent.refresh() = _Refresh;

  /// Switch active range filter. `from`/`to` only used when [range] is
  /// [HistoryDateRange.custom].
  const factory HistoryEvent.filterByRange({
    required HistoryDateRange range,
    DateTime? from,
    DateTime? to,
  }) = _FilterByRange;
}
