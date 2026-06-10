part of 'delete_account_bloc.dart';

@freezed
sealed class DeleteAccountEvent with _$DeleteAccountEvent {
  const factory DeleteAccountEvent.submit() = _Submit;
}
