import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:flutter_pos_app/presentation/home/models/checkout_summary.dart';
import 'package:flutter_pos_app/presentation/order/models/draft_order_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class _MockLocal extends Mock implements ProductLocalDatasource {}

class _FakeDraft extends Fake implements DraftOrderModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeDraft());
  });

  group('CheckoutBloc', () {
    late _MockLocal local;

    setUp(() {
      local = _MockLocal();
    });

    test('initial state is success with empty cart', () {
      final bloc = CheckoutBloc(local: local);
      expect(
        bloc.state,
        const CheckoutState.success(CheckoutSummary()),
      );
    });

    blocTest<CheckoutBloc, CheckoutState>(
      'addCheckout — adds product with qty=1 and totals',
      build: () => CheckoutBloc(local: local),
      act: (b) => b.add(CheckoutEvent.addCheckout(productFixture())),
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.maybeWhen(
            success: (sum) => (sum.totalQuantity, sum.totalPrice, sum.products.length),
            orElse: () => (-1, -1, -1),
          ),
          'success summary',
          (1, 22000, 1),
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'addCheckout twice for same product — increments qty, not list size',
      build: () => CheckoutBloc(local: local),
      act: (b) {
        final p = productFixture();
        b.add(CheckoutEvent.addCheckout(p));
        b.add(CheckoutEvent.addCheckout(p));
      },
      skip: 1,
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.maybeWhen(
            success: (sum) => (sum.totalQuantity, sum.totalPrice, sum.products.length),
            orElse: () => (-1, -1, -1),
          ),
          'success summary',
          (2, 44000, 1),
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'removeCheckout — decrements qty above 1',
      build: () => CheckoutBloc(local: local),
      seed: () => CheckoutState.success(CheckoutSummary(
        products: [orderItem(productFixture(), qty: 3)],
        totalQuantity: 3,
        totalPrice: 66000,
      )),
      act: (b) => b.add(CheckoutEvent.removeCheckout(productFixture())),
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.maybeWhen(
            success: (sum) => (sum.totalQuantity, sum.totalPrice),
            orElse: () => (-1, -1),
          ),
          'totals',
          (2, 44000),
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'removeCheckout — drops item when qty hits 0',
      build: () => CheckoutBloc(local: local),
      seed: () => CheckoutState.success(CheckoutSummary(
        products: [orderItem(productFixture(), qty: 1)],
        totalQuantity: 1,
        totalPrice: 22000,
      )),
      act: (b) => b.add(CheckoutEvent.removeCheckout(productFixture())),
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.maybeWhen(
            success: (sum) =>
                (sum.totalQuantity, sum.totalPrice, sum.products.length),
            orElse: () => (-1, -1, -1),
          ),
          'totals',
          (0, 0, 0),
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'removeProduct — drops item regardless of qty',
      build: () => CheckoutBloc(local: local),
      seed: () => CheckoutState.success(CheckoutSummary(
        products: [orderItem(productFixture(), qty: 5)],
        totalQuantity: 5,
        totalPrice: 110000,
      )),
      act: (b) => b.add(CheckoutEvent.removeProduct(productFixture())),
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.maybeWhen(
            success: (sum) => sum.products.length,
            orElse: () => -1,
          ),
          'no products left',
          0,
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'started — clears cart back to empty',
      build: () => CheckoutBloc(local: local),
      seed: () => CheckoutState.success(CheckoutSummary(
        products: [orderItem(productFixture(), qty: 2)],
        totalQuantity: 2,
        totalPrice: 44000,
      )),
      act: (b) => b.add(const CheckoutEvent.started()),
      expect: () => [
        const CheckoutState.success(CheckoutSummary()),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'saveDraftOrder — calls datasource, emits savedDraftOrder',
      setUp: () {
        when(() => local.saveDraftOrder(any()))
            .thenAnswer((_) async => 99);
      },
      build: () => CheckoutBloc(local: local),
      seed: () => CheckoutState.success(CheckoutSummary(
        products: [orderItem(productFixture(), qty: 2)],
        totalQuantity: 2,
        totalPrice: 44000,
      )),
      act: (b) => b.add(const CheckoutEvent.saveDraftOrder(
        tableLabel: 'Meja 4',
        customerName: 'Andi',
        tableNumber: 4,
      )),
      expect: () => [
        const CheckoutState.savedDraftOrder(),
      ],
      verify: (_) => verify(() => local.saveDraftOrder(any())).called(1),
    );

    test('CheckoutSummary.totalsOf — sums qty * price across items', () {
      final p1 = productFixture(id: 1, price: 10000);
      final p2 = productFixture(id: 2, price: 5000);
      final items = [orderItem(p1, qty: 2), orderItem(p2, qty: 3)];
      final (qty, price) = CheckoutSummary.totalsOf(items);
      expect(qty, 5);
      expect(price, 35000);
    });
  });
}
