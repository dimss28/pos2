import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../presentation/home/models/draft_order_item.dart';
import '../../presentation/home/models/order_item.dart';
import '../../presentation/order/models/draft_order_model.dart';
import '../models/request/order_request_model.dart';
import '../models/response/category_response_model.dart';

class ProductLocalDatasource {
  ProductLocalDatasource._init();

  static final ProductLocalDatasource instance = ProductLocalDatasource._init();

  final String tableProducts = 'products';

  static Database? _database;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE cash_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          user_name TEXT NOT NULL,
          shift_label TEXT NOT NULL,
          opening_float INTEGER NOT NULL,
          opening_note TEXT,
          opened_at TEXT NOT NULL,
          cash_in INTEGER DEFAULT 0,
          cash_out INTEGER DEFAULT 0,
          physical_count INTEGER,
          variance INTEGER,
          closing_note TEXT,
          closed_at TEXT,
          is_sync INTEGER DEFAULT 0
        )
      ''');
      await db.execute(
        'ALTER TABLE orders ADD COLUMN cash_session_id INTEGER',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE cash_sessions ADD COLUMN expected_cash INTEGER',
      );
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE order_items ADD COLUMN note TEXT');
    }
    if (oldVersion < 5) {
      await db
          .execute('ALTER TABLE draft_orders ADD COLUMN table_label TEXT');
      await db
          .execute('ALTER TABLE draft_orders ADD COLUMN customer_name TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE promos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          value INTEGER NOT NULL DEFAULT 0,
          code TEXT,
          applies_to TEXT,
          min_subtotal INTEGER DEFAULT 0,
          starts_at TEXT,
          ends_at TEXT,
          active INTEGER DEFAULT 1,
          is_sync INTEGER DEFAULT 0
        )
      ''');
      await db
          .execute('ALTER TABLE orders ADD COLUMN promo_id INTEGER');
      await db
          .execute('ALTER TABLE orders ADD COLUMN discount_amount INTEGER DEFAULT 0');
    }
    if (oldVersion < 7) {
      // V1 refund: full-only, controlled vocab reason + free-text note.
      // We track refund state with two columns so legacy local rows (paid)
      // still render correctly when refunded_at is null.
      await db.execute(
        "ALTER TABLE orders ADD COLUMN status TEXT DEFAULT 'paid'",
      );
      await db.execute('ALTER TABLE orders ADD COLUMN refunded_at TEXT');
      await db.execute('ALTER TABLE orders ADD COLUMN refund_reason TEXT');
      await db.execute('ALTER TABLE orders ADD COLUMN refund_note TEXT');
      await db.execute(
        'ALTER TABLE orders ADD COLUMN refund_amount INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE orders ADD COLUMN refunded_by_user_id INTEGER',
      );
    }
    if (oldVersion < 8) {
      // Idempotency key: generate UUID v4 saat order dibuat lokal, kirim ke
      // BE saat sync. BE check duplikat by client_uuid → tidak double-process.
      await db.execute('ALTER TABLE orders ADD COLUMN client_uuid TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        name TEXT,
        price INTEGER,
        stock INTEGER,
        image TEXT,
        category TEXT,
        category_id INTEGER,
        is_best_seller INTEGER,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_uuid TEXT,
        nominal INTEGER,
        payment_method TEXT,
        total_item INTEGER,
        id_kasir INTEGER,
        nama_kasir TEXT,
        transaction_time TEXT,
        is_sync INTEGER DEFAULT 0,
        cash_session_id INTEGER,
        promo_id INTEGER,
        discount_amount INTEGER DEFAULT 0,
        status TEXT DEFAULT 'paid',
        refunded_at TEXT,
        refund_reason TEXT,
        refund_note TEXT,
        refund_amount INTEGER DEFAULT 0,
        refunded_by_user_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE promos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        value INTEGER NOT NULL DEFAULT 0,
        code TEXT,
        applies_to TEXT,
        min_subtotal INTEGER DEFAULT 0,
        starts_at TEXT,
        ends_at TEXT,
        active INTEGER DEFAULT 1,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE cash_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        user_name TEXT NOT NULL,
        shift_label TEXT NOT NULL,
        opening_float INTEGER NOT NULL,
        opening_note TEXT,
        opened_at TEXT NOT NULL,
        cash_in INTEGER DEFAULT 0,
        cash_out INTEGER DEFAULT 0,
        physical_count INTEGER,
        expected_cash INTEGER,
        variance INTEGER,
        closing_note TEXT,
        closed_at TEXT,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    //categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE draft_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_item INTEGER,
        nominal INTEGER,
        transaction_time TEXT,
        table_number INTEGER,
        table_label TEXT,
        draft_name TEXT,
        customer_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE draft_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_draft_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');
  }

  //insert all categories
  Future<void> insertAllCategories(List<Category> categories) async {
    final db = await instance.database;
    for (var category in categories) {
      await db.insert('categories', category.toMap());
    }
  }

  //delete all categories
  Future<void> removeAllCategories() async {
    final db = await instance.database;
    await db.delete('categories');
  }

  //get all categories
  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');

    return result.map((e) => Category.fromLocal(e)).toList();
  }

  //save order
  Future<int> saveOrder(OrderModel order) async {
    final db = await instance.database;
    // Wrap in a transaction so partial inserts (e.g. one item OK, the next
    // fails) don't leave the catalog stock half-decremented.
    return db.transaction((txn) async {
      final id = await txn.insert('orders', order.toMapForLocal());
      for (final orderItem in order.orders) {
        await txn.insert('order_items', orderItem.toMapForLocal(id));

        // V1 stock decrement: mirror the BE so the local catalog stays in
        // sync even while offline. Negative values are not blocked here —
        // the FE cart guard prevents over-add; race conditions surface in
        // reports.
        final productId = orderItem.product.productId ?? orderItem.product.id;
        final qty = orderItem.quantity;
        if (productId != null && qty > 0) {
          await txn.rawUpdate(
            'UPDATE products SET stock = COALESCE(stock, 0) - ? WHERE product_id = ?',
            [qty, productId],
          );
        }
      }
      return id;
    });
  }

  //save draft order
  Future<int> saveDraftOrder(DraftOrderModel order) async {
    final db = await instance.database;
    int id = await db.insert('draft_orders', order.toMapForLocal());
    for (var orderItem in order.orders) {
      await db.insert('draft_order_items', orderItem.toMapForLocal(id));
    }
    return id;
  }

  //get all draft order
  Future<List<DraftOrderModel>> getAllDraftOrder() async {
    final db = await instance.database;
    final result = await db.query('draft_orders', orderBy: 'id ASC');

    List<DraftOrderModel> results = await Future.wait(result.map((item) async {
      // Your asynchronous operation here
      final draftOrderItem =
          await getDraftOrderItemByOrderId(item['id'] as int);
      return DraftOrderModel.newFromLocalMap(item, draftOrderItem);
    }));
    return results;
  }

  //get draft order item by id order
  Future<List<DraftOrderItem>> getDraftOrderItemByOrderId(int idOrder) async {
    final db = await instance.database;
    final result =
        await db.query('draft_order_items', where: 'id_draft_order = $idOrder');

    List<DraftOrderItem> results = await Future.wait(result.map((item) async {
      // Your asynchronous operation here
      final product = await getProductById(item['id_product'] as int);
      return DraftOrderItem(
          product: product!, quantity: item['quantity'] as int);
    }));
    return results;
  }

  //remove draft order by id
  Future<void> removeDraftOrderById(int id) async {
    final db = await instance.database;
    await db.delete('draft_orders', where: 'id = ?', whereArgs: [id]);
    await db.delete('draft_order_items',
        where: 'id_draft_order = ?', whereArgs: [id]);
  }

  //get order by isSync = 0
  Future<List<OrderModel>> getOrderByIsSync() async {
    final db = await instance.database;
    final result = await db.query('orders', where: 'is_sync = 0');

    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get order item by id order
  Future<List<OrderItemModel>> getOrderItemByOrderIdLocal(int idOrder) async {
    final db = await instance.database;
    final result = await db.query('order_items', where: 'id_order = $idOrder');

    return result.map((e) => OrderItem.fromMapLocal(e)).toList();
  }

  //update isSync order by id
  Future<int> updateIsSyncOrderById(int id) async {
    final db = await instance.database;
    return await db.update('orders', {'is_sync': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  /// V1 refund: mark a local order as refunded and restore stock for each
  /// line item. Wrapped in a transaction so a failed stock update doesn't
  /// leave the order half-refunded.
  Future<void> markOrderRefunded({
    required int localOrderId,
    required String reason,
    required int amount,
    String? note,
    int? userId,
    String? refundedAtIso,
  }) async {
    final db = await instance.database;
    final ts = refundedAtIso ?? DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.update(
        'orders',
        {
          'status': 'refunded',
          'refunded_at': ts,
          'refund_reason': reason,
          'refund_note': note,
          'refund_amount': amount,
          'refunded_by_user_id': userId,
        },
        where: 'id = ?',
        whereArgs: [localOrderId],
      );

      // Restore stock per line item.
      final items = await txn.query(
        'order_items',
        where: 'id_order = ?',
        whereArgs: [localOrderId],
      );
      for (final item in items) {
        final productId = (item['product_id'] as num?)?.toInt();
        final qty = (item['quantity'] as num?)?.toInt() ?? 0;
        if (productId != null && qty > 0) {
          await txn.rawUpdate(
            'UPDATE products SET stock = COALESCE(stock, 0) + ? WHERE product_id = ?',
            [qty, productId],
          );
        }
      }

      // Bump cash_out on the originating shift so closing recap balances.
      final orderRow = await txn.query(
        'orders',
        columns: ['cash_session_id'],
        where: 'id = ?',
        whereArgs: [localOrderId],
        limit: 1,
      );
      final cashSessionId =
          (orderRow.firstOrNull?['cash_session_id'] as num?)?.toInt();
      if (cashSessionId != null) {
        await txn.rawUpdate(
          'UPDATE cash_sessions SET cash_out = COALESCE(cash_out, 0) + ? WHERE id = ?',
          [amount, cashSessionId],
        );
      }
    });
  }

  //get all orders
  Future<List<OrderModel>> getAllOrder() async {
    final db = await instance.database;
    final result = await db.query('orders', orderBy: 'id DESC');

    List<OrderModel> results = await Future.wait(result.map((item) async {
      // Your asynchronous operation here
      final orderItem = await getOrderItemByOrderId(item['id'] as int);
      return OrderModel.newFromLocalMap(item, orderItem);
    }));
    return results;
    // return result.map((e) {
    //   return OrderModel.fromLocalMap(e);
    // }).toList();
  }

  //get order item by id order
  Future<List<OrderItem>> getOrderItemByOrderId(int idOrder) async {
    final db = await instance.database;
    final result = await db.query('order_items', where: 'id_order = $idOrder');

    List<OrderItem> results = await Future.wait(result.map((item) async {
      final productId = (item['id_product'] as num?)?.toInt() ?? 0;
      final qty = (item['quantity'] as num?)?.toInt() ?? 0;
      final price = (item['price'] as num?)?.toInt() ?? 0;
      var product = await getProductById(productId);
      // A re-sync may have wiped the product row (different IDs from BE).
      // Render a placeholder so historical orders don't crash the page.
      product ??= Product(
        id: productId,
        productId: productId,
        name: 'Produk dihapus',
        description: '',
        price: price,
        stock: 0,
        category: '',
        categoryId: 0,
        image: '',
      );
      return OrderItem(product: product, quantity: qty);
    }));
    return results;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('pos13.db');
    return _database!;
  }

  //remove all data product
  Future<void> removeAllProduct() async {
    final db = await instance.database;
    await db.delete(tableProducts);
  }

  //insert data product from list product
  Future<void> insertAllProduct(List<Product> products) async {
    final db = await instance.database;
    for (var product in products) {
      try {
        await db.insert(
          tableProducts,
          product.toLocalMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        // Skip this row but keep going — a single bad record (e.g. unexpected
        // null/type from BE) should not truncate the entire catalog.
        // ignore: avoid_print
        print('[ProductLocal] insert failed for ${product.name}: $e');
      }
    }
  }

  //isert data product
  Future<Product> insertProduct(Product product) async {
    final db = await instance.database;
    int id = await db.insert(tableProducts, product.toMap());
    return product.copyWith(id: id);
  }

  /// Insert if absent, otherwise update by `product_id`. Used by the edit
  /// flow so the manage list and home grid show the fresh row without
  /// needing a full re-sync.
  Future<void> upsertProduct(Product product) async {
    final db = await instance.database;
    final remoteId = product.id;
    if (remoteId == null) {
      await db.insert(tableProducts, product.toLocalMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return;
    }
    final existing = await db.query(
      tableProducts,
      where: 'product_id = ?',
      whereArgs: [remoteId],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert(tableProducts, product.toLocalMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.update(
        tableProducts,
        product.toLocalMap(),
        where: 'product_id = ?',
        whereArgs: [remoteId],
      );
    }
  }

  //get all data product
  Future<List<Product>> getAllProduct() async {
    final db = await instance.database;
    final result = await db.query(tableProducts);

    final out = <Product>[];
    for (final row in result) {
      try {
        out.add(Product.fromMap(row));
      } catch (_) {
        // skip malformed row instead of blanking out the entire list
      }
    }
    return out;
  }

  //get product by id
  Future<Product?> getProductById(int id) async {
    final db = await instance.database;
    final result =
        await db.query(tableProducts, where: 'product_id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return Product.fromMap(result.first);
  }
}
