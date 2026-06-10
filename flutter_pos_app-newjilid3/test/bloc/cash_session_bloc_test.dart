import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/data/datasources/cash_session_local_datasource.dart';
import 'package:flutter_pos_app/data/datasources/cash_session_remote_datasource.dart';
import 'package:flutter_pos_app/data/models/response/cash_session_model.dart';
import 'package:flutter_pos_app/presentation/cash_session/bloc/cash_session/cash_session_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class _MockRemote extends Mock implements CashSessionRemoteDatasource {}

class _MockLocal extends Mock implements CashSessionLocalDatasource {}

class _FakeSession extends Fake implements CashSessionModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSession());
  });

  group('CashSessionBloc', () {
    late _MockRemote remote;
    late _MockLocal local;

    setUp(() {
      remote = _MockRemote();
      local = _MockLocal();
      when(() => local.upsertFromRemote(any())).thenAnswer((_) async {});
      when(() => local.getLastClosed()).thenAnswer((_) async => null);
    });

    blocTest<CashSessionBloc, CashSessionState>(
      'loaded — open session found → emits open(session)',
      setUp: () {
        when(() => remote.getCurrent())
            .thenAnswer((_) async => right(openSessionFixture()));
      },
      build: () => CashSessionBloc(remote: remote, local: local),
      act: (b) => b.add(const CashSessionEvent.loaded()),
      expect: () => [
        const CashSessionState.loading(),
        isA<CashSessionState>().having(
          (s) => s.maybeWhen(
            open: (sess) => sess.id,
            orElse: () => null,
          ),
          'open session id',
          42,
        ),
      ],
      verify: (_) {
        verify(() => remote.getCurrent()).called(1);
        verify(() => local.upsertFromRemote(any())).called(1);
      },
    );

    blocTest<CashSessionBloc, CashSessionState>(
      'loaded — no open session → emits noSession(lastClosed)',
      setUp: () {
        when(() => remote.getCurrent()).thenAnswer((_) async => right(null));
      },
      build: () => CashSessionBloc(remote: remote, local: local),
      act: (b) => b.add(const CashSessionEvent.loaded()),
      expect: () => [
        const CashSessionState.loading(),
        isA<CashSessionState>().having(
          (s) => s.maybeWhen(
            noSession: (last) => last,
            orElse: () => 'wrong',
          ),
          'noSession',
          isNull,
        ),
      ],
    );

    blocTest<CashSessionBloc, CashSessionState>(
      'loaded — backend error → emits error',
      setUp: () {
        when(() => remote.getCurrent())
            .thenAnswer((_) async => left('Network down'));
      },
      build: () => CashSessionBloc(remote: remote, local: local),
      act: (b) => b.add(const CashSessionEvent.loaded()),
      expect: () => [
        const CashSessionState.loading(),
        const CashSessionState.error('Network down'),
      ],
    );

    blocTest<CashSessionBloc, CashSessionState>(
      'open — success → emits open(session) and mirrors local',
      setUp: () {
        when(() => remote.open(
              shiftLabel: any(named: 'shiftLabel'),
              openingFloat: any(named: 'openingFloat'),
              openingNote: any(named: 'openingNote'),
            )).thenAnswer((_) async => right(openSessionFixture()));
      },
      build: () => CashSessionBloc(remote: remote, local: local),
      act: (b) => b.add(const CashSessionEvent.open(
        shiftLabel: 'Siang',
        openingFloat: 200000,
      )),
      expect: () => [
        const CashSessionState.loading(),
        isA<CashSessionState>().having(
          (s) => s.maybeWhen(open: (sess) => sess.id, orElse: () => null),
          'open id',
          42,
        ),
      ],
      verify: (_) => verify(() => local.upsertFromRemote(any())).called(1),
    );

    blocTest<CashSessionBloc, CashSessionState>(
      'open — BE rejects (409 already open) → emits error',
      setUp: () {
        when(() => remote.open(
              shiftLabel: any(named: 'shiftLabel'),
              openingFloat: any(named: 'openingFloat'),
              openingNote: any(named: 'openingNote'),
            )).thenAnswer(
                (_) async => left('Masih ada shift aktif. Tutup shift sebelumnya dulu.'));
      },
      build: () => CashSessionBloc(remote: remote, local: local),
      act: (b) => b.add(const CashSessionEvent.open(
        shiftLabel: 'Siang',
        openingFloat: 200000,
      )),
      expect: () => [
        const CashSessionState.loading(),
        const CashSessionState.error(
            'Masih ada shift aktif. Tutup shift sebelumnya dulu.'),
      ],
    );

    blocTest<CashSessionBloc, CashSessionState>(
      'close — no open session → error',
      build: () => CashSessionBloc(remote: remote, local: local),
      act: (b) => b.add(const CashSessionEvent.close(physicalCount: 100000)),
      expect: () => [
        const CashSessionState.error('Tidak ada shift yang aktif'),
      ],
    );

    blocTest<CashSessionBloc, CashSessionState>(
      'close — success → emits noSession(closedSession)',
      setUp: () {
        final closed = openSessionFixture().copyWith(
          physicalCount: 779000,
          expectedCash: 779000,
          variance: 0,
          closedAt: DateTime(2026, 5, 25, 22),
        );
        when(() => remote.close(
              sessionId: any(named: 'sessionId'),
              physicalCount: any(named: 'physicalCount'),
              cashIn: any(named: 'cashIn'),
              cashOut: any(named: 'cashOut'),
              closingNote: any(named: 'closingNote'),
            )).thenAnswer((_) async => right(closed));
      },
      build: () => CashSessionBloc(remote: remote, local: local),
      seed: () => CashSessionState.open(openSessionFixture()),
      act: (b) =>
          b.add(const CashSessionEvent.close(physicalCount: 779000)),
      expect: () => [
        const CashSessionState.loading(),
        isA<CashSessionState>().having(
          (s) => s.maybeWhen(
            noSession: (last) => (last?.variance, last?.physicalCount),
            orElse: () => null,
          ),
          'closed shift',
          (0, 779000),
        ),
      ],
    );
  });
}
