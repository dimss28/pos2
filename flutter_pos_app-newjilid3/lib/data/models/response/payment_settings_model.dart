class PaymentSettingsModel {
  final bool qrisEnabled;
  final bool midtransConfigured;
  final String environment;
  final bool transferConfigured;

  PaymentSettingsModel({
    required this.qrisEnabled,
    required this.midtransConfigured,
    required this.environment,
    required this.transferConfigured,
  });

  bool get qrisAvailable => qrisEnabled && midtransConfigured;

  factory PaymentSettingsModel.fromMap(Map<String, dynamic> m) {
    return PaymentSettingsModel(
      qrisEnabled: m['qris_enabled'] == true,
      midtransConfigured: m['midtrans_configured'] == true,
      environment: (m['midtrans_environment'] as String?) ?? 'sandbox',
      transferConfigured: m['transfer_configured'] == true,
    );
  }

  static PaymentSettingsModel unavailable() => PaymentSettingsModel(
        qrisEnabled: false,
        midtransConfigured: false,
        environment: 'sandbox',
        transferConfigured: false,
      );
}
