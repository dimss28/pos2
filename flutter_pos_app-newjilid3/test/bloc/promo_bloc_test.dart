import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/data/datasources/promo_local_datasource.dart';
import 'package:flutter_pos_app/data/datasources/promo_remote_datasource.dart';
import 'package:flutter_pos_app/data/models/response/promo_model.dart';
import 'package:flutter_pos_app/presentation/promo/bloc/promo/promo_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements PromoRemoteDatasource {}

class _MockLocal extends Mock implements PromoLocalDatasource {}

class _FakePromo extends Fake implements PromoModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePromo());
    registerFallbackValue(<PromoModel>[]);
  });

  PromoModel makePromo({
    int id = 1,
    String name = 'Happy Hour',
    PromoType type = PromoType.percent,
    int value = 20,
    bool active = true,
    String? code,
    int minSubtotal = 0,
  }) =>
      PromoModel(
        id: id,
        name: name,
        type: type,
        value: value,
        code: code,
        minSubtotal: minSubtotal,
        active: active,
      );

  group('PromoModel.computeDiscount', () {
    test('percent — 20% of 50000 = 10000', () {
      final p = makePromo(value: 20);
      expect(p.computeDiscount(50000), 10000);
    });

    test('rupiah — caps at subtotal', () {
      final p = makePromo(type: PromoType.rupiah, value: 100000);
      expect(p.computeDiscount(60000), 60000);
    });

    test('inactive promo → 0', () {
      final p = makePromo(active: false);
      expect(p.computeDiscount(50000), 0);
    });

    test('subtotal under min_subtotal → 0', () {
      final p = makePromo(minSubtotal: 100000);
      expect(p.computeDiscount(50000), 0);
    });

    test('b1g1 — server-driven, client returns 0', () {
      final p = makePromo(type: PromoType.b1g1);
      expect(p.computeDiscount(50000), 0);
    });
  });

  group('PromoBloc', () {
    late _MockRemote remote;
    late _MockLocal local;

    setUp(() {
      remote = _MockRemote();
      local = _MockLocal();
      when(() => local.upsert(any())).thenAnswer((_) async => 1);
      when(() => local.replaceAll(any())).thenAnswer((_) async {});
      when(() => local.delete(any())).thenAnswer((_) async {});
    });

    blocTest<PromoBloc, PromoState>(
      'loadFromCache — emits loading then success',
      setUp: () {
        when(() => local.getAll()).thenAnswer((_) async => [makePromo()]);
      },
      build: () => PromoBloc(remote: remote, local: local),
      act: (b) => b.add(const PromoEvent.loadFromCache()),
      expect: () => [
        const PromoState.loading(),
        isA<PromoState>().having(
          (s) => s.maybeWhen(
            success: (list) => list.length,
            orElse: () => -1,
          ),
          'cached count',
          1,
        ),
      ],
    );

    blocTest<PromoBloc, PromoState>(
      'refreshFromRemote — success pulls + mirrors to local',
      setUp: () {
        when(() => remote.list(
              activeOnly: any(named: 'activeOnly'),
              liveOnly: any(named: 'liveOnly'),
            )).thenAnswer((_) async => right([makePromo(), makePromo(id: 2)]));
      },
      build: () => PromoBloc(remote: remote, local: local),
      act: (b) => b.add(const PromoEvent.refreshFromRemote()),
      verify: (_) {
        verify(() => remote.list()).called(1);
        verify(() => local.replaceAll(any())).called(1);
      },
    );

    blocTest<PromoBloc, PromoState>(
      'refreshFromRemote — failure → error state, no local write',
      setUp: () {
        when(() => remote.list(
              activeOnly: any(named: 'activeOnly'),
              liveOnly: any(named: 'liveOnly'),
            )).thenAnswer((_) async => left('Network down'));
      },
      build: () => PromoBloc(remote: remote, local: local),
      act: (b) => b.add(const PromoEvent.refreshFromRemote()),
      expect: () => [
        const PromoState.loading(),
        const PromoState.error('Network down'),
      ],
      verify: (_) {
        verifyNever(() => local.replaceAll(any()));
      },
    );

    blocTest<PromoBloc, PromoState>(
      'toggle — optimistic flip, BE confirms',
      setUp: () {
        when(() => remote.toggle(1))
            .thenAnswer((_) async => right(makePromo(active: false)));
      },
      build: () => PromoBloc(remote: remote, local: local),
      seed: () => PromoState.success([makePromo()]),
      act: (b) => b.add(const PromoEvent.toggle(1)),
      verify: (_) => verify(() => local.upsert(any())).called(1),
    );

    blocTest<PromoBloc, PromoState>(
      'save (create) — merges new promo into list',
      setUp: () {
        when(() => remote.create(any()))
            .thenAnswer((_) async => right(makePromo(id: 99, name: 'New')));
      },
      build: () => PromoBloc(remote: remote, local: local),
      seed: () => PromoState.success([makePromo()]),
      act: (b) => b.add(PromoEvent.save(
        PromoModel(name: 'New', type: PromoType.percent, value: 10),
      )),
      expect: () => [
        isA<PromoState>().having(
          (s) => s.maybeWhen(
            success: (list) => list.map((p) => p.id).toList(),
            orElse: () => null,
          ),
          'new promo at head',
          [99, 1],
        ),
      ],
    );

    blocTest<PromoBloc, PromoState>(
      'delete — optimistic removal',
      setUp: () {
        when(() => remote.delete(1)).thenAnswer((_) async => right(null));
      },
      build: () => PromoBloc(remote: remote, local: local),
      seed: () => PromoState.success([makePromo(), makePromo(id: 2)]),
      act: (b) => b.add(const PromoEvent.delete(1)),
      expect: () => [
        isA<PromoState>().having(
          (s) => s.maybeWhen(
            success: (list) => list.map((p) => p.id).toList(),
            orElse: () => null,
          ),
          'after delete',
          [2],
        ),
      ],
    );
  });
}
