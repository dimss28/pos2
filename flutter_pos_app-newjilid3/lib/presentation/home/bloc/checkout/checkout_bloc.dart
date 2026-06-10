import 'package:bloc/bloc.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:flutter_pos_app/presentation/home/models/checkout_summary.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';
import 'package:flutter_pos_app/presentation/order/models/draft_order_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../../../data/datasources/product_local_datasource.dart';
import '../../models/draft_order_item.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';
part 'checkout_bloc.freezed.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final ProductLocalDatasource _local;

  CheckoutBloc({ProductLocalDatasource? local})
      : _local = local ?? ProductLocalDatasource.instance,
        super(const CheckoutState.success(CheckoutSummary())) {
    on<_AddCheckout>(_onAdd);
    on<_RemoveCheckout>(_onDecrement);
    on<_RemoveProduct>(_onRemove);
    on<_Started>(_onStarted);
    on<_SaveDraftOrder>(_onSaveDraft);
    on<_LoadDraftOrder>(_onLoadDraft);
  }

  CheckoutSummary _summaryFrom(List<OrderItem> items, {String? draftName}) {
    final (qty, price) = CheckoutSummary.totalsOf(items);
    final cur = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    return cur.copyWith(
      products: items,
      totalQuantity: qty,
      totalPrice: price,
      draftName: draftName ?? cur.draftName,
    );
  }

  void _onAdd(_AddCheckout event, Emitter<CheckoutState> emit) {
    final current = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    final newItems = [...current.products];
    final idx = newItems
        .indexWhere((element) => element.product == event.product);
    final inCartQty = idx >= 0 ? newItems[idx].quantity : 0;

    // V1 stock guard: cap at available stock. The Home grid disables the
    // add button at the cap, so reaching here usually means a race / bug.
    // We still defensively no-op rather than letting cart exceed stock.
    final stock = event.product.stock;
    if (stock > 0 && inCartQty >= stock) {
      return;
    }

    if (idx >= 0) {
      newItems[idx].quantity++;
    } else {
      newItems.add(OrderItem(product: event.product, quantity: 1));
    }
    emit(CheckoutState.success(_summaryFrom(newItems)));
  }

  void _onDecrement(_RemoveCheckout event, Emitter<CheckoutState> emit) {
    final current = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    final newItems = [...current.products];
    final idx = newItems
        .indexWhere((element) => element.product == event.product);
    if (idx >= 0) {
      if (newItems[idx].quantity > 1) {
        newItems[idx].quantity--;
      } else {
        newItems.removeAt(idx);
      }
    }
    emit(CheckoutState.success(_summaryFrom(newItems)));
  }

  void _onRemove(_RemoveProduct event, Emitter<CheckoutState> emit) {
    final current = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    final newItems = [...current.products]
      ..removeWhere((e) => e.product == event.product);
    emit(CheckoutState.success(_summaryFrom(newItems)));
  }

  void _onStarted(_Started event, Emitter<CheckoutState> emit) {
    emit(const CheckoutState.success(CheckoutSummary()));
  }

  Future<void> _onSaveDraft(
      _SaveDraftOrder event, Emitter<CheckoutState> emit) async {
    final current = state.maybeWhen(
      success: (s) => s,
      orElse: () => const CheckoutSummary(),
    );
    // If this cart originated from an existing Open Bill, drop the old row
    // first so we don't accumulate duplicates.
    if (current.linkedDraftId != null) {
      await _local.removeDraftOrderById(current.linkedDraftId!);
    }
    final draftOrder = DraftOrderModel(
      orders: current.products
          .map((e) =>
              DraftOrderItem(product: e.product, quantity: e.quantity))
          .toList(),
      totalQuantity: current.totalQuantity,
      totalPrice: current.totalPrice,
      tableLabel: event.tableLabel,
      customerName: event.customerName,
      tableNumber: event.tableNumber,
      draftName: event.customerName,
      transactionTime:
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );
    await _local.saveDraftOrder(draftOrder);
    emit(const CheckoutState.savedDraftOrder());
  }

  void _onLoadDraft(_LoadDraftOrder event, Emitter<CheckoutState> emit) {
    final draftOrder = event.data;
    final items = draftOrder.orders
        .map((e) => OrderItem(product: e.product, quantity: e.quantity))
        .toList();
    final (qty, price) = CheckoutSummary.totalsOf(items);
    emit(CheckoutState.success(CheckoutSummary(
      products: items,
      totalQuantity: qty,
      totalPrice: price,
      draftName: draftOrder.displayCustomerName,
      linkedDraftId: draftOrder.id,
      linkedTableLabel: draftOrder.displayTableLabel,
      linkedCustomerName: draftOrder.displayCustomerName,
    )));
  }
}
