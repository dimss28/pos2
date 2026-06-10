import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/promo_local_datasource.dart';
import '../../../../data/datasources/promo_remote_datasource.dart';
import '../../../../data/models/response/promo_model.dart';

part 'promo_bloc.freezed.dart';
part 'promo_event.dart';
part 'promo_state.dart';

/// Owns the promo catalog state.
///
/// **Remote-first** for create/toggle/delete (must round-trip to BE so a
/// staff phone doesn't fork the catalog). **Local-first** for `loaded` so
/// the cashier can browse promos offline once the bootstrap sync ran.
class PromoBloc extends Bloc<PromoEvent, PromoState> {
  final PromoRemoteDatasource _remote;
  final PromoLocalDatasource _local;

  PromoBloc({
    PromoRemoteDatasource? remote,
    PromoLocalDatasource? local,
  })  : _remote = remote ?? PromoRemoteDatasource(),
        _local = local ?? PromoLocalDatasource.instance,
        super(const PromoState.initial()) {
    on<_LoadFromCache>(_onLoadFromCache);
    on<_RefreshFromRemote>(_onRefresh);
    on<_Toggle>(_onToggle);
    on<_Save>(_onSave);
    on<_Delete>(_onDelete);
  }

  Future<void> _onLoadFromCache(
      _LoadFromCache event, Emitter<PromoState> emit) async {
    emit(const PromoState.loading());
    try {
      final list = await _local.getAll();
      emit(PromoState.success(list));
    } catch (e) {
      emit(PromoState.error(e.toString()));
    }
  }

  Future<void> _onRefresh(
      _RefreshFromRemote event, Emitter<PromoState> emit) async {
    emit(const PromoState.loading());
    final result = await _remote.list();
    await result.fold(
      (msg) async {
        emit(PromoState.error(msg));
      },
      (remote) async {
        await _local.replaceAll(remote);
        emit(PromoState.success(remote));
      },
    );
  }

  Future<void> _onToggle(_Toggle event, Emitter<PromoState> emit) async {
    final current = state.maybeWhen(
      success: (list) => list,
      orElse: () => <PromoModel>[],
    );
    // Optimistic flip.
    final optimistic = current
        .map((p) =>
            p.id == event.id ? p.copyWith(active: !p.active) : p)
        .toList();
    emit(PromoState.success(optimistic));

    final result = await _remote.toggle(event.id);
    await result.fold(
      (msg) async {
        // Roll back on failure.
        emit(PromoState.success(current));
        emit(PromoState.error(msg));
        emit(PromoState.success(current));
      },
      (saved) async {
        await _local.upsert(saved);
        final synced = optimistic
            .map((p) => p.id == saved.id ? saved : p)
            .toList();
        emit(PromoState.success(synced));
      },
    );
  }

  Future<void> _onSave(_Save event, Emitter<PromoState> emit) async {
    final result = event.promo.id == null
        ? await _remote.create(event.promo)
        : await _remote.update(event.promo);
    await result.fold(
      (msg) async => emit(PromoState.error(msg)),
      (saved) async {
        await _local.upsert(saved);
        final current = state.maybeWhen(
          success: (list) => list,
          orElse: () => <PromoModel>[],
        );
        final exists = current.any((p) => p.id == saved.id);
        final merged = exists
            ? current.map((p) => p.id == saved.id ? saved : p).toList()
            : [saved, ...current];
        emit(PromoState.success(merged));
      },
    );
  }

  Future<void> _onDelete(_Delete event, Emitter<PromoState> emit) async {
    final current = state.maybeWhen(
      success: (list) => list,
      orElse: () => <PromoModel>[],
    );
    // Optimistic removal.
    emit(PromoState.success(
      current.where((p) => p.id != event.id).toList(),
    ));
    final result = await _remote.delete(event.id);
    await result.fold(
      (msg) async {
        emit(PromoState.success(current));
        emit(PromoState.error(msg));
        emit(PromoState.success(current));
      },
      (_) async => _local.delete(event.id),
    );
  }
}
