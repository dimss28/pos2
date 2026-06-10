import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';

import '../../../order/models/draft_order_model.dart';

part 'draft_order_bloc.freezed.dart';
part 'draft_order_event.dart';
part 'draft_order_state.dart';

class DraftOrderBloc extends Bloc<DraftOrderEvent, DraftOrderState> {
  final ProductLocalDatasource _local;

  DraftOrderBloc(this._local) : super(const DraftOrderState.initial()) {
    on<_GetAllDraftOrder>(_onLoad);
    on<_RemoveDraft>(_onRemove);
  }

  Future<void> _onLoad(
      _GetAllDraftOrder event, Emitter<DraftOrderState> emit) async {
    emit(const DraftOrderState.loading());
    try {
      final list = await _local.getAllDraftOrder();
      emit(DraftOrderState.success(list));
    } catch (e) {
      emit(DraftOrderState.error(e.toString()));
    }
  }

  Future<void> _onRemove(
      _RemoveDraft event, Emitter<DraftOrderState> emit) async {
    final current = state.maybeWhen(
      success: (list) => list,
      orElse: () => <DraftOrderModel>[],
    );
    // Optimistic update — remove from in-memory list first, then DB.
    emit(DraftOrderState.success(
      current.where((d) => d.id != event.id).toList(),
    ));
    try {
      await _local.removeDraftOrderById(event.id);
    } catch (e) {
      // On failure refetch authoritative list.
      add(const DraftOrderEvent.getAllDraftOrder());
    }
  }
}
