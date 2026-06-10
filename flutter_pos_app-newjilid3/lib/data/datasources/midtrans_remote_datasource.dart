import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:flutter_pos_app/data/models/response/qris_response_model.dart';
import 'package:flutter_pos_app/data/models/response/qris_status_response_model.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';
import 'auth_local_datasource.dart';

/// QRIS via server — Server Key Midtrans hanya disimpan di backend.
class MidtransRemoteDatasource {
  Future<Map<String, String>> _headers() async {
    final auth = await AuthLocalDatasource().getAuthData();
    return {
      'Authorization': 'Bearer ${auth.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<QrisResponseModel> generateQRCode(
      String orderId, int grossAmount) async {
    dev.log('POST /api/payments/qris/charge orderId=$orderId amount=$grossAmount',
        name: 'QrisPayment');

    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/payments/qris/charge'),
      headers: await _headers(),
      body: jsonEncode({
        'order_id': orderId,
        'gross_amount': grossAmount,
      }),
    );

    AuthInterceptor.instance.check(response);
    dev.log('charge response ${response.statusCode}: ${response.body}',
        name: 'QrisPayment');

    if (response.statusCode != 200) {
      final msg = _extractMessage(response);
      throw Exception(msg);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final midtrans = data['midtrans'] as Map<String, dynamic>? ?? data;
    return QrisResponseModel.fromMap(midtrans);
  }

  Future<QrisStatusResponseModel> checkPaymentStatus(String orderId) async {
    dev.log('GET /api/payments/qris/$orderId/status', name: 'QrisPayment');

    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/payments/qris/$orderId/status'),
      headers: await _headers(),
    );

    AuthInterceptor.instance.check(response);
    dev.log('status response ${response.statusCode}: ${response.body}',
        name: 'QrisPayment');

    if (response.statusCode != 200) {
      final msg = _extractMessage(response);
      throw Exception(msg);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return QrisStatusResponseModel.fromMap(data);
  }

  String _extractMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['message'] as String?) ??
          'Gagal (${response.statusCode})';
    } catch (_) {
      return 'Gagal (${response.statusCode})';
    }
  }
}
