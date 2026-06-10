import 'dart:convert';

class OrderRequestModel {
  /// Idempotency key — Flutter generate UUID v4 saat order dibuat lokal.
  /// BE check kalau sudah ada → return existing (tidak duplikat).
  /// Penting untuk handle network blip yang retry order.
  final String? clientUuid;
  final String transactionTime;
  final int kasirId;
  final int totalPrice;
  final int totalItem;
  final String paymentMethod;
  final List<OrderItemModel> orderItems;
  final int? promoId;
  final int discountAmount;
  final int? cashSessionId;
  final int? amountPaid;

  OrderRequestModel({
    required this.transactionTime,
    required this.kasirId,
    required this.totalPrice,
    required this.totalItem,
    required this.orderItems,
    this.clientUuid,
    this.paymentMethod = 'cash',
    this.promoId,
    this.discountAmount = 0,
    this.cashSessionId,
    this.amountPaid,
  });

  factory OrderRequestModel.fromJson(String str) =>
      OrderRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderRequestModel.fromMap(Map<String, dynamic> json) =>
      OrderRequestModel(
        clientUuid: json['client_uuid'] as String?,
        transactionTime: json['transaction_time'],
        kasirId: json['kasir_id'],
        totalPrice: json['total_price'],
        totalItem: json['total_item'],
        paymentMethod: json['payment_method'],
        promoId: (json['promo_id'] as num?)?.toInt(),
        discountAmount: (json['discount_amount'] as num?)?.toInt() ?? 0,
        orderItems: List<OrderItemModel>.from(
            json['order_items'].map((x) => OrderItemModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        if (clientUuid != null) 'client_uuid': clientUuid,
        'transaction_time': transactionTime,
        'kasir_id': kasirId,
        'total_price': totalPrice,
        'total_item': totalItem,
        'payment_method': paymentMethod,
        if (promoId != null) 'promo_id': promoId,
        'discount_amount': discountAmount,
        if (cashSessionId != null) 'cash_session_id': cashSessionId,
        if (amountPaid != null) 'amount_paid': amountPaid,
        'order_items': List<dynamic>.from(orderItems.map((x) => x.toMap())),
      };
}

class OrderItemModel {
  final int productId;
  final int quantity;
  final int totalPrice;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(String str) =>
      OrderItemModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderItemModel.fromMap(Map<String, dynamic> json) => OrderItemModel(
        productId: json['product_id'],
        quantity: json['quantity'],
        totalPrice: json['total_price'],
      );

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'quantity': quantity,
        'total_price': totalPrice,
      };
}
