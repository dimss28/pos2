# 28 — PaymentQRISSheet (Midtrans) + QrisBloc + MidtransRemoteDatasource

## Goal

Bayar QRIS via Midtrans: `MidtransRemoteDatasource.generateQRCode` (POST /v2/charge) + `checkPaymentStatus` (GET /v2/{orderId}/status). `QrisBloc` orchestration. `PaymentQRISSheet` render QR, polling status, "Cek Status" manual, success → PaymentSuccessSheet.

## Prerequisite

- Step 27 selesai.
- `AuthLocalDatasource.getMitransServerKey/isMidtransEnabled` ada (step 13).

## Konsep yang diajarkan

- **Basic Auth** dengan server key Midtrans (base64 encode "key:").
- **Polling** dengan `Timer.periodic` untuk cek status.
- **2 model response**: QrisResponseModel (qr_string + actions), QrisStatusResponseModel (transaction_status).
- **Sandbox vs Production endpoint** — production = `api.midtrans.com`, sandbox = `api.sandbox.midtrans.com`.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `AuthLocalDatasource.getMitransServerKey()` ada.

Generate 6 file.

═══════════════════════════════════════════════
FILE 1: lib/data/models/response/qris_response_model.dart
═══════════════════════════════════════════════
`QrisResponseModel` (handwritten DTO):
- Field: `statusCode, statusMessage, transactionId, orderId, grossAmount, currency, paymentType, transactionTime, transactionStatus, fraudStatus, qrString, actions, expiryTime`.
- `Action { name, method, url }` di-list.
- fromMap/toMap/fromJson/toJson standar dengan defensive parsing.

═══════════════════════════════════════════════
FILE 2: lib/data/models/response/qris_status_response_model.dart
═══════════════════════════════════════════════
`QrisStatusResponseModel`:
- Field: `transactionTime, grossAmount, paymentType, signatureKey, statusCode, transactionId, transactionStatus, fraudStatus, statusMessage, merchantId, currency, orderId`.
- fromMap/toMap.

═══════════════════════════════════════════════
FILE 3: lib/data/datasources/midtrans_remote_datasource.dart
═══════════════════════════════════════════════
```dart
import 'dart:convert';
import 'package:flutter_pos_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos_app/data/models/response/qris_response_model.dart';
import 'package:flutter_pos_app/data/models/response/qris_status_response_model.dart';
import 'package:http/http.dart' as http;

class MidtransRemoteDatasource {
  String _basicAuth(String serverKey) =>
      'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

  /// POST /v2/charge dengan payment_type=gopay (QRIS).
  Future<QrisResponseModel> generateQRCode(
      String orderId, int grossAmount) async {
    final serverKey = await AuthLocalDatasource().getMitransServerKey();
    final response = await http.post(
      Uri.parse('https://api.midtrans.com/v2/charge'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _basicAuth(serverKey),
      },
      body: jsonEncode({
        'payment_type': 'gopay',
        'transaction_details': {
          'gross_amount': grossAmount,
          'order_id': orderId,
        },
      }),
    );
    if (response.statusCode == 200) {
      return QrisResponseModel.fromJson(response.body);
    }
    throw Exception('Failed to generate QR Code: ${response.body}');
  }

  Future<QrisStatusResponseModel> checkPaymentStatus(String orderId) async {
    final serverKey = await AuthLocalDatasource().getMitransServerKey();
    final response = await http.get(
      Uri.parse('https://api.midtrans.com/v2/$orderId/status'),
      headers: {
        'Authorization': _basicAuth(serverKey),
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return QrisStatusResponseModel.fromJson(response.body);
    }
    throw Exception('Failed to check status: ${response.body}');
  }
}
```

═══════════════════════════════════════════════
FILE 4-6: QrisBloc + event + state
═══════════════════════════════════════════════
**qris_bloc.dart**:
```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pos_app/data/datasources/midtrans_remote_datasource.dart';

import '../../../../data/models/response/qris_response_model.dart';

part 'qris_bloc.freezed.dart';
part 'qris_event.dart';
part 'qris_state.dart';

class QrisBloc extends Bloc<QrisEvent, QrisState> {
  final MidtransRemoteDatasource midtransRemoteDatasource;
  QrisBloc(this.midtransRemoteDatasource) : super(const _Initial()) {
    on<_GenerateQRCode>((event, emit) async {
      emit(const QrisState.loading());
      try {
        final response = await midtransRemoteDatasource.generateQRCode(
            event.orderId, event.grossAmount);
        emit(QrisState.qrisResponse(response));
      } catch (e) {
        emit(QrisState.error(e.toString()));
      }
    });

    on<_CheckPaymentStatus>((event, emit) async {
      try {
        final response = await midtransRemoteDatasource.checkPaymentStatus(event.orderId);
        if (response.transactionStatus == 'settlement') {
          emit(const QrisState.success('Pembayaran Berhasil'));
        }
      } catch (_) {}
    });
  }
}
```

**qris_event.dart**:
```dart
@freezed
class QrisEvent with _$QrisEvent {
  const factory QrisEvent.started() = _Started;
  const factory QrisEvent.generateQRCode(String orderId, int grossAmount) = _GenerateQRCode;
  const factory QrisEvent.checkPaymentStatus(String orderId) = _CheckPaymentStatus;
}
```

