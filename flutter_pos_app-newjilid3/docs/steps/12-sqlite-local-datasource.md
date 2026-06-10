# 12 — SQLite Local Datasource + Migration v1→v7

## Goal

`ProductLocalDatasource` (singleton) yang menangani semua tabel SQLite: products, categories, orders, order_items, draft_orders, draft_order_items, cash_sessions, promos. Plus model lokal `OrderModel`, `OrderItem`, `DraftOrderModel`, `DraftOrderItem`. DB version 7 dengan `_onUpgrade` cascading.

## Prerequisite

- Step 11 selesai. Models (`Product`, `Category`) sudah ada.
- Package `sqflite` sudah di pubspec.

## Konsep yang diajarkan

- **Singleton pattern** dengan static instance — 1 koneksi DB untuk seluruh app.
- **`onCreate` vs `onUpgrade`** — schema baru (install fresh) vs migration (user upgrade dari versi lama).
- **DB version bump policy** — wajib tiap ubah schema.
- **`db.transaction` wrap** — atomicity: gagal di tengah → rollback.
- **`COALESCE`** SQL — fallback null ke nilai default.
- **Snake_case columns** SQL standar.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Saya butuh layer local storage SQLite dengan migration. Sudah ada model `Product`, `Category` di `lib/data/models/response/`.

Step ini cukup banyak, mohon generate semua file berikut.

═══════════════════════════════════════════════
FILE 1: lib/presentation/home/models/order_item.dart
═══════════════════════════════════════════════
Class `OrderItem`:
- Field: `final Product product, int quantity (mutable), String? note`.
- Methods:
  - `toMap()` → `{product: product.toMap(), quantity, note}`.
  - `toMapForLocal(int orderId)` → `{id_order: orderId, id_product: product.productId, quantity, price: product.price, note}`.
  - `static OrderItemModel fromMapLocal(Map)` → wrap ke `OrderItemModel(productId, quantity, totalPrice = price*quantity)` (untuk push BE).
  - `factory fromMap(Map)` / `fromJson(String)` / `toJson()` standar.

═══════════════════════════════════════════════
FILE 2: lib/presentation/home/models/draft_order_item.dart
═══════════════════════════════════════════════
Mirip `OrderItem` tapi minus `note`. `toMapForLocal(int orderId)` pakai key `id_draft_order` (bukan `id_order`).

═══════════════════════════════════════════════
FILE 3: lib/presentation/order/models/order_model.dart
═══════════════════════════════════════════════
`OrderModel` — domain model untuk tabel `orders`:
- Field:
  - `int? id, String paymentMethod, int nominalBayar, List<OrderItem> orders, int totalQuantity, int totalPrice, int idKasir, String namaKasir, String transactionTime, bool isSync`.
  - `int? cashSessionId` (FK ke cash_sessions.id), `int? promoId`, `int discountAmount = 0`.
  - V1 refund: `String status = 'paid', String? refundedAt, String? refundReason, String? refundNote, int refundAmount = 0, int? refundedByUserId`.
  - Getter `bool get isRefunded => status == 'refunded'`.
- Methods:
  - `toMap()` (untuk JSON serialization umum, camelCase).
  - `toMapForLocal()` (untuk SQLite, snake_case + isSync 1/0 + semua refund fields).
  - `factory fromLocalMap(Map)` (parse hasil query SQLite, orders empty by default).
  - `factory newFromLocalMap(Map, List<OrderItem>)` (sama tapi orders di-inject).
  - `factory fromMap(Map)` (parse camelCase JSON, untuk dari/ke server kalau pernah).
  - `fromJson` / `toJson`.

═══════════════════════════════════════════════
FILE 4: lib/presentation/order/models/draft_order_model.dart
═══════════════════════════════════════════════
`DraftOrderModel`:
- Field: `int? id, List<DraftOrderItem> orders, int totalQuantity, int totalPrice, String transactionTime, String tableLabel = '', String customerName = '', int tableNumber = 0, String draftName = ''`.
- `tableNumber`/`draftName` adalah legacy field — kept for backcompat, baru pakai `tableLabel`/`customerName`.
- Getter `displayTableLabel` (kalau tableLabel kosong tapi tableNumber > 0 → "Meja N", else tableLabel atau '').
- Getter `displayCustomerName` (customerName ?? draftName).
- `toMapForLocal()` snake_case mengisi semua kolom termasuk legacy.
- Factory `fromLocalMap`, `newFromLocalMap(Map, List<DraftOrderItem>)`.

