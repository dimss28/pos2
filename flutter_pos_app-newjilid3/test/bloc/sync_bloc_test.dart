import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/data/datasources/order_remote_datasource.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/data/datasources/product_remote_datasource.dart';
import 'package:flutter_pos_app/data/datasources/promo_local_datasource.dart';
import 'package:flutter_pos_app/data/datasources/promo_remote_datasource.dart';
import 'package:flutter_pos_app/data/models/request/order_request_model.dart';
import 'package:flutter_pos_app/data/models/response/category_response_model.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:flutter_pos_app/presentation/setting/bloc/sync/sync_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fixtures.dart';

class _MockProductRemote extends Mock implements ProductRemoteDatasource {}

class _MockOrderRemote extends Mock implements OrderRemoteDatasource {}

class _MockLocal extends Mock implements ProductLocalDatasource {}

class _MockPromoRemote extends Mock implements PromoRemoteDatasource {}

class _MockPromoLocal extends Mock implements PromoLocalDatasource {}

class _FakeOrderReq extends Fake implements OrderRequestModel {}

class _FakeProduct extends Fake implements Product {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOrderReq());
    registerFallbackValue(_FakeProduct());
  });

  group('SyncBloc', () {
    late _MockProductRemote productRemote;
    late _MockOrderRemote orderRemote;
    late _MockLocal local;
    late _MockPromoRemote promoRemote;
    late _MockPromoLocal promoLocal;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      productRemote = _MockProductRemote();
      orderRemote = _MockOrderRemote();
      local = _MockLocal();
      promoRemote = _MockPromoRemote();
      promoLocal = _MockPromoLocal();

      // Default empty local DB
      when(() => local.getAllProduct()).thenAnswer((_) async => []);
      when(() => local.getAllCategories()).thenAnswer((_) async => []);
      when(() => local.getOrderByIsSync()).thenAnswer((_) async => []);
      when(() => promoLocal.getAll()).thenAnswer((_) async => []);
    });

    blocTest<SyncBloc, SyncState>(
      'refreshSnapshot — reads counts from local',
      setUp: () {
        when(() => local.getAllProduct())
            .thenAnswer((_) async => [productFixture()]);
        when(() => local.getAllCategories()).thenAnswer((_) async => [
              Category(id: 1, name: 'Kopi'),
            ]);
        when(() => local.getOrderByIsSync()).thenAnswer((_) async => [
              OrderModel(
                paymentMethod: 'Tunai',
                nominalBayar: 22000,
                orders: const [],
                totalQuantity: 1,
                totalPrice: 22000,
                idKasir: 1,
                namaKasir: 'Bahri',
                isSync: false,
                transactionTime: '2026-05-25 14:00:00',
              ),
            ]);
      },
      build: () => SyncBloc(
        productRemote: productRemote,
        orderRemote: orderRemote,
        local: local,
        promoRemote: promoRemote,
        promoLocal: promoLocal,
      ),
      act: (b) => b.add(const SyncEvent.refreshSnapshot()),
      expect: () => [
        isA<SyncState>().having(
          (s) => s.maybeWhen(
            ready: (snap) =>
                (snap.productCount, snap.categoryCount, snap.pendingOrderCount),
            orElse: () => null,
          ),
          'counts',
          (1, 1, 1),
        ),
      ],
    );

    blocTest<SyncBloc, SyncState>(
      'pullProducts — fetches remote, replaces local, stamps last_sync',
      setUp: () {
        when(() => productRemote.getProducts()).thenAnswer(
          (_) async => right(ProductResponseModel(
            success: true,
            message: 'ok',
            data: [productFixture()],
          )),
        );
        when(() => local.removeAllProduct()).thenAnswer((_) async {});
        when(() => local.insertAllProduct(any())).thenAnswer((_) async {});
      },
      build: () => SyncBloc(
        productRemote: productRemote,
        orderRemote: orderRemote,
        local: local,
        promoRemote: promoRemote,
        promoLocal: promoLocal,
      ),
      act: (b) => b.add(const SyncEvent.pullProducts()),
      verify: (_) {
        verify(() => local.removeAllProduct()).called(1);
        verify(() => local.insertAllProduct(any())).called(1);
        verify(() => productRemote.getProducts()).called(1);
      },
    );

    blocTest<SyncBloc, SyncState>(
      'pullProducts — remote failure → captures error, no local wipe',
      setUp: () {
        when(() => productRemote.getProducts())
            .thenAnswer((_) async => left('500 Server Error'));
      },
      build: () => SyncBloc(
        productRemote: productRemote,
        orderRemote: orderRemote,
        local: local,
        promoRemote: promoRemote,
        promoLocal: promoLocal,
      ),
      act: (b) => b.add(const SyncEvent.pullProducts()),
      verify: (_) {
        verifyNever(() => local.removeAllProduct());
        verifyNever(() => local.insertAllProduct(any()));
      },
    );

    blocTest<SyncBloc, SyncState>(
      'pushOrders — pushes pending, marks synced',
      setUp: () {
        when(() => local.getOrderByIsSync()).thenAnswer((_) async => [
              OrderModel(
                id: 11,
                paymentMethod: 'Tunai',
                nominalBayar: 22000,
                orders: const [],
                totalQuantity: 1,
                totalPrice: 22000,
                idKasir: 1,
                namaKasir: 'Bahri',
                isSync: false,
                transactionTime: '2026-05-25 14:00:00',
              ),
            ]);
        when(() => local.getOrderItemByOrderIdLocal(any()))
            .thenAnswer((_) async => []);
        when(() => orderRemote.sendOrder(any())).thenAnswer((_) async => true);
        when(() => local.updateIsSyncOrderById(any()))
            .thenAnswer((_) async => 1);
      },
      build: () => SyncBloc(
        productRemote: productRemote,
        orderRemote: orderRemote,
        local: local,
        promoRemote: promoRemote,
        promoLocal: promoLocal,
      ),
      act: (b) => b.add(const SyncEvent.pushOrders()),
      verify: (_) {
        verify(() => orderRemote.sendOrder(any())).called(1);
        verify(() => local.updateIsSyncOrderById(11)).called(1);
      },
    );

    blocTest<SyncBloc, SyncState>(
      'pushOrders — partial failure → no markSynced for failed, error recorded',
      setUp: () {
        when(() => local.getOrderByIsSync()).thenAnswer((_) async => [
              OrderModel(
                id: 22,
                paymentMethod: 'QRIS',
                nominalBayar: 50000,
                orders: const [],
                totalQuantity: 1,
                totalPrice: 50000,
                idKasir: 1,
                namaKasir: 'Bahri',
                isSync: false,
                transactionTime: '2026-05-25 14:00:00',
              ),
            ]);
        when(() => local.getOrderItemByOrderIdLocal(any()))
            .thenAnswer((_) async => []);
        when(() => orderRemote.sendOrder(any()))
            .thenAnswer((_) async => false);
      },
      build: () => SyncBloc(
        productRemote: productRemote,
        orderRemote: orderRemote,
        local: local,
        promoRemote: promoRemote,
        promoLocal: promoLocal,
      ),
      act: (b) => b.add(const SyncEvent.pushOrders()),
      verify: (_) {
        verifyNever(() => local.updateIsSyncOrderById(any()));
      },
      expect: () => [
        isA<SyncState>().having(
          (s) => s.maybeWhen(
              ready: (snap) => snap.inProgress, orElse: () => null),
          'in progress while running',
          'orders',
        ),
        isA<SyncState>().having(
          (s) => s.maybeWhen(
              ready: (snap) => snap.errors['orders'], orElse: () => null),
          'error captured for orders domain',
          contains('gagal'),
        ),
      ],
    );
  });
}
