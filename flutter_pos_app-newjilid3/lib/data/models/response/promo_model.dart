import 'dart:convert';

enum PromoType { percent, rupiah, b1g1 }

PromoType _parseType(String? raw) {
  switch (raw) {
    case 'rupiah':
      return PromoType.rupiah;
    case 'b1g1':
      return PromoType.b1g1;
    case 'percent':
    default:
      return PromoType.percent;
  }
}

String typeKey(PromoType t) => switch (t) {
      PromoType.percent => 'percent',
      PromoType.rupiah => 'rupiah',
      PromoType.b1g1 => 'b1g1',
    };

/// Promo / voucher record — mirrors `App\Models\Promo` server-side.
///
/// `computeDiscount(subtotal)` is the client-side preview; the BE recomputes
/// on order creation so a tampered client can't fake savings.
class PromoModel {
  final int? id;
  final String name;
  final PromoType type;
  final int value;
  final String? code;

  /// JSON-encoded shape, e.g. `{"category":"kopi"}` or `{"product_ids":[1,2]}`.
  final String? appliesToJson;

  final int minSubtotal;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool active;
  final int isSync;

  PromoModel({
    this.id,
    required this.name,
    required this.type,
    required this.value,
    this.code,
    this.appliesToJson,
    this.minSubtotal = 0,
    this.startsAt,
    this.endsAt,
    this.active = true,
    this.isSync = 0,
  });

  bool get hasCode => (code ?? '').isNotEmpty;

  bool isLive([DateTime? now]) {
    final n = now ?? DateTime.now();
    if (!active) return false;
    if (startsAt != null && n.isBefore(startsAt!)) return false;
    if (endsAt != null && n.isAfter(endsAt!)) return false;
    return true;
  }

  /// Client-side discount preview. Matches BE's `Promo::computeDiscount`.
  int computeDiscount(int subtotal) {
    if (!isLive()) return 0;
    if (subtotal < minSubtotal) return 0;
    switch (type) {
      case PromoType.percent:
        return (subtotal * value ~/ 100);
      case PromoType.rupiah:
        return value > subtotal ? subtotal : value;
      case PromoType.b1g1:
        return 0; // Computed per-line by caller; left to UI.
    }
  }

  factory PromoModel.fromMap(Map<String, dynamic> map) {
    return PromoModel(
      id: (map['id'] as num?)?.toInt(),
      name: map['name'] as String,
      type: _parseType(map['type'] as String?),
      value: (map['value'] as num?)?.toInt() ?? 0,
      code: map['code'] as String?,
      appliesToJson: map['applies_to'] is String
          ? map['applies_to'] as String
          : map['applies_to'] == null
              ? null
              : json.encode(map['applies_to']),
      minSubtotal: (map['min_subtotal'] as num?)?.toInt() ?? 0,
      startsAt: _parseDt(map['starts_at']),
      endsAt: _parseDt(map['ends_at']),
      active: _parseBool(map['active']),
      isSync: (map['is_sync'] as num?)?.toInt() ?? 0,
    );
  }

  factory PromoModel.fromJson(String src) =>
      PromoModel.fromMap(json.decode(src));

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'type': typeKey(type),
        'value': value,
        'code': code,
        'applies_to': appliesToJson,
        'min_subtotal': minSubtotal,
        'starts_at': startsAt?.toIso8601String(),
        'ends_at': endsAt?.toIso8601String(),
        'active': active ? 1 : 0,
        'is_sync': isSync,
      };

  PromoModel copyWith({
    int? id,
    String? name,
    PromoType? type,
    int? value,
    String? code,
    String? appliesToJson,
    int? minSubtotal,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? active,
    int? isSync,
  }) =>
      PromoModel(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        value: value ?? this.value,
        code: code ?? this.code,
        appliesToJson: appliesToJson ?? this.appliesToJson,
        minSubtotal: minSubtotal ?? this.minSubtotal,
        startsAt: startsAt ?? this.startsAt,
        endsAt: endsAt ?? this.endsAt,
        active: active ?? this.active,
        isSync: isSync ?? this.isSync,
      );

  static DateTime? _parseDt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }
}
