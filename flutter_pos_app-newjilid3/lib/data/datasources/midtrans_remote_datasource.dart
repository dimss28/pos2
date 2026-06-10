import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_pos_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos_app/data/models/response/qris_response_model.dart';
import 'package:flutter_pos_app/data/models/response/qris_status_response_model.dart';
import 'package:http/http.dart' as http;

class MidtransRemoteDatasource {
  static String _baseUrl(String serverKey) =>
      serverKey.startsWith('SB-')
          ? 'https://api.sandbox.midtrans.com'
          : 'https://api.midtrans.com';

  String generateBasicAuthHeader(String serverKey) {
    final base64Credentials = base64Encode(utf8.encode('$serverKey:'));
    return 'Basic $base64Credentials';
  }

  Future<QrisResponseModel> generateQRCode(
      String orderId, int grossAmount) async {
    final serverKey = await AuthLocalDatasource().getMitransServerKey();
    final baseUrl = _baseUrl(serverKey);
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(serverKey),
    };

    final body = jsonEncode({
      'payment_type': 'gopay',
      'transaction_details': {
        'gross_amount': grossAmount,
        'order_id': orderId,
      },
    });

    dev.log('POST $baseUrl/v2/charge orderId=$orderId amount=$grossAmount',
        name: 'Midtrans');

    final response = await http.post(
      Uri.parse('$baseUrl/v2/charge'),
      headers: headers,
      body: body,
    );

    dev.log('charge response ${response.statusCode}: ${response.body}',
        name: 'Midtrans');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final qris = QrisResponseModel.fromJson(response.body);
      for (final a in qris.actions ?? []) {
        dev.log('action: ${a.name} → ${a.url}', name: 'Midtrans');
      }
      return qris;
    } else {
      throw Exception(
          'Failed to generate QR Code (${response.statusCode}): ${response.body}');
    }
  }

  Future<QrisStatusResponseModel> checkPaymentStatus(String orderId) async {
    final serverKey = await AuthLocalDatasource().getMitransServerKey();
    final baseUrl = _baseUrl(serverKey);
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(serverKey),
    };

    final response = await http.get(
      Uri.parse('$baseUrl/v2/$orderId/status'),
      headers: headers,
    );

    dev.log('status response ${response.statusCode}: ${response.body}',
        name: 'Midtrans');

    if (response.statusCode == 200) {
      return QrisStatusResponseModel.fromJson(response.body);
    } else {
      throw Exception(
          'Failed to check payment status (${response.statusCode}): ${response.body}');
    }
  }
}
