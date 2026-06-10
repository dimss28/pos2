import 'dart:convert';

import '../../home/models/order_item.dart';

class OrderModel {
  final int? id;
  /// Idempotency key — UUID v4 yang di-generate saat order dibuat lokal.
  /// Disimpan di tabel orders.client_uuid (sqflite) dan dikirim ke BE saat
  /// sync. BE check duplikat by client_uuid → tidak double-process kalau
  /// retry karena network blip.
  final String? clientUuid;
  final String paymentMethod;
  final int nominalBayar;
  final List<OrderItem> orders;
  final int totalQuantity;
  final int totalPrice;
  final int idKasir;
  final String namaKasir;
  final String transactionTime;
  final bool isSync;

  /// FK → `cash_sessions.id`. Required for orders made while a shift is
  /// active; carried through to the BE so `cashRevenue()` attribution works.
  final int? cashSessionId;

  /// FK → `promos.id` if a promo was applied at checkout.
  final int? promoId;

  /// Discount amount in rupiah that was deducted from subtotal.
  final int discountAmount;

  /// V1 refund tracking. `'paid'` for normal orders, `'refunded'` once a
  /// refund has been processed. Other transitional statuses come from BE
  /// (`pending`, `cancelled`) and are surfaced as-is.
  final String status;
  final String? refundedAt;
  final String? refundReason;
  final String? refundNote;
  final int refundAmount;
  final int? refundedByUserId;

  bool get isRefunded => status == 'refunded';

  OrderModel({
    this.id,
    this.clientUuid,
    required this.paymentMethod,
    required this.nominalBayar,
    required this.orders,
    required this.totalQuantity,
    required this.totalPrice,
    required this.idKasir,
    required this.namaKasir,
    required this.isSync,
    required this.transactionTime,
    this.cashSessionId,
    this.promoId,
    this.discountAmount = 0,
    this.status = 'paid',
    this.refundedAt,
    this.refundReason,
    this.refundNote,
    this.refundAmount = 0,
    this.refundedByUserId,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentMethod': paymentMethod,
      'nominalBayar': nominalBayar,
      'orders': orders.map((x) => x.toMap()).toList(),
      'totalQuantity': totalQuantity,
      'totalPrice': totalPrice,
      'idKasir': idKasir,
      'namaKasir': namaKasir,
      'isSync': isSync,
      'cashSessionId': cashSessionId,
      'promoId': promoId,
      'discountAmount': discountAmount,
    };
  }

  Map<String, dynamic> toMapForLocal() {
    return {
      'client_uuid': clientUuid,
      'payment_method': paymentMethod,
      'total_item': totalQuantity,
      'nominal': totalPrice,
      'id_kasir': idKasir,
      'nama_kasir': namaKasir,
      'is_sync': isSync ? 1 : 0,
      'transaction_time': transactionTime,
      'cash_session_id': cashSessionId,
      'promo_id': promoId,
      'discount_amount': discountAmount,
      'status': status,
      'refunded_at': refundedAt,
      'refund_reason': refundReason,
      'refund_note': refundNote,
      'refund_amount': refundAmount,
      'refunded_by_user_id': refundedByUserId,
    };
  }

  factory OrderModel.fromLocalMap(Map<String, dynamic> map) {
    return OrderModel(
      clientUuid: map['client_uuid'] as String?,
      paymentMethod: map['payment_method'] ?? '',
      nominalBayar: (map['nominal'] as num?)?.toInt() ?? 0,
      orders: const [],
      totalQuantity: (map['total_item'] as num?)?.toInt() ?? 0,
      totalPrice: (map['nominal'] as num?)?.toInt() ?? 0,
      idKasir: (map['id_kasir'] as num?)?.toInt() ?? 0,
      isSync: map['is_sync'] == 1,
      namaKasir: map['nama_kasir'] ?? '',
      id: (map['id'] as num?)?.toInt(),
      transactionTime: map['transaction_time'] ?? '',
      cashSessionId: (map['cash_session_id'] as num?)?.toInt(),
      promoId: (map['promo_id'] as num?)?.toInt(),
      discountAmount: (map['discount_amount'] as num?)?.toInt() ?? 0,
      status: (map['status'] as String?) ?? 'paid',
      refundedAt: map['refunded_at'] as String?,
      refundReason: map['refund_reason'] as String?,
      refundNote: map['refund_note'] as String?,
      refundAmount: (map['refund_amount'] as num?)?.toInt() ?? 0,
      refundedByUserId: (map['refunded_by_user_id'] as num?)?.toInt(),
    );
  }

  factory OrderModel.newFromLocalMap(
      Map<String, dynamic> map, List<OrderItem> orders) {
    return OrderModel(
      clientUuid: map['client_uuid'] as String?,
      paymentMethod: map['payment_method'] ?? '',
      nominalBayar: (map['nominal'] as num?)?.toInt() ?? 0,
      orders: orders,
      totalQuantity: (map['total_item'] as num?)?.toInt() ?? 0,
      totalPrice: (map['nominal'] as num?)?.toInt() ?? 0,
      idKasir: (map['id_kasir'] as num?)?.toInt() ?? 0,
      isSync: map['is_sync'] == 1,
      namaKasir: map['nama_kasir'] ?? '',
      id: (map['id'] as num?)?.toInt(),
      transactionTime: map['transaction_time'] ?? '',
      cashSessionId: (map['cash_session_id'] as num?)?.toInt(),
      promoId: (map['promo_id'] as num?)?.toInt(),
      discountAmount: (map['discount_amount'] as num?)?.toInt() ?? 0,
      status: (map['status'] as String?) ?? 'paid',
      refundedAt: map['refunded_at'] as String?,
      refundReason: map['refund_reason'] as String?,
      refundNote: map['refund_note'] as String?,
      refundAmount: (map['refund_amount'] as num?)?.toInt() ?? 0,
      refundedByUserId: (map['refunded_by_user_id'] as num?)?.toInt(),
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      paymentMethod: map['paymentMethod'] ?? '',
      nominalBayar: (map['nominalBayar'] as num?)?.toInt() ?? 0,
      orders: List<OrderItem>.from(
          (map['orders'] ?? const []).map((x) => OrderItem.fromMap(x))),
      totalQuantity: (map['totalQuantity'] as num?)?.toInt() ?? 0,
      totalPrice: (map['totalPrice'] as num?)?.toInt() ?? 0,
      idKasir: (map['idKasir'] as num?)?.toInt() ?? 0,
      isSync: map['isSync'] ?? false,
      namaKasir: map['namaKasir'] ?? '',
      id: (map['id'] as num?)?.toInt(),
      transactionTime: map['transactionTime'] ?? '',
      cashSessionId: (map['cashSessionId'] as num?)?.toInt(),
      promoId: (map['promoId'] as num?)?.toInt(),
      discountAmount: (map['discountAmount'] as num?)?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source));
}
