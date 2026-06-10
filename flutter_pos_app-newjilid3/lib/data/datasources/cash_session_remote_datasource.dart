import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';

import '../../core/constants/variables.dart';
import '../models/response/cash_session_model.dart';
import 'auth_local_datasource.dart';

/// HTTP client for `/api/cash-sessions/*`.
///
/// The backend is the source of truth for shift state — it enforces
/// "one open session per user" and rejects new orders without an open
/// session. This datasource is wrapped by [CashSessionBloc].
class CashSessionRemoteDatasource {
  final AuthLocalDatasource _auth;
  final http.Client _http;

  CashSessionRemoteDatasource({
    AuthLocalDatasource? auth,
    http.Client? client,
  })  : _auth = auth ?? AuthLocalDatasource(),
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

  /// Pulls the envelope. Returns `data` on success, or the BE `message`
  /// (or fallback) on failure. Chokepoint untuk semua response cash-session,
  /// jadi 401-check dilakukan di sini sekali.
  Either<String, dynamic> _unwrap(http.Response r) {
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
    final msg = (body['message'] as String?) ?? 'Terjadi kesalahan.';
    return left(msg);
  }

  /// `GET /api/cash-sessions?all=1&status=open` — list shift.
  /// Admin/owner pakai `all: true` untuk lihat shift semua kasir
  /// (untuk fitur force-close shift orang lain).
  Future<Either<String, List<CashSessionModel>>> list({
    bool all = false,
    String? status,
  }) async {
    try {
      final qs = <String, String>{
        if (all) 'all': '1',
        if (status != null) 'status': status,
      };
      final uri = _u('cash-sessions').replace(queryParameters: qs);
      final r = await _http.get(uri, headers: await _headers());
      return _unwrap(r).fold(
        left,
        (data) {
          final list = (data as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map(CashSessionModel.fromMap)
              .toList();
          return right(list);
        },
      );
    } catch (e) {
      return left('Gagal koneksi ke server: $e');
    }
  }

  /// `GET /api/cash-sessions/current` — returns the open session for the
  /// auth user, or `right(null)` if none.
  Future<Either<String, CashSessionModel?>> getCurrent() async {
    try {
      final r = await _http.get(_u('cash-sessions/current'),
          headers: await _headers());
      return _unwrap(r).fold(
        left,
        (data) => right(data == null
            ? null
            : CashSessionModel.fromMap(data as Map<String, dynamic>)),
      );
    } catch (e) {
      return left('Gagal koneksi ke server: $e');
    }
  }

  /// `POST /api/cash-sessions/open` — opens a new shift. BE rejects with 409
  /// if a session is already open for this user.
  Future<Either<String, CashSessionModel>> open({
    required String shiftLabel,
    required int openingFloat,
    String? openingNote,
  }) async {
    try {
      final r = await _http.post(
        _u('cash-sessions/open'),
        headers: await _headers(),
        body: json.encode({
          'shift_label': shiftLabel,
          'opening_float': openingFloat,
          if (openingNote != null) 'opening_note': openingNote,
        }),
      );
      return _unwrap(r).fold(
        left,
        (data) =>
            right(CashSessionModel.fromMap(data as Map<String, dynamic>)),
      );
    } catch (e) {
      return left('Gagal koneksi ke server: $e');
    }
  }

  /// `POST /api/cash-sessions/{id}/close` — close a shift. The BE recomputes
  /// `expected_cash` and `variance` from order data; the response carries
  /// the authoritative values.
  Future<Either<String, CashSessionModel>> close({
    required int sessionId,
    required int physicalCount,
    int? cashIn,
    int? cashOut,
    String? closingNote,
  }) async {
    try {
      final r = await _http.post(
        _u('cash-sessions/$sessionId/close'),
        headers: await _headers(),
        body: json.encode({
          'physical_count': physicalCount,
          if (cashIn != null) 'cash_in': cashIn,
          if (cashOut != null) 'cash_out': cashOut,
          if (closingNote != null) 'closing_note': closingNote,
        }),
      );
      return _unwrap(r).fold(
        left,
        (data) =>
            right(CashSessionModel.fromMap(data as Map<String, dynamic>)),
      );
    } catch (e) {
      return left('Gagal koneksi ke server: $e');
    }
  }

  /// Admin/owner-only: force-close shift orang lain (kalau kasir lupa tutup).
  /// BE menganggap variance 0 dan tag closing_note dengan nama admin
  /// supaya audit trail jelas.
  Future<Either<String, CashSessionModel>> forceClose(int sessionId) async {
    try {
      final r = await _http.post(
        _u('cash-sessions/$sessionId/force-close'),
        headers: await _headers(),
      );
      return _unwrap(r).fold(
        left,
        (data) =>
            right(CashSessionModel.fromMap(data as Map<String, dynamic>)),
      );
    } catch (e) {
      return left('Gagal koneksi ke server: $e');
    }
  }

  /// `GET /api/cash-sessions/{id}/summary` — aggregate for close-shift screen:
  /// order_count, items_sold, gross_revenue, cash_revenue, by_method,
  /// expected_cash.
  Future<Either<String, Map<String, dynamic>>> summary(int sessionId) async {
    try {
      final r = await _http.get(
        _u('cash-sessions/$sessionId/summary'),
        headers: await _headers(),
      );
      return _unwrap(r).fold(
        left,
        (data) => right((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return left('Gagal koneksi ke server: $e');
    }
  }
}
