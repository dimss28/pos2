import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/product_local_datasource.dart';
import '../../../home/models/order_item.dart';
import '../../../promo/models/applied_discount.dart';
import '../../models/order_model.dart';
import '../../models/order_summary.dart';

part 'order_event.dart';
part 'order_state.dart';
part 'order_bloc.freezed.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final AuthLocalDatasource _auth;
  final ProductLocalDatasource _local;

  OrderBloc({
    AuthLocalDatasource? auth,
    ProductLocalDatasource? local,
  })  : _auth = auth ?? AuthLocalDatasource(),
        _local = local ?? ProductLocalDatasource.instance,
        super(const OrderState.success(OrderSummary())) {
    on<_Started>(_onStarted);
    on<_Reset>(_onReset);
    on<_AddPaymentMethod>(_onAddPaymentMethod);
    on<_AddNominalBayar>(_onAddNominal);
    on<_ApplyDiscount>(_onApplyDiscount);
    on<_ClearDiscount>(_onClearDiscount);
    on<_PersistLocal>(_onPersistLocal);
  }

  OrderSummary _currentSummary() => switch (state) {
        _Success(:final summary) => summary,
        _Persisted(:final summary) => summary,
        _ => const OrderSummary(),
      };

  void _onStarted(_Started event, Emitter<OrderState> emit) {
    emit(const OrderState.success(OrderSummary()));
  }

  void _onReset(_Reset event, Emitter<OrderState> emit) {
    emit(const OrderState.success(OrderSummary()));
  }

  Future<void> _onAddPaymentMethod(
      _AddPaymentMethod event, Emitter<OrderState> emit) async {
    // Capture discount BEFORE emitting loading (which clears state).
    final existing = _currentSummary();
    final discount = existing.appliedDiscount;
    emit(const OrderState.loading());
    try {
      final auth = await _auth.getAuthData();
      var qty = 0;
      var subtotal = 0;
      for (final item in event.orders) {
        qty += item.quantity;
        subtotal += item.quantity * item.product.price;
      }
      final discountAmt =
          discount == null ? 0 : discount.amount.clamp(0, subtotal).toInt();
      emit(OrderState.success(OrderSummary(
        products: event.orders,
        totalQuantity: qty,
        totalPrice: subtotal - discountAmt,
        paymentMethod: event.paymentMethod,
        nominalBayar: 0,
        idKasir: auth.user.id,
        namaKasir: auth.user.name,
        customerName: event.customerName,
        cashSessionId: event.cashSessionId,
        appliedDiscount: discount,
      )));
    } catch (e) {
      emit(OrderState.error(e.toString()));
    }
  }

  void _onAddNominal(_AddNominalBayar event, Emitter<OrderState> emit) {
    final cur = _currentSummary();
    emit(OrderState.success(cur.copyWith(nominalBayar: event.nominal)));
  }

  void _onApplyDiscount(
      _ApplyDiscount event, Emitter<OrderState> emit) {
    // Don't clamp against `cur.subtotal` here — the bloc's summary is only
    // hydrated with products at addPaymentMethod time, so this would clamp
    // to 0 when the discount is applied from the cart page. The discount
    // amount was already computed against the real subtotal in the sheet;
    // we just store it and let _onAddPaymentMethod do the final clamp once
    // products land in the summary.
    final cur = _currentSummary();
    emit(OrderState.success(cur.copyWith(
      appliedDiscount: event.discount,
      totalPrice: (cur.subtotal - event.discount.amount).clamp(0, 1 << 31),
    )));
  }

  void _onClearDiscount(
      _ClearDiscount event, Emitter<OrderState> emit) {
    final cur = _currentSummary();
    emit(OrderState.success(cur.copyWith(
      appliedDiscount: null,
      totalPrice: cur.subtotal,
    )));
  }

  Future<void> _onPersistLocal(
      _PersistLocal event, Emitter<OrderState> emit) async {
    final summary = _currentSummary();
    if (summary.products.isEmpty) {
      emit(const OrderState.error('Tidak ada item di keranjang'));
      return;
    }
    emit(const OrderState.loading());
    try {
      // Generate idempotency key (UUID v4) untuk order baru.
      // Disimpan di local DB + dikirim ke BE saat sync. BE check duplikat
      // by client_uuid → tidak double-process kalau retry karena network blip.
      final clientUuid = const Uuid().v4();

      // Apply tax dari Receipt Settings ke total final.
      // summary.totalPrice = subtotal - discount (belum include tax).
      final taxPct = AuthLocalDatasource().getTaxPercentSync();
      final taxAmount = taxPct > 0
          ? (summary.subtotal * taxPct / 100).round()
          : 0;
      final finalTotal = summary.totalPrice + taxAmount;

      final orderModel = OrderModel(
        clientUuid: clientUuid,
        paymentMethod: summary.paymentMethod,
        nominalBayar: summary.nominalBayar,
        orders: summary.products,
        totalQuantity: summary.totalQuantity,
        totalPrice: finalTotal,
        idKasir: summary.idKasir,
        namaKasir: summary.namaKasir,
        isSync: false,
        transactionTime:
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        cashSessionId: summary.cashSessionId,
        promoId: summary.promoId,
        discountAmount: summary.discountAmount,
      );
      final localId = await _local.saveOrder(orderModel);
      emit(OrderState.persisted(localId, summary));
    } catch (e) {
      emit(OrderState.error(e.toString()));
    }
  }
}
