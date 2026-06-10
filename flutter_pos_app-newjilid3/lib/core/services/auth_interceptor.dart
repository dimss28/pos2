import 'dart:async';

import 'package:http/http.dart' as http;

/// Centralized handler untuk respons HTTP 401 (token revoked / expired).
///
/// Semua datasource yang memanggil endpoint authenticated harus pass response
/// HTTP-nya melalui [AuthInterceptor.check]. Kalau status 401, [onUnauthorized]
/// stream akan emit event → main.dart listener akan force logout user dan
/// redirect ke LoginPage.
///
/// Kenapa pattern singleton + Stream, bukan Dio interceptor?
/// Project ini pakai `http` package langsung di banyak datasource. Migrasi ke
/// Dio = refactor besar. Pattern ini minim-invasive: cukup wrap response.
class AuthInterceptor {
  AuthInterceptor._();

  static final AuthInterceptor instance = AuthInterceptor._();

  final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();

  /// Listen di main.dart (di-handle via BlocListener atau navigator key).
  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  /// Cek response — kalau 401, emit event ke stream.
  /// Datasource tetap return error normal-nya, listener yang handle redirect.
  void check(http.Response response) {
    if (response.statusCode == 401) {
      _unauthorizedController.add(null);
    }
  }

  /// Helper untuk dispose saat app shutdown (umumnya tidak perlu — singleton
  /// hidup sampai app mati).
  Future<void> dispose() async {
    await _unauthorizedController.close();
  }
}
