import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../user_model.dart';

class AuthLocalDataSource {
  final DatabaseHelper _dbHelper = Get.find<DatabaseHelper>();

  // Cache user details locally in SQFlite database
  Future<void> saveUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      'users_cache',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve user details from SQLite
  Future<UserModel?> getUser(String uid) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users_cache',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  // Delete user cache on logout
  Future<void> deleteUser(String uid) async {
    final db = await _dbHelper.database;
    await db.delete(
      'users_cache',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Fallback option: get the most recently cached user
  Future<UserModel?> getCachedUser() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users_cache',
      orderBy: 'cached_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }
}
