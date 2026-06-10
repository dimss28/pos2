# 11 — Remote Datasources (HTTP) + Pola `Either<String, T>`

## Goal

3 datasource HTTP: auth (login/logout/deleteAccount), product (getProducts, addProduct multipart, updateProduct, getCategories). Plus pola `Either<String, T>` dari `dartz` untuk error handling.

## Prerequisite

- Step 10 (models) selesai.
- Backend Laravel sudah running di base URL yang di-define di `Variables.baseUrl`.

## Konsep yang diajarkan

- **`Either<L, R>` dari `dartz`** — Functional Programming-style "either error or value". Left = error, Right = success. Pemanggil pakai `result.fold(onLeft, onRight)` atau `.match(...)`.
- **`package:http`** — `http.get`, `http.post`, `http.MultipartRequest` untuk file upload.
- **Bearer token** — `headers: { 'Authorization': 'Bearer $token' }`.
- **Multipart vs form-urlencoded vs json**: kapan pakai mana.
- **`StreamedResponse` & `response.stream.bytesToString()`** untuk multipart response.
- **Method spoofing Laravel** (`_method=PUT` dengan POST multipart) — Laravel trick karena HTML form gak support PUT/PATCH.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Model & `Variables.baseUrl` sudah ada (step 10). Package `http`, `dartz`, `image_picker` sudah di pubspec.

Generate 2 file datasource di `lib/data/datasources/`.

═══════════════════════════════════════════════
FILE 1: lib/data/datasources/auth_remote_datasource.dart
═══════════════════════════════════════════════
```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:flutter_pos_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos_app/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  /// POST /api/login dengan body form (email, password).
  /// 200 → Right(AuthResponseModel). Else → Left(body) (raw error string).
  Future<Either<String, AuthResponseModel>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/login'),
      body: {'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      return right(AuthResponseModel.fromJson(response.body));
    } else {
      return left(response.body);
    }
  }

  /// POST /api/logout — butuh Bearer token dari AuthLocal.
  Future<Either<String, String>> logout() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/logout'),
      headers: {'Authorization': 'Bearer ${authData.token}'},
    );
    return response.statusCode == 200
        ? right(response.body)
        : left(response.body);
  }

  /// DELETE /api/account dengan body {"confirmation":"HAPUS AKUN"}.
  /// Guard supaya tidak terpicu tanpa intent eksplisit user.
  Future<Either<String, String>> deleteAccount() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.delete(
      Uri.parse('${Variables.baseUrl}/api/account'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: '{"confirmation":"HAPUS AKUN"}',
    );
    return response.statusCode == 200
        ? right(response.body)
        : left(response.body);
  }
}
```

(Asumsikan `AuthLocalDatasource` belum ada — akan dibuat di step 13. Sementara biarkan import dan akan resolve nanti.)

