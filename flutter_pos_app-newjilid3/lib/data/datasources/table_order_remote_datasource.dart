import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';
import '../models/response/table_order_model.dart';
import 'auth_local_datasource.dart';

class TableOrderRemoteDatasource {
  Future<Map<String, String>> _headers() async {
    final auth = await AuthLocalDatasource().getAuthData();
    return {
      'Authorization': 'Bearer ${auth.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<Either<String, List<TableOrderModel>>> list({String? status}) async {
    final uri = Uri.parse('${Variables.baseUrl}/api/table-orders').replace(
      queryParameters: status != null && status.isNotEmpty ? {'status': status} : null,
    );
    final response = await http.get(uri, headers: await _headers());
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_msg(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (json['data'] as List<dynamic>? ?? const []);
      return right(data
          .map((e) => TableOrderModel.fromMap(e as Map<String, dynamic>))
          .toList());
    } catch (e) {
      return left('Gagal membaca data: $e');
    }
  }

  Future<Either<String, Unit>> confirm(int orderId) async {
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/table-orders/$orderId/confirm'),
      headers: await _headers(),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_msg(response));
    return right(unit);
  }

  Future<Either<String, Unit>> reject(int orderId) async {
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/table-orders/$orderId/reject'),
      headers: await _headers(),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_msg(response));
    return right(unit);
  }

  Future<Either<String, Unit>> updateStatus(int orderId, String status) async {
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/table-orders/$orderId/status'),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_msg(response));
    return right(unit);
  }

  String _msg(http.Response r) {
    try {
      final json = jsonDecode(r.body) as Map<String, dynamic>;
      return (json['message'] as String?) ?? 'Gagal (${r.statusCode}).';
    } catch (_) {
      return 'Gagal (${r.statusCode}).';
    }
  }
}
