import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/presentation/draft_order/bloc/draft_order/draft_order_bloc.dart';
import 'package:flutter_pos_app/presentation/order/models/draft_order_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocal extends Mock implements ProductLocalDatasource {}

void main() {
  group('DraftOrderBloc', () {
    late _MockLocal local;

    setUp(() {
      local = _MockLocal();
    });

    DraftOrderModel draft({int id = 1, String label = 'Meja 4'}) =>
        DraftOrderModel(
          id: id,
          orders: const [],
          totalQuantity: 2,
          totalPrice: 50000,
          transactionTime: '2026-05-25 14:00:00',
          tableLabel: label,
          customerName: 'Andi',
        );

    blocTest<DraftOrderBloc, DraftOrderState>(
      'getAllDraftOrder — loading then success',
      setUp: () {
        when(() => local.getAllDraftOrder())
            .thenAnswer((_) async => [draft(), draft(id: 2, label: 'Bar 2')]);
      },
      build: () => DraftOrderBloc(local),
      act: (b) => b.add(const DraftOrderEvent.getAllDraftOrder()),
      expect: () => [
        const DraftOrderState.loading(),
        isA<DraftOrderState>().having(
          (s) => s.maybeWhen(
            success: (list) => list.length,
            orElse: () => -1,
          ),
          'loaded count',
          2,
        ),
      ],
    );

    blocTest<DraftOrderBloc, DraftOrderState>(
      'getAllDraftOrder — datasource throws → error state',
      setUp: () {
        when(() => local.getAllDraftOrder()).thenThrow(Exception('db down'));
      },
      build: () => DraftOrderBloc(local),
      act: (b) => b.add(const DraftOrderEvent.getAllDraftOrder()),
      expect: () => [
        const DraftOrderState.loading(),
        isA<DraftOrderState>().having(
          (s) => s.maybeWhen(error: (m) => m, orElse: () => null),
          'has error',
          contains('db down'),
        ),
      ],
    );

    blocTest<DraftOrderBloc, DraftOrderState>(
      'removeDraft — optimistic removal + delete call',
      setUp: () {
        when(() => local.removeDraftOrderById(1)).thenAnswer((_) async {});
      },
      build: () => DraftOrderBloc(local),
      seed: () => DraftOrderState.success([draft(id: 1), draft(id: 2)]),
      act: (b) => b.add(const DraftOrderEvent.removeDraft(1)),
      expect: () => [
        isA<DraftOrderState>().having(
          (s) => s.maybeWhen(
            success: (list) => list.map((d) => d.id).toList(),
            orElse: () => null,
          ),
          'optimistic list',
          [2],
        ),
      ],
      verify: (_) {
        verify(() => local.removeDraftOrderById(1)).called(1);
      },
    );

    test('DraftOrderModel displayTableLabel — new field takes priority', () {
      final d = DraftOrderModel(
        orders: const [],
        totalQuantity: 1,
        totalPrice: 10000,
        transactionTime: '',
        tableLabel: 'Takeaway',
        tableNumber: 4,
      );
      expect(d.displayTableLabel, 'Takeaway');
    });

    test(
        'DraftOrderModel displayTableLabel — falls back to "Meja N" when only legacy int set',
        () {
      final d = DraftOrderModel(
        orders: const [],
        totalQuantity: 1,
        totalPrice: 10000,
        transactionTime: '',
        tableNumber: 7,
      );
      expect(d.displayTableLabel, 'Meja 7');
    });

    test('DraftOrderModel displayCustomerName — falls back to draft_name',
        () {
      final d = DraftOrderModel(
        orders: const [],
        totalQuantity: 1,
        totalPrice: 10000,
        transactionTime: '',
        draftName: 'Andi (legacy)',
      );
      expect(d.displayCustomerName, 'Andi (legacy)');
    });
  });
}
