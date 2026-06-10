# 32 — RefundBloc + RefundSheet (Full Refund V1)

## Goal

V1 full refund: pilih alasan (dropdown) + optional catatan → BE PATCH (best-effort) + local mark refunded + restore stock + bump cash_session.cash_out. State: success / successWithRemoteWarning / error.

## Prerequisite

- Step 31 selesai.
- `ProductLocalDatasource.markOrderRefunded` (step 12) ada.
- `OrderRemoteDatasource.refund` (step 30) ada.

## Konsep yang diajarkan

- **Best-effort remote + local certainty**: BE call boleh gagal, local update tetap jalan. Sync akan reconcile nanti.
- **Controlled vocab reason** vs free text — analytics-friendly.
- **`successWithRemoteWarning` state** — beda dari pure success/error.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `ProductLocalDatasource.markOrderRefunded({localOrderId, reason, amount, note?, userId?, refundedAtIso?})` ready. `OrderRemoteDatasource.refund({orderId, reason, note?})` ready.

Generate 4 file.

═══════════════════════════════════════════════
FILE 1-3: refund_bloc/event/state
═══════════════════════════════════════════════
**refund_event.dart**:
```dart
@freezed
sealed class RefundEvent with _$RefundEvent {
  const factory RefundEvent.submit({
    required int localOrderId,
    int? serverOrderId,
    required String reason,
    required int amount,
    String? note,
  }) = _Submit;
  const factory RefundEvent.reset() = _Reset;
}
```

**refund_state.dart**:
```dart
@freezed
sealed class RefundState with _$RefundState {
  const factory RefundState.initial() = _Initial;
  const factory RefundState.loading() = _Loading;
  const factory RefundState.success() = _Success;
  /// Local OK, tapi BE gagal — sync akan reconcile.
  const factory RefundState.successWithRemoteWarning(String message) =
      _SuccessWithRemoteWarning;
  const factory RefundState.error(String message) = _Error;
}
```

**refund_bloc.dart**:
```dart
class RefundBloc extends Bloc<RefundEvent, RefundState> {
  final OrderRemoteDatasource _remote;
  final ProductLocalDatasource _local;
  final AuthLocalDatasource _auth;

  RefundBloc({OrderRemoteDatasource? remote, ProductLocalDatasource? local, AuthLocalDatasource? auth})
      : _remote = remote ?? OrderRemoteDatasource(),
        _local = local ?? ProductLocalDatasource.instance,
        _auth = auth ?? AuthLocalDatasource(),
        super(const RefundState.initial()) {
    on<_Submit>(_onSubmit);
    on<_Reset>((_, emit) => emit(const RefundState.initial()));
  }

  Future<void> _onSubmit(_Submit event, Emitter<RefundState> emit) async {
    emit(const RefundState.loading());
    try {
      final auth = await _auth.getAuthData();

      String? remoteError;
      OrderModel? refreshed;
      if (event.serverOrderId != null) {
        final r = await _remote.refund(
          orderId: event.serverOrderId!,
          reason: event.reason, note: event.note,
        );
        r.fold((msg) => remoteError = msg, (o) => refreshed = o);
      }

      await _local.markOrderRefunded(
        localOrderId: event.localOrderId,
        reason: event.reason, amount: event.amount,
        note: event.note, userId: auth.user.id,
        refundedAtIso: refreshed?.refundedAt,
      );

      if (remoteError != null && event.serverOrderId != null) {
        emit(RefundState.successWithRemoteWarning(remoteError!));
      } else {
        emit(const RefundState.success());
      }
    } catch (e) {
      emit(RefundState.error(e.toString()));
    }
  }
}
```

═══════════════════════════════════════════════
FILE 4: lib/presentation/refund/widgets/refund_sheet.dart
═══════════════════════════════════════════════
`StatefulWidget`. Field: `localOrderId, serverOrderId?, amount: int`.

State: `String _reason = 'Customer membatalkan'`, `TextEditingController _noteCtrl`.

Controlled reasons:
```dart
const _reasons = [
  'Customer membatalkan',
  'Salah pesan',
  'Barang rusak / bermasalah',
  'Stok kosong',
  'Lainnya',
];
```

Build:
- Column.stretch:
  - AppKeyValueRow(label: 'Total Refund', value: amount.currencyFormatRp, variant: big).
  - SpaceHeight 16.
  - AppSectionLabel('Alasan').
  - For each reason: InkWell radio-like → Container border `_reason == r ? primary : outline` Text r + leading Radio.
  - SpaceHeight 16.
  - AppTextField(label: 'Catatan (opsional)', hint: 'Tambahkan detail...', controller: _noteCtrl, maxLines: 3).
  - SpaceHeight 20.
  - BlocConsumer<RefundBloc>:
    - listener:
      - success → AppSnackbar.success('Refund berhasil') + Navigator.pop.
      - successWithRemoteWarning(msg) → AppSnackbar.info('Refund lokal OK, sync akan reconcile: $msg') + pop.
      - error(msg) → AppSnackbar.error(msg).
    - builder:
      - loading = state.maybeWhen(loading: () => true, orElse: () => false).
      - AppButton.danger(label: 'Konfirmasi Refund', loading, onPressed: loading ? null : () {
          context.read<RefundBloc>().add(RefundEvent.submit(
            localOrderId: localOrderId, serverOrderId: serverOrderId,
            reason: _reason, amount: amount,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          ));
        }).

═══════════════════════════════════════════════
STEP 5: Wiring
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => RefundBloc())`.
- TransactionDetailPage (step 31) → tap Refund → `showAppBottomSheet(child: RefundSheet(...))`.
````

---

## Verifikasi

1. TransactionDetailPage of order belum refunded → tap Refund.
2. Sheet muncul. Pilih alasan + (opsional) catatan → tap "Konfirmasi Refund".
3. Cek DB:
   - `orders.status` = 'refunded', `refunded_at` set, `refund_reason`, `refund_amount`.
   - `products.stock` restored (kalau order ada items).
   - `cash_sessions.cash_out` bertambah `refund_amount` (kalau order ada cash_session_id).
4. Kembali ke detail → hero banner sekarang "Order Dibatalkan (Refund)" warning.

## Talking points

1. **Best-effort BE + local certainty pattern**:
   Refund offline tetap harus jalan (kasir gak punya internet, tetap refund). BE call boleh fail → flag pending → sync reconcile.

2. **Controlled vocab reason**:
   Analytics: BI bisa group "salah pesan" vs "barang rusak". Free text = berisik.

3. **`successWithRemoteWarning` state distinct**:
   UX: snackbar info (orange/blue) bukan error (red). User tahu local berhasil tapi BE perlu dicek.

4. **Stock restoration**:
   Pakai `ProductLocalDatasource.markOrderRefunded` yang internal-nya bungkus transaction: update orders + restore stock + bump cash_session.cash_out atomik.

5. **Cash_out bump**:
   Saat tutup kasir (step 35), expected_cash = opening + cash_in - cash_out + cash_revenue. Refund = cash keluar.

## Commit suggestion

```bash
git add lib/presentation/refund/ lib/main.dart lib/presentation/history/pages/transaction_detail_page.dart
git commit -m "Step 32: RefundBloc + RefundSheet V1 full refund"
```

---

➡️ Lanjut ke [Step 33 — Cash Session Data + Bloc](./33-cash-session-data.md)
