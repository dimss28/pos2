import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';

import '../../core/constants/variables.dart';
import '../models/response/promo_model.dart';
import 'auth_local_datasource.dart';

class PromoRemoteDatasource {
  final AuthLocalDatasource _auth;
  final http.Client _http;

  PromoRemoteDatasource({AuthLocalDatasource? auth, http.Client? client})
      : _auth = auth ?? AuthLocalDatasource(),
        _http = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final authData = await _auth.getAuthData();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authData.token}',
    };
  }

  Uri _u(String path) => Uri.parse('${Variables.baseUrl}/api/$path');

  Either<String, dynamic> _unwrap(http.Response r) {
    // Chokepoint untuk semua response promo — 401 auto-redirect ke login.
    AuthInterceptor.instance.check(r);
    Map<String, dynamic> body;
    try {
      body = json.decode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return left('Server tidak merespon (${r.statusCode}).');
    }
    if (r.statusCode >= 200 && r.statusCode < 300 && body['success'] == true) {
      return right(body['data']);
    }
    return left((body['message'] as String?) ?? 'Terjadi kesalahan.');
  }

  Future<Either<String, List<PromoModel>>> list({
    bool activeOnly = false,
    bool liveOnly = false,
  }) async {
    try {
      final qp = <String, String>{};
      if (activeOnly) qp['active_only'] = '1';
      if (liveOnly) qp['live_only'] = '1';
      final uri = _u('promos').replace(queryParameters: qp.isEmpty ? null : qp);
      final r = await _http.get(uri, headers: await _headers());
      return _unwrap(r).fold(
        left,
        (data) => right(
          (data as List)
              .cast<Map<String, dynamic>>()
              .map(PromoModel.fromMap)
              .toList(),
        ),
      );
    } catch (e) {
      return left('Gagal koneksi: $e');
    }
  }

  Future<Either<String, PromoModel>> create(PromoModel p) async {
    try {
      final r = await _http.post(
        _u('promos'),
        headers: await _headers(),
        body: json.encode({
          'name': p.name,
          'type': typeKey(p.type),
          'value': p.value,
          if (p.code != null) 'code': p.code,
          'min_subtotal': p.minSubtotal,
          if (p.startsAt != null) 'starts_at': p.startsAt!.toIso8601String(),
          if (p.endsAt != null) 'ends_at': p.endsAt!.toIso8601String(),
          'active': p.active,
        }),
      );
      return _unwrap(r).fold(
        left,
        (data) => right(PromoModel.fromMap(data as Map<String, dynamic>)),
      );
    } catch (e) {
      return left('Gagal koneksi: $e');
    }
  }

  Future<Either<String, PromoModel>> update(PromoModel p) async {
    assert(p.id != null);
    try {
      final r = await _http.put(
        _u('promos/${p.id}'),
        headers: await _headers(),
        body: json.encode({
          'name': p.name,
          'type': typeKey(p.type),
          'value': p.value,
          'code': p.code,
          'min_subtotal': p.minSubtotal,
          if (p.startsAt != null) 'starts_at': p.startsAt!.toIso8601String(),
          if (p.endsAt != null) 'ends_at': p.endsAt!.toIso8601String(),
          'active': p.active,
        }),
      );
      return _unwrap(r).fold(
        left,
        (data) => right(PromoModel.fromMap(data as Map<String, dynamic>)),
      );
    } catch (e) {
      return left('Gagal koneksi: $e');
    }
  }

  Future<Either<String, PromoModel>> toggle(int id) async {
    try {
      final r = await _http.post(_u('promos/$id/toggle'),
          headers: await _headers());
      return _unwrap(r).fold(
        left,
        (data) => right(PromoModel.fromMap(data as Map<String, dynamic>)),
      );
    } catch (e) {
      return left('Gagal koneksi: $e');
    }
  }

  Future<Either<String, void>> delete(int id) async {
    try {
      final r =
          await _http.delete(_u('promos/$id'), headers: await _headers());
      return _unwrap(r).fold(left, (_) => right(null));
    } catch (e) {
      return left('Gagal koneksi: $e');
    }
  }

  /// Server-validated voucher application. Returns the matched promo +
  /// authoritative discount amount.
  Future<Either<String, (PromoModel, int)>> applyCode(
      String code, int subtotal) async {
    try {
      final r = await _http.post(
        _u('promos/apply'),
        headers: await _headers(),
        body: json.encode({'code': code, 'subtotal': subtotal}),
      );
      return _unwrap(r).fold(
        left,
        (data) {
          final map = data as Map<String, dynamic>;
          final promo = PromoModel.fromMap(
              map['promo'] as Map<String, dynamic>);
          final discount = (map['discount_amount'] as num).toInt();
          return right((promo, discount));
        },
      );
    } catch (e) {
      return left('Gagal koneksi: $e');
    }
  }
}
