import 'package:dartz/dartz.dart';
import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:flutter_pos_app/data/models/request/product_request_model.dart';
import 'package:flutter_pos_app/data/models/response/add_product_response_model.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_interceptor.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:image_picker/image_picker.dart';

import '../models/response/category_response_model.dart';
import 'auth_local_datasource.dart';

class ProductRemoteDatasource {
  Future<Either<String, ProductResponseModel>> getProducts() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/products'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
      },
    );
    AuthInterceptor.instance.check(response);

    if (response.statusCode == 200) {
      return right(ProductResponseModel.fromJson(response.body));
    } else {
      return left(response.body);
    }
  }

  Future<Either<String, AddProductResponseModel>> addProduct(
      ProductRequestModel productRequestModel) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${authData.token}',
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Variables.baseUrl}/api/products'));
    request.fields.addAll(productRequestModel.toMap());
    request.files.add(await http.MultipartFile.fromPath(
        'image', productRequestModel.image.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    final String body = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return right(AddProductResponseModel.fromJson(body));
    } else {
      return left(body);
    }
  }

  /// PUT-via-multipart `POST /api/products/{id}` with `_method=PUT`. Image is
  /// optional — when null we omit the file part and the BE keeps the existing
  /// filename. Returns the refreshed product on success.
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
    final headers = <String, String>{
      'Authorization': 'Bearer ${authData.token}',
      'Accept': 'application/json',
    };

    // ignore: avoid_print
    print('[updateProduct] → POST $url (id=$productId, hasImage=${image != null})');

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
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }
    request.headers.addAll(headers);

    // ignore: avoid_print
    print(
      '[updateProduct] fields=${request.fields} '
      'files=${request.files.length} '
      'token=${authData.token.isEmpty ? "<empty>" : "<set ${authData.token.length} chars>"}',
    );

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      // ignore: avoid_print
      print(
        '[updateProduct] ← status=${response.statusCode} '
        'contentType=${response.headers['content-type']} '
        'bodyLen=${body.length}',
      );
      // ignore: avoid_print
      print('[updateProduct] body: ${body.length > 800 ? "${body.substring(0, 800)}..." : body}');

      if (response.statusCode == 200) {
        return right(AddProductResponseModel.fromJson(body));
      }
      return left('HTTP ${response.statusCode}: $body');
    } catch (e, st) {
      // ignore: avoid_print
      print('[updateProduct] EXCEPTION: $e\n$st');
      return left('Network error: $e');
    }
  }

  //get categories
  Future<Either<String, CategoryResponseModel>> getCategories() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/list-categories'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
      },
    );
    AuthInterceptor.instance.check(response);

    if (response.statusCode == 200) {
      return right(CategoryResponseModel.fromJson(response.body));
    } else {
      return left(response.body);
    }
  }
}
