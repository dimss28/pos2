import 'dart:convert';

class CategoryResponseModel {
  final bool status;
  final String message;
  final List<Category> data;

  CategoryResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryResponseModel.fromJson(String str) =>
      CategoryResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CategoryResponseModel.fromMap(Map<String, dynamic> json) =>
      CategoryResponseModel(
        status: (json["success"] ?? json["status"] ?? true) as bool,
        message: json["message"] ?? '',
        data: json["data"] == null
            ? <Category>[]
            : List<Category>.from(
                (json["data"] as List).map((x) => Category.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class Category {
  final int id;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final int sortOrder;
  final bool isActive;
  final int? productsCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon = 'tag',
    this.color = '#3B82F6',
    this.sortOrder = 0,
    this.isActive = true,
    this.productsCount,
  });

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: _asInt(json['id']) ?? 0,
        name: (json['name'] as String?) ?? '',
        description: json['description'] as String?,
        icon: (json['icon'] as String?) ?? 'tag',
        color: (json['color'] as String?) ?? '#3B82F6',
        sortOrder: _asInt(json['sort_order']) ?? 0,
        isActive: _asBool(json['is_active']) ?? true,
        productsCount: _asInt(json['products_count']),
      );

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == '1' || v == 'true') return true;
      if (v == '0' || v == 'false') return false;
    }
    return null;
  }

  factory Category.fromLocal(Map<String, dynamic> json) => Category(
        id: (json["category_id"] as num?)?.toInt() ?? 0,
        name: (json["name"] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        "category_id": id,
        "name": name,
      };

  @override
  String toString() => name;
}
