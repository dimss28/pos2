import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:flutter_pos_app/data/models/request/order_request_model.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';

import '../../presentation/order/models/order_model.dart';
import 'auth_local_datasource.dart';

class OrderRemoteDatasource {
  Future<bool> sendOrder(OrderRequestModel requestModel) async {
    final url = Uri.parse('${Variables.baseUrl}/api/orders');
    final authData = await AuthLocalDatasource().getAuthData();
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${authData.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (kDebugMode) {
      // Don't log the full payload — order data carries customer names and
      // payment totals that don't belong in console logs in production-style
      // builds. A counter is enough for traceability during dev.
      dev.log(
        'Sending order (${requestModel.totalItem} items)',
        name: 'OrderRemoteDatasource.sendOrder',
      );
    }
    final response = await http.post(
      url,
      headers: headers,
      body: requestModel.toJson(),
    );
    AuthInterceptor.instance.check(response);
    final ok = response.statusCode == 201 || response.statusCode == 200;
    if (!ok) {
      dev.log(
        'sendOrder FAILED ${response.statusCode}: ${response.body}',
        name: 'OrderRemoteDatasource',
      );
    } else {
      dev.log('sendOrder OK ${response.statusCode}', name: 'OrderRemoteDatasource');
    }
    return ok;
  }

  /// GET `/api/orders`. Returns the full server-side list of completed orders
  /// for the workspace, regardless of device. Used by HistoryBloc to render a
  /// multi-device view (orders from another tablet still show up).
  Future<Either<String, List<OrderModel>>> list({int? kasirId}) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final qs = kasirId != null ? '?kasir_id=$kasirId' : '';
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/orders$qs'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
      },
    );
    AuthInterceptor.instance.check(response);

    if (response.statusCode != 200) return left(response.body);

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (json['data'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return right(list.map(_mapResource).toList());
    } catch (e) {
      return left('Parse error: $e');
    }
  }

  /// POST `/api/orders/{id}/refund`. Submits a full refund with controlled
  /// reason + free-text note. Returns the refreshed [OrderModel] on success
  /// or the raw error body in Left for snackbar display.
  Future<Either<String, OrderModel>> refund({
    required int orderId,
    required String reason,
    String? note,
  }) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/orders/$orderId/refund'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reason': reason,
        if (note != null && note.isNotEmpty) 'note': note,
      }),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(response.body);
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) return left('Empty refund response');
      return right(_mapResource(data));
    } catch (e) {
      return left('Parse error: $e');
    }
  }

  OrderModel _mapResource(Map<String, dynamic> m) {
    return OrderModel(
      id: (m['id'] as num?)?.toInt(),
      paymentMethod: m['payment_method']?.toString() ?? '',
      nominalBayar: (m['amount_paid'] as num?)?.toInt() ?? 0,
      orders: const [],
      totalQuantity: (m['total_item'] as num?)?.toInt() ?? 0,
      totalPrice: (m['total_price'] as num?)?.toInt() ?? 0,
      idKasir: (m['kasir_id'] as num?)?.toInt() ?? 0,
      namaKasir: (m['kasir'] is Map)
          ? (m['kasir']['name']?.toString() ?? '')
          : '',
      isSync: true,
      transactionTime: m['transaction_time']?.toString() ?? '',
      cashSessionId: (m['cash_session_id'] as num?)?.toInt(),
      promoId: (m['promo_id'] as num?)?.toInt(),
      discountAmount: (m['discount_amount'] as num?)?.toInt() ?? 0,
      status: m['status']?.toString() ?? 'paid',
      refundedAt: m['refunded_at']?.toString(),
      refundReason: m['refund_reason']?.toString(),
      refundNote: m['refund_note']?.toString(),
      refundAmount: (m['refund_amount'] as num?)?.toInt() ?? 0,
      refundedByUserId: (m['refunded_by_user_id'] as num?)?.toInt(),
    );
  }
}
