import 'package:http/http.dart' as http;

import 'auth_interceptor.dart';

/// Thin wrapper di atas `package:http` yang auto-check 401 via
/// [AuthInterceptor]. Tujuan: kalau token Sanctum di-revoke BE (logout
/// di device lain, password berubah, akun dinonaktifkan, atau token expire),
/// FE tidak diam-diam show error body raw — tapi auto-redirect ke login.
///
/// Cara pakai (drop-in replacement untuk http.post / http.get / dll):
///
/// ```dart
/// final response = await AuthorizedHttp.post(uri, headers: ..., body: ...);
/// ```
///
/// Kalau datasource lama belum migrasi ke wrapper ini, mereka bisa tetap
/// pakai `http` langsung — tapi handler 401 tidak aktif untuk panggilan
/// tersebut.
class AuthorizedHttp {
  AuthorizedHttp._();

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final response = await http.get(url, headers: headers);
    AuthInterceptor.instance.check(response);
    return response;
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    AuthInterceptor.instance.check(response);
    return response;
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await http.put(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    AuthInterceptor.instance.check(response);
    return response;
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await http.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    AuthInterceptor.instance.check(response);
    return response;
  }

  /// Untuk multipart request, kita tidak bisa wrap konstruktor MultipartRequest
  /// langsung. Tapi datasource bisa pakai pattern:
  ///
  /// ```dart
  /// final streamed = await multipart.send();
  /// final response = await http.Response.fromStream(streamed);
  /// AuthorizedHttp.check(response); // manual check
  /// ```
  static void check(http.Response response) {
    AuthInterceptor.instance.check(response);
  }
}

// Re-export Encoding supaya import langsung jadi minimal di datasource.
typedef Encoding = dynamic;
