import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_pos_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/presentation/order/bloc/order/order_bloc.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:flutter_pos_app/presentation/order/models/order_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class _MockAuth extends Mock implements AuthLocalDatasource {}

class _MockLocal extends Mock implements ProductLocalDatasource {}

class _FakeOrder extends Fake implements OrderModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOrder());
  });

  group('OrderBloc', () {
    late _MockAuth auth;
    late _MockLocal local;

    setUp(() {
      auth = _MockAuth();
      local = _MockLocal();
      when(() => auth.getAuthData()).thenAnswer((_) async => authFixture());
    });

    test('initial state — empty success summary', () {
      final bloc = OrderBloc(auth: auth, local: local);
      expect(
        bloc.state,
        const OrderState.success(OrderSummary()),
      );
    });

    blocTest<OrderBloc, OrderState>(
      'addPaymentMethod — sets method + cashSessionId + computes totals from items',
      build: () => OrderBloc(auth: auth, local: local),
      act: (b) => b.add(OrderEvent.addPaymentMethod(
        paymentMethod: 'Tunai',
        orders: [orderItem(productFixture(price: 10000), qty: 2)],
        customerName: 'Walk-in',
        cashSessionId: 42,
      )),
      expect: () => [
        const OrderState.loading(),
        isA<OrderState>().having(
          (s) => s.maybeWhen(
            success: (sum) => (
              sum.totalQuantity,
              sum.totalPrice,
              sum.paymentMethod,
              sum.cashSessionId,
              sum.namaKasir,
            ),
            orElse: () => null,
          ),
          'computed summary',
          (2, 20000, 'Tunai', 42, 'Bahri'),
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'addNominalBayar — updates received cash, preserves rest of summary',
      build: () => OrderBloc(auth: auth, local: local),
      seed: () => OrderState.success(OrderSummary(
        products: [orderItem(productFixture(price: 22000), qty: 1)],
        totalQuantity: 1,
        totalPrice: 22000,
        paymentMethod: 'Tunai',
        idKasir: 1,
        namaKasir: 'Bahri',
        cashSessionId: 42,
      )),
      act: (b) => b.add(const OrderEvent.addNominalBayar(50000)),
      expect: () => [
        isA<OrderState>().having(
          (s) => s.maybeWhen(
            success: (sum) => (
              sum.nominalBayar,
              sum.change,
              sum.paymentMethod,
              sum.cashSessionId,
            ),
            orElse: () => null,
          ),
          'preserves summary',
          (50000, 28000, 'Tunai', 42),
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'persistLocal — saves order with cashSessionId, emits persisted',
      setUp: () {
        when(() => local.saveOrder(any())).thenAnswer((_) async => 77);
      },
      build: () => OrderBloc(auth: auth, local: local),
      seed: () => OrderState.success(OrderSummary(
        products: [orderItem(productFixture(price: 22000), qty: 1)],
        totalQuantity: 1,
        totalPrice: 22000,
        paymentMethod: 'Tunai',
        nominalBayar: 50000,
        idKasir: 1,
        namaKasir: 'Bahri',
        cashSessionId: 42,
      )),
      act: (b) => b.add(const OrderEvent.persistLocal()),
      expect: () => [
        const OrderState.loading(),
        isA<OrderState>().having(
          (s) => s.maybeWhen(
            persisted: (localId, sum) => (localId, sum.cashSessionId),
            orElse: () => null,
          ),
          'persisted local id + session',
          (77, 42),
        ),
      ],
      verify: (_) {
        final captured =
            verify(() => local.saveOrder(captureAny())).captured.single
                as OrderModel;
        expect(captured.cashSessionId, 42);
        expect(captured.paymentMethod, 'Tunai');
        expect(captured.totalPrice, 22000);
        expect(captured.nominalBayar, 50000);
        expect(captured.isSync, false);
      },
    );

    blocTest<OrderBloc, OrderState>(
      'persistLocal with empty cart — emits error, no datasource call',
      build: () => OrderBloc(auth: auth, local: local),
      seed: () => const OrderState.success(OrderSummary()),
      act: (b) => b.add(const OrderEvent.persistLocal()),
      expect: () => [
        isA<OrderState>().having(
          (s) => s.maybeWhen(error: (m) => m, orElse: () => null),
          'error message present',
          contains('keranjang'),
        ),
      ],
      verify: (_) => verifyNever(() => local.saveOrder(any())),
    );

    blocTest<OrderBloc, OrderState>(
      'reset — returns to empty summary',
      build: () => OrderBloc(auth: auth, local: local),
      seed: () => OrderState.success(OrderSummary(
        products: [orderItem(productFixture(), qty: 1)],
        totalQuantity: 1,
        totalPrice: 22000,
        paymentMethod: 'Tunai',
      )),
      act: (b) => b.add(const OrderEvent.reset()),
      expect: () => [
        const OrderState.success(OrderSummary()),
      ],
    );

    test('OrderSummary.change — computed correctly', () {
      const sum = OrderSummary(totalPrice: 22000, nominalBayar: 50000);
      expect(sum.change, 28000);
      const underpaid = OrderSummary(totalPrice: 22000, nominalBayar: 20000);
      expect(underpaid.change, -2000);
    });
  });
}
