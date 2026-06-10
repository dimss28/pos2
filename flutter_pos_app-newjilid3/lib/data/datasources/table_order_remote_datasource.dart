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

  List<Map<String, dynamic>> _extractOrderMaps(Map<String, dynamic> json) {
    final root = json['data'];
    if (root is List) {
      return root
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (root is Map<String, dynamic>) {
      final nested = root['data'];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  Future<Either<String, List<TableOrderModel>>> list({String? status}) async {
    final uri = Uri.parse('${Variables.baseUrl}/api/table-orders').replace(
      queryParameters:
          status != null && status.isNotEmpty ? {'status': status} : null,
    );
    final response = await http.get(uri, headers: await _headers());
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_msg(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final maps = _extractOrderMaps(json);
      return right(
        maps.map(TableOrderModel.fromMap).toList(),
      );
    } catch (e) {
      return left('Gagal membaca pesanan meja: $e');
    }
  }

  Future<int> pendingCount() async {
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/table-orders/pending-count'),
      headers: await _headers(),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return 0;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'];
      if (data is Map && data['count'] != null) {
        return (data['count'] as num).toInt();
      }
    } catch (_) {}
    return 0;
  }

  Future<Either<String, TableOrderModel>> show(int orderId) async {
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/table-orders/$orderId'),
      headers: await _headers(),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_msg(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        return right(TableOrderModel.fromMap(data));
      }
      return left('Format pesanan tidak valid.');
    } catch (e) {
      return left('Gagal membaca detail pesanan: $e');
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
      if (r.statusCode == 404) {
        return 'API pesanan meja tidak ditemukan. Update server & route:clear.';
      }
      return 'Gagal (${r.statusCode}).';
    }
  }
}
