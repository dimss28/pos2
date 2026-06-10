import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/auth_remote_datasource.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';
part 'delete_account_bloc.freezed.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final AuthRemoteDatasource _remote;

  DeleteAccountBloc(this._remote) : super(const DeleteAccountState.initial()) {
    on<_Submit>(_onSubmit);
  }

  Future<void> _onSubmit(
    _Submit event,
    Emitter<DeleteAccountState> emit,
  ) async {
    emit(const DeleteAccountState.loading());
    final result = await _remote.deleteAccount();
    result.fold(
      (l) => emit(DeleteAccountState.error(l)),
      (_) => emit(const DeleteAccountState.success()),
    );
  }
}