═══════════════════════════════════════════════
FILE 2: lib/data/datasources/product_remote_datasource.dart
═══════════════════════════════════════════════
```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:flutter_pos_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos_app/data/models/request/product_request_model.dart';
import 'package:flutter_pos_app/data/models/response/add_product_response_model.dart';
import 'package:flutter_pos_app/data/models/response/category_response_model.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProductRemoteDatasource {
  /// GET /api/products
  Future<Either<String, ProductResponseModel>> getProducts() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/products'),
      headers: {'Authorization': 'Bearer ${authData.token}'},
    );
    return response.statusCode == 200
        ? right(ProductResponseModel.fromJson(response.body))
        : left(response.body);
  }

  /// POST /api/products multipart — image file + form fields.
  /// Status 201 (Created) = success.
  Future<Either<String, AddProductResponseModel>> addProduct(
      ProductRequestModel req) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final request = http.MultipartRequest(
        'POST', Uri.parse('${Variables.baseUrl}/api/products'));
    request.fields.addAll(req.toMap());
    request.files.add(await http.MultipartFile.fromPath('image', req.image.path));
    request.headers.addAll({'Authorization': 'Bearer ${authData.token}'});

    final response = await request.send();
    final body = await response.stream.bytesToString();

    return response.statusCode == 201
        ? right(AddProductResponseModel.fromJson(body))
        : left(body);
  }

  /// Update via POST multipart + _method=PUT (Laravel form spoofing).
  /// `image` optional — kalau null, BE tidak menyentuh kolom image.
  Future<Either<String, AddProductResponseModel>> updateProduct({
    required int productId,
    required String name,
    required int price,
    required int stock,
    required String category,
    required int categoryId,
    required bool isBestSeller,
    XFile? image,
  }) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = '${Variables.baseUrl}/api/products/$productId';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll({
      '_method': 'PUT',
      'name': name,
      'price': price.toString(),
      'stock': stock.toString(),
      'category': category,
      'category_id': categoryId.toString(),
      'is_best_seller': isBestSeller ? '1' : '0',
    });
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    request.headers.addAll({
      'Authorization': 'Bearer ${authData.token}',
      'Accept': 'application/json',
    });

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return right(AddProductResponseModel.fromJson(body));
      }
      return left('HTTP ${response.statusCode}: $body');
    } catch (e) {
      return left('Network error: $e');
    }
  }

  /// GET /api/list-categories
  Future<Either<String, CategoryResponseModel>> getCategories() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/list-categories'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
      },
    );
    return response.statusCode == 200
        ? right(CategoryResponseModel.fromJson(response.body))
        : left(response.body);
  }
}
```

Beri saya juga **cheatsheet ringkas** cara pakai `Either`:
```dart
final result = await AuthRemoteDatasource().login(email, password);
result.fold(
  (err) => emit(LoginState.error(err)),
  (data) => emit(LoginState.success(data)),
);
```
````

---

## Verifikasi

Belum bisa di-run end-to-end (auth local belum ada). Sementara:
1. `flutter analyze` clean (kecuali `AuthLocalDatasource` undefined — akan resolve di step 13).
2. Pastikan struktur method `Future<Either<String, T>>` konsisten.

## Talking points

1. **Kenapa `Either<String, T>`?**
   - Alternatif: throw exception. Tapi bloc lebih clean kalau treat error sebagai value, bukan control flow.
   - `Either` adalah type "salah satu dari dua": Left (gagal) atau Right (sukses). "Right is right" mnemonic — Right = correct = success.
   - `result.fold(onLeft, onRight)` paksa kita handle keduanya — compiler check.

2. **Bearer token tiap call**:
   Boilerplate berulang. Trade-off vs interceptor (Dio): interceptor lebih elegan tapi nambah dependency. Untuk POS sederhana, eksplisit baik karena pemula bisa lihat token mengalir.

3. **Multipart vs json**:
   - File upload → multipart wajib (foto produk).
   - Form simple → `body: {...}` (map<String, String>) auto-encode `application/x-www-form-urlencoded`.
   - JSON body → `headers: {'Content-Type': 'application/json'}, body: jsonEncode({...})`.

4. **Method spoofing `_method=PUT`**:
   Laravel terima `POST /resource/{id}` dengan field `_method=PUT` dan treat sebagai PUT. Trick lawas karena HTML form gak support PUT — tapi `package:http` ada DELETE/PUT, kenapa pakai trick? Karena multipart Dart Multipart API gak support method PUT properly. Workaround.

5. **`response.stream.bytesToString()` di multipart**:
   `request.send()` return `StreamedResponse`, bukan `Response`. Body harus di-collect dari stream secara manual.

6. **Status code 201 vs 200**:
   201 Created adalah konvensi REST untuk "resource baru dibuat". Cek spec BE: kadang BE pakai 200 untuk semua, kadang strict 201/204. Salah cek → false negative error handling.

## Commit suggestion

```bash
git add lib/data/datasources/auth_remote_datasource.dart lib/data/datasources/product_remote_datasource.dart
git commit -m "Step 11: remote datasources — auth, product (with multipart)"
```

---

➡️ Lanjut ke [Step 12 — SQLite Local Datasource](./12-sqlite-local-datasource.md)
