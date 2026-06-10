class TableOrderItemModel {
  final String productName;
  final int quantity;
  final int totalPrice;

  const TableOrderItemModel({
    required this.productName,
    required this.quantity,
    required this.totalPrice,
  });

  factory TableOrderItemModel.fromMap(Map<String, dynamic> m) {
    final product = m['product'] as Map<String, dynamic>?;
    return TableOrderItemModel(
      productName: (product?['name'] as String?) ?? 'Item',
      quantity: (m['quantity'] as num?)?.toInt() ?? 0,
      totalPrice: (m['total_price'] as num?)?.toInt() ?? 0,
    );
  }
}

class TableOrderModel {
  final int id;
  final String? orderNumber;
  final String status;
  final String? statusLabel;
  final String paymentMethod;
  final int totalPrice;
  final String? tableLabel;
  final String? customerName;
  final String? customerWhatsapp;
  final String? paymentProofUrl;
  final String? transactionTime;
  final String? notes;
  final List<TableOrderItemModel> items;

  TableOrderModel({
    required this.id,
    this.orderNumber,
    required this.status,
    this.statusLabel,
    required this.paymentMethod,
    required this.totalPrice,
    this.tableLabel,
    this.customerName,
    this.customerWhatsapp,
    this.paymentProofUrl,
    this.transactionTime,
    this.notes,
    this.items = const [],
  });

  bool get hasPaymentProof =>
      paymentProofUrl != null && paymentProofUrl!.isNotEmpty;

  factory TableOrderModel.fromMap(Map<String, dynamic> m) {
    final table = m['dining_table'] as Map<String, dynamic>?;
    final rawItems = m['order_items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => TableOrderItemModel.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : const <TableOrderItemModel>[];

    return TableOrderModel(
      id: (m['id'] as num?)?.toInt() ?? 0,
      orderNumber: m['order_number'] as String?,
      status: (m['status'] as String?) ?? '',
      statusLabel: m['status_label'] as String?,
      paymentMethod: (m['payment_method'] as String?) ?? '',
      totalPrice: (m['total_price'] as num?)?.toInt() ?? 0,
      tableLabel: table?['label'] as String?,
      customerName: m['customer_name'] as String?,
      customerWhatsapp: m['customer_whatsapp'] as String?,
      paymentProofUrl: m['payment_proof_url'] as String?,
      transactionTime: m['transaction_time'] as String?,
      notes: m['notes'] as String?,
      items: items,
    );
  }
}
