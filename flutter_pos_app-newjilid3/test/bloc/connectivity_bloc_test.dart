import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_pos_app/presentation/connectivity/bloc/connectivity/connectivity_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectivityBloc', () {
    blocTest<ConnectivityBloc, ConnectivityState>(
      'resultChanged([wifi]) → online from unknown',
      build: () => ConnectivityBloc(),
      seed: () => const ConnectivityState.unknown(),
      act: (b) => b.add(const ConnectivityEvent.resultChanged(
        [ConnectivityResult.wifi],
      )),
      expect: () => [const ConnectivityState.online()],
    );

    blocTest<ConnectivityBloc, ConnectivityState>(
      'resultChanged([none]) → offline from unknown',
      build: () => ConnectivityBloc(),
      seed: () => const ConnectivityState.unknown(),
      act: (b) => b.add(const ConnectivityEvent.resultChanged(
        [ConnectivityResult.none],
      )),
      expect: () => [const ConnectivityState.offline()],
    );

    blocTest<ConnectivityBloc, ConnectivityState>(
      'offline → online emits RESTORED (the side-effect trigger)',
      build: () => ConnectivityBloc(),
      seed: () => const ConnectivityState.offline(),
      act: (b) => b.add(const ConnectivityEvent.resultChanged(
        [ConnectivityResult.mobile],
      )),
      expect: () => [const ConnectivityState.restored()],
    );

    blocTest<ConnectivityBloc, ConnectivityState>(
      'online → online does NOT emit RESTORED (and state is deduped)',
      build: () => ConnectivityBloc(),
      seed: () => const ConnectivityState.online(),
      act: (b) => b.add(const ConnectivityEvent.resultChanged(
        [ConnectivityResult.wifi, ConnectivityResult.mobile],
      )),
      // flutter_bloc dedupes identical successive states, so no emission.
      expect: () => <ConnectivityState>[],
    );

    blocTest<ConnectivityBloc, ConnectivityState>(
      'empty results list treated as offline',
      build: () => ConnectivityBloc(),
      seed: () => const ConnectivityState.online(),
      act: (b) => b.add(const ConnectivityEvent.resultChanged([])),
      expect: () => [const ConnectivityState.offline()],
    );
  });
}
