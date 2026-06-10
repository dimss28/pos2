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

  /// Payload shape for `POST /api/orders` (Laravel [ApiOrderStoreRequest]).
  Map<String, dynamic> toMap() {
    final itemsSubtotal = orderItems.fold<int>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final tax = (totalPrice - itemsSubtotal).clamp(0, 1 << 31);

    return {
      'items': orderItems.map((x) => x.toMap()).toList(),
      'subtotal': itemsSubtotal,
      if (tax > 0) 'tax': tax,
      'amount_paid': amountPaid ?? totalPrice,
      'payment_method': _normalizePaymentMethod(paymentMethod),
      if (promoId != null) 'promo_id': promoId,
      if (transactionTime.isNotEmpty) 'transaction_time': transactionTime,
    };
  }

  static String _normalizePaymentMethod(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('qris')) return 'qris';
    if (v.contains('transfer')) return 'transfer';
    return 'cash';
  }
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