**qris_state.dart**:
```dart
@freezed
class QrisState with _$QrisState {
  const factory QrisState.initial() = _Initial;
  const factory QrisState.loading() = _Loading;
  const factory QrisState.qrisResponse(QrisResponseModel response) = _QrisResponse;
  const factory QrisState.success(String message) = _Success;
  const factory QrisState.error(String message) = _Error;
}
```

═══════════════════════════════════════════════
FILE 7: lib/presentation/order/widgets/payment_qris_sheet.dart
═══════════════════════════════════════════════
`StatefulWidget` dengan `CheckoutSummary cart`, `void Function() onSuccess`. State:
- `_orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}'`
- `Timer? _pollTimer` — poll 5s sekali.
- `int _remaining = 300` (5 menit countdown).
- `Timer? _countdownTimer`.

initState:
- `context.read<QrisBloc>().add(QrisEvent.generateQRCode(_orderId, cart.totalPrice))`.
- Start `_pollTimer = Timer.periodic(5s, (_) => bloc.add(checkPaymentStatus(_orderId)))`.
- Start `_countdownTimer = Timer.periodic(1s, (_) => setState(--_remaining))`.

dispose: cancel kedua timer.

Build:
- `BlocConsumer<QrisBloc, QrisState>`:
  - listener: success → cancel timers, pop sheet, `widget.onSuccess()`.
  - builder:
    - Pakai `state.maybeWhen`:
      - loading/initial → CircularProgressIndicator + Text 'Generating QR...'.
      - error(msg) → Text error + button "Retry".
      - qrisResponse(r) → Column:
        - `AppStatusPill(label: 'MENUNGGU', kind: warning, showDot: true, pulse: true)`.
        - SpaceHeight 12.
        - Text 'QR berlaku ${(_remaining / 60).floor()}m ${_remaining % 60}d lagi' (bodyS).
        - SpaceHeight 16.
        - **`AppQrView(data: r.qrString, size: 240)`**.
        - SpaceHeight 16.
        - `AppKeyValueRow(label: 'Total', value: cart.totalPrice.currencyFormatRp, variant: big)`.
        - SpaceHeight 20.
        - Row: AppButton.outline(label: 'Batal', onPressed: pop), SpaceWidth 12, Expanded AppButton.primary(label: 'Cek Status Manual', onPressed: () => bloc.add(checkPaymentStatus(_orderId))).

═══════════════════════════════════════════════
STEP 8: Wiring
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => QrisBloc(MidtransRemoteDatasource()))`.
- OrderPage `_onPayTap`: kalau `_paymentMethod == 'qris'`:
  ```dart
  showAppBottomSheet(
    context: context,
    title: 'Bayar dengan QRIS',
    isDismissible: false,
    child: PaymentQRISSheet(
      cart: cart,
      onSuccess: () {
        context.read<OrderBloc>().add(OrderEvent.addPaymentMethod(
          paymentMethod: 'qris', orders: cart.products,
          customerName: cart.linkedCustomerName ?? '', cashSessionId: null,
        ));
        context.read<OrderBloc>().add(const OrderEvent.persistLocal());
      },
    ),
  );
  ```
````

---

## Verifikasi

1. Pastikan server key QRIS sudah di-save di SaveServerKeyPage (step 39 nanti). Sementara hardcode test:
   ```dart
   AuthLocalDatasource().saveMidtransServerKey('SB-Mid-server-XYZ');
   ```
2. Cart isi → QRIS → tap "Bayar" → sheet generate QR.
3. Scan QR pakai GoPay/Dana sandbox → status berubah → sheet auto close → PaymentSuccessSheet.
4. Tap "Cek Status Manual" sebelum bayar → no-op (status pending).

## Talking points

1. **Polling vs webhook**:
   Production setup proper: BE listen Midtrans webhook → push ke FE via WebSocket / push notification. Kita pakai polling karena simpler untuk POS app yang user-visible (kasir nungguin layar).

2. **`'payment_type': 'gopay'`** tapi tampil QRIS:
   Midtrans v2 routes QRIS lewat tipe 'gopay' (legacy naming). Production resmi sekarang punya 'qris' juga. Cek doc Midtrans.

3. **5-menit countdown**:
   QR Midtrans biasanya expire 15 menit. Kita pakai 5 menit UX-wise: kasir gak mau nunggu lama, kalau gagal generate ulang lebih cepat.

4. **Server key di-store di lokal user**:
   Tiap merchant punya server key beda. Tidak di-hardcode di app. User input di Settings (step 39).

5. **Basic Auth `<key>:`** (kosong setelah colon):
   Midtrans pakai pattern HTTP Basic dengan server key sebagai username, password kosong.

6. **Sandbox vs production**:
   Endpoint sandbox: `api.sandbox.midtrans.com`. Production: `api.midtrans.com`. Kita pakai production di code; bisa ditambah toggle env di SaveServerKeyPage (step 39).

## Commit suggestion

```bash
git add lib/data/datasources/midtrans_remote_datasource.dart lib/data/models/response/qris_response_model.dart lib/data/models/response/qris_status_response_model.dart lib/presentation/order/bloc/qris/ lib/presentation/order/widgets/payment_qris_sheet.dart lib/presentation/order/pages/order_page.dart lib/main.dart
git commit -m "Step 28: QRIS payment (Midtrans) + polling + sheet"
```

---

➡️ Lanjut ke [Step 29 — DraftOrder](./29-draft-order.md)
