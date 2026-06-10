# 10 — Models: Request & Response (handwritten DTO)

## Goal

Bikin model untuk komunikasi dengan Laravel BE: `AuthResponseModel` (login), `Product` + `ProductResponseModel` (katalog), `Category` + `CategoryResponseModel`, dan `OrderRequestModel` (checkout). Plus `Variables` config (base URL via dart-define).

## Prerequisite

- Step 04 selesai.

## Konsep yang diajarkan

- **DTO (Data Transfer Object)** — struktur data yang merepresentasikan payload JSON HTTP.
- **`fromMap` / `toMap` handwritten** — kita pilih ini, bukan `json_serializable`, karena codebase POS sudah pakai pola ini. Lebih simple untuk diajarkan, no codegen step.
- **Defensive parsing** — BE bisa kirim null/string/int campuran, model harus tahan banting (`json["category_id"] is String ? int.tryParse(...) : json["category_id"] ?? 0`).
- **`toLocalMap()`** vs `toMap()` — perbedaan format BE response vs SQLite column.
- **`String.fromEnvironment`** untuk dart-define — base URL configurable tanpa rebuild image.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Generate model & config berikut.

═══════════════════════════════════════════════
FILE 1: lib/core/constants/variables.dart
═══════════════════════════════════════════════
```dart
/// Build-time config. Pakai:
///   flutter run --dart-define=BASE_URL=http://192.168.1.x:8000
class Variables {
  Variables._();
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.18.192:8000',
  );
  static const String imageBaseUrl = '$baseUrl/storage/products/';
}
```

═══════════════════════════════════════════════
FILE 2: lib/data/models/response/auth_response_model.dart
═══════════════════════════════════════════════
2 class: `AuthResponseModel { final User user; final String token; }` dan `User { final int id, name, email, phone, roles; final DateTime? createdAt, updatedAt; }`.

Tiap class punya:
- Constructor named param required.
- `factory fromJson(String str) => fromMap(json.decode(str))`.
- `String toJson() => json.encode(toMap())`.
- `factory fromMap(Map<String, dynamic>)`.
- `Map<String, dynamic> toMap()`.

`User.fromMap` defensive:
- id, name, email, phone, roles → `json["x"] ?? 0` atau `?? ''`.
- createdAt/updatedAt → `json["created_at"] is String ? DateTime.tryParse(json["created_at"]) : null`.

`User.toMap` → tetap pakai `created_at`/`updated_at` (snake_case sesuai BE Laravel), `createdAt?.toIso8601String()`.

`AuthResponseModel.fromMap`:
```dart
AuthResponseModel(
  user: User.fromMap(json["user"]),
  token: json["token"],
)
```

═══════════════════════════════════════════════
FILE 3: lib/data/models/response/product_response_model.dart
═══════════════════════════════════════════════
2 class: `ProductResponseModel { bool success; String message; List<Product> data; }` dan `Product`.

`ProductResponseModel.fromMap`:
- success: `(json["success"] ?? json["status"] ?? true) as bool` (BE kadang kirim "status", kadang "success" — terima keduanya).
- message: `?? ''`.
- data: kalau null → empty list; else map setiap item ke `Product.fromMap`.

`class Product`:
- Field: `id?: int, productId?: int, name: String, description?: String, price: int, stock: int, category: String, categoryId: int, image: String, isBestSeller: bool = false, createdAt?: DateTime, updatedAt?: DateTime`.
- Constructor: `id`/`productId`/`description`/`isBestSeller` optional.

`Product.fromMap` defensive:
- id, productId pass-through.
- name: `?? ''`, description: `?? ''`, price: `?? 0`, stock: `?? 0`.
- category: `json["category"] is String ? json["category"] : ''`.
- categoryId: `json["category_id"] is String ? int.tryParse(...) ?? 0 : json["category_id"] ?? 0`.
- image: `json["image_url"] ?? json["image"] ?? ''` (BE bisa kirim salah satu).
- isBestSeller: `json["is_best_seller"] == true || json["is_best_seller"] == 1`.

2 method serialize:
- `toMap()` (untuk POST BE): name, price, stock, category, category_id, image, is_best_seller (0/1), product_id.
- `toLocalMap()` (untuk SQLite insert): sama, tapi `product_id` pakai `this.id` (id dari BE jadi product_id di lokal).

Getter `String? get displayImageUrl`:
- Kalau `image.isEmpty` → null.
- Kalau `image.startsWith('http')` → return image (sudah URL absolut).
- Else: prepend `Variables.imageBaseUrl`.

Override `==`, `hashCode` berdasarkan id+name+price+stock+image+isBestSeller+createdAt+updatedAt.

