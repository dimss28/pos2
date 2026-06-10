import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';
import '../models/response/category_response_model.dart';
import 'auth_local_datasource.dart';

/// CRUD kategori dari mobile.
///
/// Backend gated via `CategoryPolicy::create/update/delete` (admin/owner).
/// Kasir akan dapat 403 → datasource ini return `left()` dengan pesan dari BE.
class CategoryRemoteDatasource {
  Future<Map<String, String>> _headers() async {
    final auth = await AuthLocalDatasource().getAuthData();
    return {
      'Authorization': 'Bearer ${auth.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Sama dengan `ProductRemoteDatasource.getCategories()` tapi pakai
  /// endpoint baru `/api/categories` (full list, untuk admin page).
  Future<Either<String, List<Category>>> list() async {
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/categories'),
      headers: await _headers(),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_extractMessage(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (json['data'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final categories = data.map((m) => Category.fromMap(m)).toList();
      return right(categories);
    } catch (e) {
      return left('Gagal membaca data: $e');
    }
  }

  Future<Either<String, Category>> create({
    required String name,
    String? description,
    String icon = 'tag',
    String color = '#3B82F6',
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/categories'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        'icon': icon,
        'color': color,
        'sort_order': sortOrder,
        'is_active': isActive,
      }),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 201) return left(_extractMessage(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return right(Category.fromMap(json['data'] as Map<String, dynamic>));
    } catch (e) {
      return left('Gagal membaca respon: $e');
    }
  }

  Future<Either<String, Category>> update({
    required int id,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
    };
    final response = await http.put(
      Uri.parse('${Variables.baseUrl}/api/categories/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_extractMessage(response));
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return right(Category.fromMap(json['data'] as Map<String, dynamic>));
    } catch (e) {
      return left('Gagal membaca respon: $e');
    }
  }

  Future<Either<String, Unit>> delete(int id) async {
    final response = await http.delete(
      Uri.parse('${Variables.baseUrl}/api/categories/$id'),
      headers: await _headers(),
    );
    AuthInterceptor.instance.check(response);
    if (response.statusCode != 200) return left(_extractMessage(response));
    return right(unit);
  }

  String _extractMessage(http.Response r) {
    try {
      final json = jsonDecode(r.body) as Map<String, dynamic>;
      return (json['message'] as String?) ?? 'Gagal (${r.statusCode}).';
    } catch (_) {
      return 'Gagal (${r.statusCode}).';
    }
  }
}