═══════════════════════════════════════════════
FILE 5: lib/data/datasources/product_local_datasource.dart
═══════════════════════════════════════════════
**Singleton** class `ProductLocalDatasource`:
- Private constructor `_init()`.
- `static final ProductLocalDatasource instance = ProductLocalDatasource._init();`
- `final String tableProducts = 'products';`
- Private `static Database? _database;` + getter:
  ```dart
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos13.db');
    return _database!;
  }
  ```

- `Future<Database> _initDB(String filePath)`:
  ```dart
  final dbPath = await getDatabasesPath();
  final path = dbPath + filePath;
  return await openDatabase(path, version: 7, onCreate: _createDB, onUpgrade: _onUpgrade);
  ```

- `Future<void> _createDB(Database db, int version)`:
  CREATE TABLE untuk 7 tabel (semua sekaligus, untuk fresh install):

  **products** (id, product_id, name, price INTEGER, stock INTEGER, image TEXT, category TEXT, category_id INTEGER, is_best_seller INTEGER, is_sync INTEGER DEFAULT 0)

  **orders** (id, nominal INT, payment_method TEXT, total_item INT, id_kasir INT, nama_kasir TEXT, transaction_time TEXT, is_sync INT DEFAULT 0, cash_session_id INT, promo_id INT, discount_amount INT DEFAULT 0, status TEXT DEFAULT 'paid', refunded_at TEXT, refund_reason TEXT, refund_note TEXT, refund_amount INT DEFAULT 0, refunded_by_user_id INT)

  **promos** (id, name TEXT NOT NULL, type TEXT NOT NULL, value INT NOT NULL DEFAULT 0, code TEXT, applies_to TEXT, min_subtotal INT DEFAULT 0, starts_at TEXT, ends_at TEXT, active INT DEFAULT 1, is_sync INT DEFAULT 0)

  **cash_sessions** (id, user_id INT NOT NULL, user_name TEXT NOT NULL, shift_label TEXT NOT NULL, opening_float INT NOT NULL, opening_note TEXT, opened_at TEXT NOT NULL, cash_in INT DEFAULT 0, cash_out INT DEFAULT 0, physical_count INT, expected_cash INT, variance INT, closing_note TEXT, closed_at TEXT, is_sync INT DEFAULT 0)

  **categories** (id, category_id INT, name TEXT)

  **order_items** (id, id_order INT, id_product INT, quantity INT, price INT, note TEXT)

  **draft_orders** (id, total_item INT, nominal INT, transaction_time TEXT, table_number INT, table_label TEXT, draft_name TEXT, customer_name TEXT)

  **draft_order_items** (id, id_draft_order INT, id_product INT, quantity INT, price INT)

- `Future<void> _onUpgrade(Database db, int oldVersion, int newVersion)`:
  Cascading `if (oldVersion < N)`:
  - **<2**: CREATE TABLE cash_sessions + `ALTER TABLE orders ADD COLUMN cash_session_id INTEGER`.
  - **<3**: `ALTER TABLE cash_sessions ADD COLUMN expected_cash INTEGER`.
  - **<4**: `ALTER TABLE order_items ADD COLUMN note TEXT`.
  - **<5**: `ALTER TABLE draft_orders ADD COLUMN table_label TEXT` + `ADD COLUMN customer_name TEXT`.
  - **<6**: CREATE TABLE promos (skema yang sama dengan onCreate), `ALTER TABLE orders ADD COLUMN promo_id INTEGER`, `ADD COLUMN discount_amount INTEGER DEFAULT 0`.
  - **<7**: 6x `ALTER TABLE orders ADD COLUMN ...` untuk refund (status DEFAULT 'paid', refunded_at, refund_reason, refund_note, refund_amount DEFAULT 0, refunded_by_user_id).

  Mengapa cascading: user upgrade dari v3 → v7 harus jalankan migration v4,v5,v6,v7 secara berurutan.

