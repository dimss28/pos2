import 'package:sqflite/sqflite.dart';

import '../models/response/promo_model.dart';
import 'product_local_datasource.dart';

/// Local cache for promo catalog. Mirror of BE — updated by [SyncBloc]
/// on bootstrap. Used by [DiscountSheet] when offline.
class PromoLocalDatasource {
  PromoLocalDatasource._();
  static final PromoLocalDatasource instance = PromoLocalDatasource._();

  static const String _table = 'promos';

  Future<List<PromoModel>> getAll() async {
    final db = await ProductLocalDatasource.instance.database;
    final rows = await db.query(_table, orderBy: 'active DESC, id DESC');
    return rows.map(PromoModel.fromMap).toList();
  }

  Future<List<PromoModel>> getActive() async {
    final db = await ProductLocalDatasource.instance.database;
    final rows = await db.query(_table,
        where: 'active = 1', orderBy: 'id DESC');
    return rows.map(PromoModel.fromMap).toList();
  }

  Future<PromoModel?> findByCode(String code) async {
    final db = await ProductLocalDatasource.instance.database;
    final rows = await db.query(_table,
        where: 'code = ? COLLATE NOCASE', whereArgs: [code], limit: 1);
    if (rows.isEmpty) return null;
    return PromoModel.fromMap(rows.first);
  }

  Future<void> replaceAll(List<PromoModel> promos) async {
    final db = await ProductLocalDatasource.instance.database;
    await db.transaction((txn) async {
      await txn.delete(_table);
      for (final p in promos) {
        await txn.insert(
          _table,
          {...p.toMap(), 'is_sync': 1},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<int> upsert(PromoModel p) async {
    final db = await ProductLocalDatasource.instance.database;
    return db.insert(_table, p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete(int id) async {
    final db = await ProductLocalDatasource.instance.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
