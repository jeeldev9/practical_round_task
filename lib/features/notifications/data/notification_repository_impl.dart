import '../../../core/database/database_helper.dart';
import '../domain/notification_entity.dart';
import '../domain/notification_repository.dart';
import 'notification_model.dart';

/// SQLite-backed implementation of [NotificationRepository].
/// Uses [DatabaseHelper] singleton which is already registered
/// as a permanent GetX service in [InitialBinding].
class NotificationRepositoryImpl implements NotificationRepository {
  final DatabaseHelper _dbHelper;

  static const _table = 'notifications';

  NotificationRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  // ── Read ────────────────────────────────────────────────────────────────────

  @override
  Future<List<NotificationEntity>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => NotificationModel.fromMap(row).toEntity()).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      _table,
      columns: ['COUNT(*) as count'],
      where: 'is_read = ?',
      whereArgs: [0],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // ── Write ───────────────────────────────────────────────────────────────────

  @override
  Future<void> insert(NotificationEntity notification) async {
    final db = await _dbHelper.database;
    final model = NotificationModel.fromEntity(notification);
    await db.insert(_table, model.toMap());
  }

  @override
  Future<void> markAsRead(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markAllAsRead() async {
    final db = await _dbHelper.database;
    await db.update(_table, {'is_read': 1});
  }

  @override
  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete(_table);
  }
}