`copyWith({...semua field optional...})` return Product baru.

═══════════════════════════════════════════════
FILE 4: lib/data/models/response/category_response_model.dart
═══════════════════════════════════════════════
2 class: `CategoryResponseModel { bool status; String message; List<Category> data; }` dan `Category { int id; String name; }`.

`Category.fromMap` (dari BE): id `?? 0`, name `?? ''`.
`Category.fromLocal(Map)` (dari SQLite query): id dari `category_id`, name dari `name`.
`Category.toMap` (untuk insert SQLite): `{category_id: id, name: name}`.
Override `toString() => name` (memudahkan debug).

═══════════════════════════════════════════════
FILE 5: lib/data/models/request/order_request_model.dart
═══════════════════════════════════════════════
2 class: `OrderRequestModel` dan `OrderItemModel`.

`OrderRequestModel`:
- Field: `transactionTime: String, kasirId: int, totalPrice: int, totalItem: int, orderItems: List<OrderItemModel>, paymentMethod: String = 'cash', promoId?: int, discountAmount: int = 0`.
- fromMap/toMap snake_case (transaction_time, kasir_id, total_price, total_item, payment_method, promo_id, discount_amount, order_items).
- toMap pakai `if (promoId != null) 'promo_id': promoId` supaya gak kirim null.

`OrderItemModel`:
- Field: `productId: int, quantity: int, totalPrice: int`.
- fromMap/toMap snake_case.

Tiap class lengkapi fromJson/toJson dengan `json.encode/decode`.

═══════════════════════════════════════════════
FILE 6 (placeholder, akan ditambah nanti): lib/data/models/request/product_request_model.dart
═══════════════════════════════════════════════
Class `ProductRequestModel` untuk add product (multipart):
- Field: `name, price, stock, category, categoryId, isBestSeller (bool), image: XFile` (dari `image_picker`).
- `toMap() → Map<String, String>` (semua jadi String karena multipart): name, price.toString(), stock.toString(), category, category_id.toString(), is_best_seller "1"/"0".

═══════════════════════════════════════════════
FILE 7: lib/data/models/response/add_product_response_model.dart
═══════════════════════════════════════════════
`AddProductResponseModel { bool success; String message; Product? data; }` dengan fromMap/fromJson standar. `data` nullable karena BE update kadang gak return data.
````

---

## Verifikasi

Tulis test cepat di `main.dart`:
```dart
final json = '{"user":{"id":1,"name":"Saiful","email":"a@b.c","phone":"08","roles":"kasir"},"token":"abc123"}';
final auth = AuthResponseModel.fromJson(json);
debugPrint('${auth.user.name} → ${auth.token}'); // Saiful → abc123
```

## Talking points

1. **Kenapa handwritten, bukan `json_serializable`?**
   - Pros handwritten: zero codegen step, mudah dibaca pemula, fleksibel handle BE inconsistency (kayak `category_id` string vs int).
   - Cons: verbose, bisa typo.
   Pilihan kita: handwritten karena audience pemula dan BE sometimes returns inconsistent types.

2. **Defensive parsing** (`json["x"] ?? 0`, `is String ? ... : ...`):
   BE Laravel kadang return value as string saat ada validator coercion. App jangan crash, jangan tampilkan "null". Pakai default sensible.

3. **`toMap` vs `toLocalMap`**:
   BE pakai `id`, SQLite kita pakai `id INTEGER PRIMARY KEY AUTOINCREMENT` (autoincrement lokal) + `product_id INTEGER` (id BE). `toLocalMap` mapping `id_BE → product_id_local`.

4. **`displayImageUrl` getter**:
   BE Laravel kadang return path relatif (`abc.jpg`), kadang absolute (`https://...`). UI cukup pakai `product.displayImageUrl`, model yang resolve.

5. **`String.fromEnvironment('BASE_URL', defaultValue: ...)`**:
   - Compile-time const. Aman dipakai di `const Variables.baseUrl`.
   - Override saat run: `flutter run --dart-define=BASE_URL=http://staging.com`.
   - Override saat build: `flutter build apk --release --dart-define=BASE_URL=https://prod.com`.

6. **Override `==` & `hashCode` di `Product`**: dibutuhkan kalau Product dipakai di Set, atau di `==` comparison di bloc state. Tanpa ini, dua Product dengan field sama dianggap berbeda.

## Commit suggestion

```bash
git add lib/core/constants/variables.dart lib/data/models/
git commit -m "Step 10: models — auth, product, category, order request"
```

---

➡️ Lanjut ke [Step 11 — Remote Datasources](./11-remote-datasources.md)
