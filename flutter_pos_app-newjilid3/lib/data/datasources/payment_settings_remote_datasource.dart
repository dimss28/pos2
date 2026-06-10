import 'dart:convert';

import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';
import '../models/response/payment_settings_model.dart';
import 'auth_local_datasource.dart';

class PaymentSettingsRemoteDatasource {
  Future<PaymentSettingsModel> fetch() async {
    try {
      final auth = await AuthLocalDatasource().getAuthData();
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/settings/payment'),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Accept': 'application/json',
        },
      );
      AuthInterceptor.instance.check(response);
      if (response.statusCode != 200) {
        return PaymentSettingsModel.unavailable();
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return PaymentSettingsModel.fromMap(data);
    } catch (_) {
      return PaymentSettingsModel.unavailable();
    }
  }
}
