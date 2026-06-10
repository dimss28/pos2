import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/data/datasources/order_remote_datasource.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/presentation/history/bloc/history/history_bloc.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocal extends Mock implements ProductLocalDatasource {}

class _MockRemote extends Mock implements OrderRemoteDatasource {}

void main() {
  group('HistoryBloc', () {
    late _MockLocal local;
    late _MockRemote remote;

    OrderModel orderAt(
      DateTime t, {
      int id = 1,
      int total = 22000,
      bool isSync = true,
    }) =>
        OrderModel(
          id: id,
          paymentMethod: 'Tunai',
          nominalBayar: total,
          orders: const [],
          totalQuantity: 1,
          totalPrice: total,
          idKasir: 1,
          namaKasir: 'Bahri',
          isSync: isSync,
          transactionTime: t.toIso8601String(),
        );

    setUp(() {
      local = _MockLocal();
      remote = _MockRemote();
      // Default: pretend BE is offline so tests stay deterministic on the
      // local-only path unless overridden.
      when(() => remote.list()).thenAnswer((_) async => left('offline'));
    });

    blocTest<HistoryBloc, HistoryState>(
      'fetch — offline BE → falls back to local, applies today filter',
      setUp: () {
        when(() => local.getAllOrder()).thenAnswer((_) async => [
              orderAt(DateTime.now(), id: 1),
              orderAt(DateTime.now().subtract(const Duration(days: 7)),
                  id: 2),
            ]);
      },
      build: () => HistoryBloc(local: local, remote: remote),
      act: (b) => b.add(const HistoryEvent.fetch()),
      expect: () => [
        const HistoryState.loading(),
        isA<HistoryState>().having(
          (s) => s.maybeWhen(
            success: (all, filtered, range, _, __) =>
                (all.length, filtered.length, range),
            orElse: () => null,
          ),
          'all=2, today filter leaves 1, range=today',
          (2, 1, HistoryDateRange.today),
        ),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'fetch — BE returns remote orders; un-synced local rows get appended',
      setUp: () {
        when(() => local.getAllOrder()).thenAnswer((_) async => [
              orderAt(DateTime.now(), id: 100, isSync: true),
              orderAt(DateTime.now(), id: 101, isSync: false), // pending push
            ]);
        when(() => remote.list()).thenAnswer((_) async => right([
              orderAt(DateTime.now(), id: 200),
              orderAt(DateTime.now(), id: 201),
            ]));
      },
      build: () => HistoryBloc(local: local, remote: remote),
      act: (b) => b.add(const HistoryEvent.fetch()),
      expect: () => [
        const HistoryState.loading(),
        isA<HistoryState>().having(
          (s) => s.maybeWhen(
            success: (all, filtered, _, __, ___) =>
                all.map((o) => o.id).toSet(),
            orElse: () => null,
          ),
          'remote ids + pending local id are present',
          {200, 201, 101},
        ),
      ],
    );

    test('applyFilter — today filter against fixed now keeps only same-day',
        () {
      final now = DateTime(2026, 5, 27, 12);
      final orders = [
        orderAt(DateTime(2026, 5, 27, 10), id: 1),
        orderAt(DateTime(2026, 5, 26, 22), id: 2),
        orderAt(DateTime(2026, 5, 27, 23, 59), id: 3),
      ];
      final filtered = HistoryBloc.applyFilter(
        orders,
        HistoryDateRange.today,
        null,
        null,
        now: now,
      );
      expect(filtered.map((o) => o.id).toList(), [1, 3]);
    });

    test('applyFilter — week (Mon-Sun) with fixed now', () {
      // Wed 27 May 2026 → week = Mon 25 → Sun 31
      final now = DateTime(2026, 5, 27, 12);
      final orders = [
        orderAt(DateTime(2026, 5, 25, 9), id: 1),
        orderAt(DateTime(2026, 5, 31, 23), id: 2),
        orderAt(DateTime(2026, 5, 24, 12), id: 3),
        orderAt(DateTime(2026, 6, 1, 0), id: 4),
      ];
      final filtered = HistoryBloc.applyFilter(
        orders,
        HistoryDateRange.week,
        null,
        null,
        now: now,
      );
      expect(filtered.map((o) => o.id).toSet(), {1, 2});
    });

    test('applyFilter — custom range inclusive of `to` end-of-day', () {
      final orders = [
        orderAt(DateTime(2026, 5, 10, 8), id: 1),
        orderAt(DateTime(2026, 5, 15, 23, 59), id: 2),
        orderAt(DateTime(2026, 5, 20, 0), id: 3),
      ];
      final filtered = HistoryBloc.applyFilter(
        orders,
        HistoryDateRange.custom,
        DateTime(2026, 5, 10),
        DateTime(2026, 5, 15),
      );
      expect(filtered.map((o) => o.id).toSet(), {1, 2});
    });

    test('groupByDay — groups orders by calendar day, sorts within group', () {
      final base = DateTime(2026, 5, 25, 10);
      final orders = [
        orderAt(base, id: 1), // 10:00
        orderAt(base.add(const Duration(hours: 5)), id: 2), // 15:00
        orderAt(base.add(const Duration(days: 1)), id: 3), // next day 10:00
      ];
      final map = HistoryBloc.groupByDay(orders);
      expect(map.length, 2);
      final dayOne = map[DateTime(2026, 5, 25)]!;
      expect(dayOne.map((o) => o.id), [2, 1]); // sorted desc by time
      expect(map[DateTime(2026, 5, 26)]!.first.id, 3);
    });

    test('sumRevenue — sums totalPrice across orders', () {
      final orders = [
        orderAt(DateTime.now(), total: 10000),
        orderAt(DateTime.now(), total: 25000),
        orderAt(DateTime.now(), total: 5000),
      ];
      expect(HistoryBloc.sumRevenue(orders), 40000);
    });
  });
}
