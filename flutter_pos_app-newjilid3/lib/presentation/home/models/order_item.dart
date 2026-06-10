import 'dart:convert';

import 'package:flutter_pos_app/data/models/request/order_request_model.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';

class OrderItem {
  final Product product;
  int quantity;
  String? note;

  OrderItem({
    required this.product,
    required this.quantity,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'note': note,
    };
  }

  Map<String, dynamic> toMapForLocal(int orderId) {
    return {
      'id_order': orderId,
      'id_product': product.productId,
      'quantity': quantity,
      'price': product.price,
      'note': note,
    };
  }

  static OrderItemModel fromMapLocal(Map<String, dynamic> map) {
    final unitPrice = (map['price'] as num?)?.toInt() ?? 0;
    final qty = (map['quantity'] as num?)?.toInt() ?? 0;
    return OrderItemModel(
      productId: (map['id_product'] as num?)?.toInt() ?? 0,
      quantity: qty,
      totalPrice: unitPrice * qty,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity']?.toInt() ?? 0,
      note: map['note'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));
}