- Methods (semua public, semua async):
  - **Categories**: `insertAllCategories(List<Category>)`, `removeAllCategories()`, `getAllCategories() → List<Category>`.
  - **Products**: `removeAllProduct()`, `insertAllProduct(List<Product>)` (loop dengan try/catch supaya 1 row gagal gak hentikan), `insertProduct(Product) → Product` (return dengan id baru), `upsertProduct(Product)` (insert atau update by `product_id`), `getAllProduct() → List<Product>`, `getProductById(int) → Product?`.
  - **Orders**:
    - `saveOrder(OrderModel order) → int`: bungkus `db.transaction`. Insert order, lalu loop `order.orders` → insert order_item + `UPDATE products SET stock = COALESCE(stock,0) - ? WHERE product_id = ?`.
    - `getOrderByIsSync() → List<OrderModel>`: query `where: 'is_sync = 0'`.
    - `getOrderItemByOrderIdLocal(int) → List<OrderItemModel>`.
    - `updateIsSyncOrderById(int) → int`: update is_sync = 1.
    - `markOrderRefunded({localOrderId, reason, amount, note?, userId?, refundedAtIso?})`: db.transaction:
      1. UPDATE orders SET status='refunded', refunded_at, refund_reason, refund_note, refund_amount, refunded_by_user_id.
      2. Loop order_items → restore stock `UPDATE products SET stock = COALESCE(stock,0) + ? WHERE product_id = ?`.
      3. Bump `cash_sessions.cash_out` kalau order punya cash_session_id.
    - `getAllOrder() → List<OrderModel>`: query orderBy id DESC. Untuk tiap row: panggil `getOrderItemByOrderId(id)` lalu wrap `OrderModel.newFromLocalMap(row, items)`.
    - `getOrderItemByOrderId(int idOrder) → List<OrderItem>`: query order_items, untuk tiap row: panggil `getProductById(productId)`, kalau null fallback ke placeholder `Product(name: 'Produk dihapus', ...)`. Return `OrderItem(product, quantity)`.
  - **Drafts**: `saveDraftOrder(DraftOrderModel) → int`, `getAllDraftOrder() → List<DraftOrderModel>`, `getDraftOrderItemByOrderId(int) → List<DraftOrderItem>`, `removeDraftOrderById(int)`.

Pakai `import 'package:sqflite/sqflite.dart';` dan `ConflictAlgorithm.replace` saat insert produk (supaya re-sync tidak duplicate).
````

---

## Verifikasi

Quick test di `main.dart`:
```dart
Future<void> testDb() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = ProductLocalDatasource.instance;
  await db.insertAllCategories([Category(id: 1, name: 'Kopi')]);
  final cats = await db.getAllCategories();
  debugPrint('Categories: ${cats.length}'); // 1
}
```

## Talking points

1. **Singleton dengan static `instance`**:
   Pattern paling sederhana di Dart — `_init()` private constructor. Semua callsite pakai `ProductLocalDatasource.instance` — tidak bisa bikin instance baru by accident.

2. **`pos13.db`** sebagai nama file:
   Nama bebas. Inget: kalau ganti nama, user upgrade akan lihat DB kosong (file lama tidak terbaca). Kalau perlu rename → migrate manual ke file baru.

3. **`onCreate` vs `onUpgrade`**:
   - User install pertama → onCreate jalan, version langsung 7.
   - User upgrade dari versi 3 → onUpgrade(3, 7) jalan. Migration v4,v5,v6,v7 dijalankan berurutan.
   - Tanpa onUpgrade → app crash di query karena kolom baru tidak ada.

4. **Cascading `if (oldVersion < N)`** (bukan `switch`):
   `switch (oldVersion)` di Dart hanya match 1 case. Pakai if cascading supaya beberapa migration bisa jalan berurutan untuk user yang skip versi.

5. **`db.transaction((txn) async {})`**:
   - Either semua sukses, atau semua di-rollback.
   - Critical untuk `saveOrder`: insert order + insert order_items + decrement stock harus atomic. Kalau insert item gagal di tengah → stock setengah-setengah berkurang → reconciliation pusing.

6. **`COALESCE(stock, 0) - ?`**:
   Defensive — kalau ada produk dengan stock NULL (legacy data), treat sebagai 0 bukan crash dengan `null - 5 = null`.

7. **`getOrderItemByOrderId` fallback ke placeholder product**:
   Kalau user re-sync produk dengan id baru, history lama bisa point ke product yang sudah hilang. Render "Produk dihapus" daripada crash.

8. **Mengapa version policy ketat?**
   SQLite migration sekali keliru → user bisa lose data. Bangun rasa hati-hati ke peserta: "before bump version, write migration; before write migration, test upgrade path."

## Commit suggestion

```bash
git add lib/presentation/home/models/ lib/presentation/order/models/ lib/data/datasources/product_local_datasource.dart
git commit -m "Step 12: SQLite local datasource v7 with migration cascade"
```

---

➡️ Lanjut ke [Step 13 — Auth Local Datasource](./13-auth-local-datasource.md)
