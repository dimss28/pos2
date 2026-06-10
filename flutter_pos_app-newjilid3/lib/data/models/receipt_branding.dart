/// User-configurable branding shown at the top + bottom of every printed
/// receipt. Persisted via [AuthLocalDatasource]; loaded once per print job.
///
/// All fields are optional — empty strings are skipped at print time so the
/// receipt doesn't render blank lines.
class ReceiptBranding {
  final String storeName;
  final String addressLine1;
  final String addressLine2;
  final String email;
  final String phone;
  final String footerLine1;
  final String footerLine2;

  /// Base64-encoded PNG bytes of the (already resized) logo, or empty.
  final String logoBase64;

  const ReceiptBranding({
    this.storeName = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.email = '',
    this.phone = '',
    this.footerLine1 = '',
    this.footerLine2 = '',
    this.logoBase64 = '',
  });

  ReceiptBranding copyWith({
    String? storeName,
    String? addressLine1,
    String? addressLine2,
    String? email,
    String? phone,
    String? footerLine1,
    String? footerLine2,
    String? logoBase64,
  }) {
    return ReceiptBranding(
      storeName: storeName ?? this.storeName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      footerLine1: footerLine1 ?? this.footerLine1,
      footerLine2: footerLine2 ?? this.footerLine2,
      logoBase64: logoBase64 ?? this.logoBase64,
    );
  }

  bool get hasLogo => logoBase64.isNotEmpty;
}
