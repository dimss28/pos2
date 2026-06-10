import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';
import '../models/response/user_model.dart';
import 'auth_local_datasource.dart';

/// CRUD karyawan untuk Manage User page.
///
/// Backend gated via `UserPolicy` (admin/owner only).
/// Kasir akan dapat 403 dari semua endpoint → datasource return `left()`.
class UserRemoteDatasource {
  Future<Map<String, String>> _headers() async {
    final auth = await AuthLocalDatasource().getAuthData();
    return {
      'Authorization': 'Bearer ${auth.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<Either<String, List<UserModel>>> list({String? query, String? role}) async {
    final qs = <String, String>{};
    if (query != null && query.isNotEmpty) qs['q'] = query;
    if (role != null && role.isNotEmpty) qs['role'] = role;
    final uri =
        Uri.parse('${Variables.baseUrl}/api/users').replace(queryParameters: qs);
    final response = await http.get(uri, headers: await _headers());
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_msg(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (json['data'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return right(data.map(UserModel.fromMap).toList());
    } catch (e) {
      return left('Gagal membaca data: $e');
    }
  }

  Future<Either<String, UserModel>> create({
    required String name,
    required String email,
    required String password,
    required String roles,
    String? phone,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/users'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'roles': roles,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'is_active': isActive,
      }),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 201) return left(_msg(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return right(UserModel.fromMap(json['data'] as Map<String, dynamic>));
    } catch (e) {
      return left('Gagal membaca respon: $e');
    }
  }

  Future<Either<String, UserModel>> update({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? roles,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (password != null && password.isNotEmpty) 'password': password,
      if (roles != null) 'roles': roles,
      if (isActive != null) 'is_active': isActive,
    };
    final response = await http.put(
      Uri.parse('${Variables.baseUrl}/api/users/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_msg(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return right(UserModel.fromMap(json['data'] as Map<String, dynamic>));
    } catch (e) {
      return left('Gagal membaca respon: $e');
    }
  }

  Future<Either<String, Unit>> delete(int id) async {
    final response = await http.delete(
      Uri.parse('${Variables.baseUrl}/api/users/$id'),
      headers: await _headers(),
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
