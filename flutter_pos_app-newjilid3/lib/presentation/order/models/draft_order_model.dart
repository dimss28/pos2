import 'dart:convert';

import '../../home/models/draft_order_item.dart';

class DraftOrderModel {
  final int? id;
  final List<DraftOrderItem> orders;
  final int totalQuantity;
  final int totalPrice;
  final String transactionTime;

  /// Human-readable table label (e.g. "Meja 4", "Takeaway", "Bar 2").
  /// Replaces the int-only `tableNumber`. `tableNumber` is kept for
  /// backward compatibility with legacy rows but should be 0 going forward.
  final String tableLabel;

  /// Customer name (e.g. "Andi"). Empty when not given.
  final String customerName;

  /// Legacy numeric table — kept for compatibility but new code reads
  /// [tableLabel] instead.
  final int tableNumber;

  /// Legacy alias for customerName — old DB rows used this column.
  /// Reads use COALESCE(customer_name, draft_name).
  final String draftName;

  DraftOrderModel({
    this.id,
    required this.orders,
    required this.totalQuantity,
    required this.totalPrice,
    required this.transactionTime,
    this.tableLabel = '',
    this.customerName = '',
    this.tableNumber = 0,
    this.draftName = '',
  });

  /// Display label preferring the new structured fields, falling back to
  /// legacy ones for old rows.
  String get displayTableLabel {
    if (tableLabel.isNotEmpty) return tableLabel;
    if (tableNumber > 0) return 'Meja $tableNumber';
    return '';
  }

  String get displayCustomerName {
    if (customerName.isNotEmpty) return customerName;
    return draftName;
  }

  Map<String, dynamic> toMap() {
    return {
      'orders': orders.map((x) => x.toMap()).toList(),
      'totalQuantity': totalQuantity,
      'totalPrice': totalPrice,
      'tableLabel': tableLabel,
      'customerName': customerName,
    };
  }

  Map<String, dynamic> toMapForLocal() {
    return {
      'total_item': totalQuantity,
      'nominal': totalPrice,
      'table_number': tableNumber,
      'table_label': tableLabel,
      'draft_name': draftName,
      'customer_name': customerName,
      'transaction_time': transactionTime,
    };
  }

  factory DraftOrderModel.fromLocalMap(Map<String, dynamic> map) {
    return DraftOrderModel(
      orders: const [],
      totalQuantity: (map['total_item'] as num?)?.toInt() ?? 0,
      totalPrice: (map['nominal'] as num?)?.toInt() ?? 0,
      id: (map['id'] as num?)?.toInt(),
      transactionTime: map['transaction_time'] ?? '',
      tableNumber: (map['table_number'] as num?)?.toInt() ?? 0,
      tableLabel: (map['table_label'] as String?) ?? '',
      draftName: (map['draft_name'] as String?) ?? '',
      customerName: (map['customer_name'] as String?) ?? '',
    );
  }

  factory DraftOrderModel.newFromLocalMap(
      Map<String, dynamic> map, List<DraftOrderItem> orders) {
    return DraftOrderModel(
      orders: orders,
      totalQuantity: (map['total_item'] as num?)?.toInt() ?? 0,
      totalPrice: (map['nominal'] as num?)?.toInt() ?? 0,
      id: (map['id'] as num?)?.toInt(),
      transactionTime: map['transaction_time'] ?? '',
      tableNumber: (map['table_number'] as num?)?.toInt() ?? 0,
      tableLabel: (map['table_label'] as String?) ?? '',
      draftName: (map['draft_name'] as String?) ?? '',
      customerName: (map['customer_name'] as String?) ?? '',
    );
  }

  factory DraftOrderModel.fromMap(Map<String, dynamic> map) {
    return DraftOrderModel(
      orders: const [],
      totalQuantity: (map['totalQuantity'] as num?)?.toInt() ?? 0,
      totalPrice: (map['totalPrice'] as num?)?.toInt() ?? 0,
      id: (map['id'] as num?)?.toInt(),
      transactionTime: map['transactionTime'] ?? '',
      tableLabel: (map['tableLabel'] as String?) ?? '',
      customerName: (map['customerName'] as String?) ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DraftOrderModel.fromJson(String source) =>
      DraftOrderModel.fromMap(json.decode(source));
}
