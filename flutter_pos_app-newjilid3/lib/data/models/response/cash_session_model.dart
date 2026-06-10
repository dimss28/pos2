import 'dart:convert';

/// Represents a single cashier shift / cash-drawer session.
///
/// Created when the cashier taps "Mulai Shift" on [BukaKasirPage].
/// Marked closed when the cashier completes Tutup Kasir reconciliation.
class CashSessionModel {
  final int? id;
  final int userId;
  final String userName;
  final String shiftLabel; // 'Pagi' | 'Siang' | 'Malam'
  final int openingFloat;
  final String? openingNote;
  final DateTime openedAt;

  /// Cash that flowed into the drawer during the shift, on top of the float.
  final int cashIn;

  /// Cash withdrawn during the shift (e.g. petty cash).
  final int cashOut;

  /// Physical cash counted by the cashier at close. Null while open.
  final int? physicalCount;

  /// Server-computed expected drawer total at close:
  /// `openingFloat + cashIn − cashOut + cashRevenue`.
  /// Always null until the shift is closed via the BE.
  final int? expectedCash;

  /// physicalCount − expectedCash.
  /// Positive = lebih; negative = kurang.
  final int? variance;

  final String? closingNote;
  final DateTime? closedAt;

  /// 0 = local-only, 1 = pushed to backend (when backend support lands).
  final int isSync;

  CashSessionModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.shiftLabel,
    required this.openingFloat,
    this.openingNote,
    required this.openedAt,
    this.cashIn = 0,
    this.cashOut = 0,
    this.physicalCount,
    this.expectedCash,
    this.variance,
    this.closingNote,
    this.closedAt,
    this.isSync = 0,
  });

  bool get isOpen => closedAt == null;

  bool get isBalanced => variance != null && variance == 0;

  factory CashSessionModel.fromJson(String str) =>
      CashSessionModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  /// Accepts both:
  /// - BE [CashSessionResource] shape (user_name comes from eager-loaded
  ///   relation, ISO8601 timestamps, has expected_cash / is_open).
  /// - Local SQLite row shape (no expected_cash; ISO timestamps).
  factory CashSessionModel.fromMap(Map<String, dynamic> map) {
    return CashSessionModel(
      id: _asInt(map['id']),
      userId: _resolveUserId(map),
      userName: _resolveUserName(map),
      shiftLabel: (map['shift_label'] as String?) ?? 'Siang',
      openingFloat: _asInt(map['opening_float']) ?? 0,
      openingNote: map['opening_note'] as String?,
      openedAt: DateTime.parse(map['opened_at'] as String),
      cashIn: _asInt(map['cash_in']) ?? 0,
      cashOut: _asInt(map['cash_out']) ?? 0,
      physicalCount: _asInt(map['physical_count']),
      expectedCash: _asInt(map['expected_cash']),
      variance: _asInt(map['variance']),
      closingNote: map['closing_note'] as String?,
      closedAt: map['closed_at'] == null
          ? null
          : DateTime.parse(map['closed_at'] as String),
      isSync: _asInt(map['is_sync']) ?? 0,
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int _resolveUserId(Map<String, dynamic> map) {
    final direct = _asInt(map['user_id']);
    if (direct != null) return direct;
    final user = map['user'];
    if (user is Map<String, dynamic>) {
      return _asInt(user['id']) ?? 0;
    }
    return 0;
  }

  static String _resolveUserName(Map<String, dynamic> map) {
    final direct = map['user_name'] as String?;
    if (direct != null && direct.isNotEmpty) return direct;
    final user = map['user'];
    if (user is Map<String, dynamic>) {
      return (user['name'] as String?) ?? '';
    }
    return '';
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'user_name': userName,
        'shift_label': shiftLabel,
        'opening_float': openingFloat,
        'opening_note': openingNote,
        'opened_at': openedAt.toIso8601String(),
        'cash_in': cashIn,
        'cash_out': cashOut,
        'physical_count': physicalCount,
        'expected_cash': expectedCash,
        'variance': variance,
        'closing_note': closingNote,
        'closed_at': closedAt?.toIso8601String(),
        'is_sync': isSync,
      };

  CashSessionModel copyWith({
    int? id,
    int? userId,
    String? userName,
    String? shiftLabel,
    int? openingFloat,
    String? openingNote,
    DateTime? openedAt,
    int? cashIn,
    int? cashOut,
    int? physicalCount,
    int? expectedCash,
    int? variance,
    String? closingNote,
    DateTime? closedAt,
    int? isSync,
  }) {
    return CashSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      shiftLabel: shiftLabel ?? this.shiftLabel,
      openingFloat: openingFloat ?? this.openingFloat,
      openingNote: openingNote ?? this.openingNote,
      openedAt: openedAt ?? this.openedAt,
      cashIn: cashIn ?? this.cashIn,
      cashOut: cashOut ?? this.cashOut,
      physicalCount: physicalCount ?? this.physicalCount,
      expectedCash: expectedCash ?? this.expectedCash,
      variance: variance ?? this.variance,
      closingNote: closingNote ?? this.closingNote,
      closedAt: closedAt ?? this.closedAt,
      isSync: isSync ?? this.isSync,
    );
  }
}
