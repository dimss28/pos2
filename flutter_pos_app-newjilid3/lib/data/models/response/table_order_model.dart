class TableOrderModel {
  final int id;
  final String? orderNumber;
  final String status;
  final String? statusLabel;
  final String paymentMethod;
  final int totalPrice;
  final String? tableLabel;
  final String? paymentProofUrl;
  final String? transactionTime;

  TableOrderModel({
    required this.id,
    this.orderNumber,
    required this.status,
    this.statusLabel,
    required this.paymentMethod,
    required this.totalPrice,
    this.tableLabel,
    this.paymentProofUrl,
    this.transactionTime,
  });

  factory TableOrderModel.fromMap(Map<String, dynamic> m) {
    final table = m['dining_table'] as Map<String, dynamic>?;
    return TableOrderModel(
      id: (m['id'] as num?)?.toInt() ?? 0,
      orderNumber: m['order_number'] as String?,
      status: (m['status'] as String?) ?? '',
      statusLabel: m['status_label'] as String?,
      paymentMethod: (m['payment_method'] as String?) ?? '',
      totalPrice: (m['total_price'] as num?)?.toInt() ?? 0,
      tableLabel: table?['label'] as String?,
      paymentProofUrl: m['payment_proof_url'] as String?,
      transactionTime: m['transaction_time'] as String?,
    );
  }
}
