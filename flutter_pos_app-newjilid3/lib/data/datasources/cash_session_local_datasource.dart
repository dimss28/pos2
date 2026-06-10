import 'package:sqflite/sqflite.dart';

import '../models/response/cash_session_model.dart';
import 'product_local_datasource.dart';

/// CRUD for `cash_sessions` table. Reuses the same `pos13.db` instance
/// managed by [ProductLocalDatasource] — there is exactly one Database
/// singleton in the app, keyed by version 2.
///
/// Backend sync support will be added later; for now everything is local
/// and `is_sync = 0` for every row.
class CashSessionLocalDatasource {
  CashSessionLocalDatasource._();
  static final CashSessionLocalDatasource instance =
      CashSessionLocalDatasource._();

  static const String _table = 'cash_sessions';

  /// Returns the open (`closed_at IS NULL`) session for [userId], or null
  /// if the cashier needs to open a new shift.
  Future<CashSessionModel?> getCurrentOpen(int userId) async {
    final db = await ProductLocalDatasource.instance.database;
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND closed_at IS NULL',
      whereArgs: [userId],
      orderBy: 'opened_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CashSessionModel.fromMap(rows.first);
  }

  /// Returns the most recently closed session (any user) — used to show
  /// the "Shift sebelumnya" recap on [BukaKasirPage].
  Future<CashSessionModel?> getLastClosed() async {
    final db = await ProductLocalDatasource.instance.database;
    final rows = await db.query(
      _table,
      where: 'closed_at IS NOT NULL',
      orderBy: 'closed_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CashSessionModel.fromMap(rows.first);
  }

  /// Insert a new open session. Returns the row id.
  Future<int> openSession(CashSessionModel session) async {
    final db = await ProductLocalDatasource.instance.database;
    return db.insert(_table, session.toMap());
  }

  /// Mark a session closed. Caller pre-computes [physicalCount] / [variance]
  /// / [cashIn] / [cashOut] and passes them via [updated].
  Future<int> closeSession(CashSessionModel updated) async {
    assert(updated.id != null, 'cash_session.id required for close');
    final db = await ProductLocalDatasource.instance.database;
    return db.update(
      _table,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  /// Mirror a row received from the backend into the local cache. Uses
  /// `INSERT OR REPLACE` keyed on the server-side `id` so subsequent reads
  /// (e.g. recap card on BukaKasirPage) match what the server returned.
  Future<void> upsertFromRemote(CashSessionModel s) async {
    assert(s.id != null, 'cash_session.id required for upsert');
    final db = await ProductLocalDatasource.instance.database;
    await db.insert(
      _table,
      {...s.toMap(), 'is_sync': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Sum of paid cash orders attached to [sessionId] — drives the expected
  /// cash calculation on the Tutup Kasir page.
  Future<int> cashRevenueForSession(int sessionId) async {
    final db = await ProductLocalDatasource.instance.database;
    final rows = await db.rawQuery(
      "SELECT COALESCE(SUM(nominal), 0) AS total "
      "FROM orders WHERE cash_session_id = ? AND payment_method = 'Tunai'",
      [sessionId],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  /// Total order count for [sessionId].
  Future<int> orderCountForSession(int sessionId) async {
    final db = await ProductLocalDatasource.instance.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM orders WHERE cash_session_id = ?',
      [sessionId],
    );
    return (rows.first['c'] as int?) ?? 0;
  }
}
