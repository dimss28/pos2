import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/order_remote_datasource.dart';
import '../../../../data/datasources/product_local_datasource.dart';
import '../../../order/models/order_model.dart';

part 'refund_event.dart';
part 'refund_state.dart';
part 'refund_bloc.freezed.dart';

/// V1 full-refund bloc.
///
/// One-shot: open the sheet, submit a reason + optional note, watch the
/// `success` / `error` transition. The bloc is registered globally (see
/// `main.dart`) so any page can listen, but the typical consumer is the
/// `RefundSheet` opened from `TransactionDetailPage`.
class RefundBloc extends Bloc<RefundEvent, RefundState> {
  final OrderRemoteDatasource _remote;
  final ProductLocalDatasource _local;
  final AuthLocalDatasource _auth;

  RefundBloc({
    OrderRemoteDatasource? remote,
    ProductLocalDatasource? local,
    AuthLocalDatasource? auth,
  })  : _remote = remote ?? OrderRemoteDatasource(),
        _local = local ?? ProductLocalDatasource.instance,
        _auth = auth ?? AuthLocalDatasource(),
        super(const RefundState.initial()) {
    on<_Submit>(_onSubmit);
    on<_Reset>((_, emit) => emit(const RefundState.initial()));
  }

  Future<void> _onSubmit(_Submit event, Emitter<RefundState> emit) async {
    emit(const RefundState.loading());
    try {
      final auth = await _auth.getAuthData();

      // Best-effort BE refund. We still proceed with the local update even
      // when offline / BE rejects, but surface the error so the user knows.
      String? remoteError;
      OrderModel? refreshed;
      if (event.serverOrderId != null) {
        final r = await _remote.refund(
          orderId: event.serverOrderId!,
          reason: event.reason,
          note: event.note,
        );
        r.fold(
          (msg) => remoteError = msg,
          (o) => refreshed = o,
        );
      }

      await _local.markOrderRefunded(
        localOrderId: event.localOrderId,
        reason: event.reason,
        amount: event.amount,
        note: event.note,
        userId: auth.user.id,
        refundedAtIso: refreshed?.refundedAt,
      );

      if (remoteError != null && event.serverOrderId != null) {
        // Local marked refunded; sync will reconcile later. Bubble up the
        // BE message so caller can show a softer warning instead of error.
        emit(RefundState.successWithRemoteWarning(remoteError!));
      } else {
        emit(const RefundState.success());
      }
    } catch (e) {
      emit(RefundState.error(e.toString()));
    }
  }
}
