import 'package:flutter_pos_app/data/models/response/auth_response_model.dart';
import 'package:flutter_pos_app/data/models/response/cash_session_model.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';

/// Shared test fixtures.

Product productFixture({
  int id = 1,
  String name = 'Kopi Susu Gula Aren',
  int price = 22000,
  int stock = 10,
  String category = 'Kopi',
}) =>
    Product(
      id: id,
      productId: id,
      name: name,
      description: null,
      price: price,
      stock: stock,
      category: category,
      categoryId: 1,
      image: 'placeholder.jpg',
      isBestSeller: false,
      createdAt: null,
      updatedAt: null,
    );

OrderItem orderItem(Product p, {int qty = 1, String? note}) =>
    OrderItem(product: p, quantity: qty, note: note);

CashSessionModel openSessionFixture({int id = 42, int userId = 1}) =>
    CashSessionModel(
      id: id,
      userId: userId,
      userName: 'Bahri',
      shiftLabel: 'Siang',
      openingFloat: 200000,
      openingNote: null,
      openedAt: DateTime(2026, 5, 25, 14),
    );

AuthResponseModel authFixture({
  int userId = 1,
  String name = 'Bahri',
  String token = 'fake-token',
}) =>
    AuthResponseModel(
      user: User(
        id: userId,
        name: name,
        email: 'bahri@example.com',
        phone: '',
        roles: 'cashier',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
      token: token,
    );
