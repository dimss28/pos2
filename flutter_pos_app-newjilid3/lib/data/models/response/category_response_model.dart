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
        id: (json["id"] as num?)?.toInt() ?? 0,
        name: (json["name"] as String?) ?? '',
        description: json["description"] as String?,
        icon: (json["icon"] as String?) ?? 'tag',
        color: (json["color"] as String?) ?? '#3B82F6',
        sortOrder: (json["sort_order"] as num?)?.toInt() ?? 0,
        isActive: (json["is_active"] as bool?) ?? true,
        productsCount: (json["products_count"] as num?)?.toInt(),
      );

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
