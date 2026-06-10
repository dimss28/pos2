part of 'draft_order_bloc.dart';

@freezed
sealed class DraftOrderEvent with _$DraftOrderEvent {
  const factory DraftOrderEvent.started() = _Started;

  /// Pull all drafts from the local DB.
  const factory DraftOrderEvent.getAllDraftOrder() = _GetAllDraftOrder;

  /// Delete a draft (by row id) and refresh the list.
  const factory DraftOrderEvent.removeDraft(int id) = _RemoveDraft;
}
