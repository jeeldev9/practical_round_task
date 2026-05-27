import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/connectivity_service.dart';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';
import 'task_model.dart';

/// Page size constant — 15 tasks per page.
const int kPageSize = 15;

class TaskRepositoryImpl implements TaskRepository {
  final DatabaseHelper _dbHelper = Get.find<DatabaseHelper>();
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<TaskEntity>> getTasks(String userId) async {
    // 1. Instantly return locally cached SQLite records for zero-delay UI rendering
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    final localTasks = maps.map((m) => TaskModel.fromMap(m).toEntity()).toList();

    // 2. Fetch updates from cloud in the background if the device is currently online
    if (_connectivityService.isConnected.value) {
      try {
        final QuerySnapshot snapshot = await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: userId)
            .get();

        final batch = db.batch();
        for (var doc in snapshot.docs) {
          final remoteModel = TaskModel.fromFirestore(doc);
          final List<Map<String, dynamic>> localCheck = await db.query(
            'tasks',
            where: 'firestore_id = ?',
            whereArgs: [doc.id],
          );

          if (localCheck.isEmpty) {
            batch.insert(
              'tasks',
              remoteModel.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else {
            final int localId = localCheck.first['id'] as int;
            final updatedModel = TaskModel(
              id: localId,
              firestoreId: doc.id,
              title: remoteModel.title,
              description: remoteModel.description,
              priority: remoteModel.priority,
              status: remoteModel.status,
              dueDate: remoteModel.dueDate,
              userId: remoteModel.userId,
              isSynced: 1,
              createdAt: remoteModel.createdAt,
              updatedAt: remoteModel.updatedAt,
            );
            batch.update(
              'tasks',
              updatedModel.toMap(),
              where: 'id = ?',
              whereArgs: [localId],
            );
          }
        }
        await batch.commit(noResult: true);

        // Re-read local database to capture synchronized cloud changes
        final List<Map<String, dynamic>> updatedMaps = await db.query(
          'tasks',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'id DESC',
        );
        return updatedMaps.map((m) => TaskModel.fromMap(m).toEntity()).toList();
      } catch (_) {
        // Fallback gracefully to local results on network glitches
      }
    }

    return localTasks;
  }

  // ── Paginated Fetch ──────────────────────────────────────────────────────────

  @override
  Future<List<TaskEntity>> getTasksPaginated(
    String userId, {
    required int offset,
    String? lastFirestoreId,
    int pageSize = kPageSize,
  }) async {
    final db = await _dbHelper.database;

    // 1. Always return local page instantly (SQLite LIMIT + OFFSET)
    final List<Map<String, dynamic>> localMaps = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
      limit: pageSize,
      offset: offset,
    );
    final localPage = localMaps.map((m) => TaskModel.fromMap(m).toEntity()).toList();

    // 2. Sync next page from Firestore if online
    if (_connectivityService.isConnected.value) {
      try {
        // Build base query — ordered by createdAt for stable cursor pagination
        Query<Map<String, dynamic>> query = _firestore
            .collection('tasks')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(pageSize);

        // Apply cursor: skip all docs before the last seen document
        if (lastFirestoreId != null) {
          final lastDoc = await _firestore
              .collection('tasks')
              .doc(lastFirestoreId)
              .get();
          if (lastDoc.exists) {
            query = query.startAfterDocument(lastDoc);
          }
        }

        final QuerySnapshot snapshot = await query.get();

        // Merge cloud results into local SQLite (upsert)
        final batch = db.batch();
        for (var doc in snapshot.docs) {
          final remoteModel = TaskModel.fromFirestore(doc);
          final List<Map<String, dynamic>> existing = await db.query(
            'tasks',
            where: 'firestore_id = ?',
            whereArgs: [doc.id],
          );

          if (existing.isEmpty) {
            batch.insert(
              'tasks',
              remoteModel.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else {
            final int localId = existing.first['id'] as int;
            batch.update(
              'tasks',
              TaskModel(
                id: localId,
                firestoreId: doc.id,
                title: remoteModel.title,
                description: remoteModel.description,
                priority: remoteModel.priority,
                status: remoteModel.status,
                dueDate: remoteModel.dueDate,
                userId: remoteModel.userId,
                isSynced: 1,
                createdAt: remoteModel.createdAt,
                updatedAt: remoteModel.updatedAt,
              ).toMap(),
              where: 'id = ?',
              whereArgs: [localId],
            );
          }
        }
        await batch.commit(noResult: true);

        // Re-read the same page from local after merge to get accurate results
        final List<Map<String, dynamic>> mergedMaps = await db.query(
          'tasks',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'id DESC',
          limit: pageSize,
          offset: offset,
        );
        return mergedMaps.map((m) => TaskModel.fromMap(m).toEntity()).toList();
      } catch (_) {
        // Graceful fallback to local page on any network error
      }
    }

    return localPage;
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final db = await _dbHelper.database;
    final model = TaskModel.fromEntity(task);

    // 1. Insert into local SQLite database immediately to make the UI ultra-responsive
    final int localId = await db.insert(
      'tasks',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 2. Check if we can sync to cloud
    if (_connectivityService.isConnected.value) {
      try {
        final DocumentReference ref = await _firestore.collection('tasks').add({
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'status': task.status,
          'dueDate': task.dueDate,
          'userId': task.userId,
          'createdAt': task.createdAt ?? DateTime.now().toIso8601String(),
          'updatedAt': task.updatedAt ?? DateTime.now().toIso8601String(),
        });

        // Update local database with assigned Firestore Document ID
        await db.update(
          'tasks',
          {
            'firestore_id': ref.id,
            'is_synced': 1,
          },
          where: 'id = ?',
          whereArgs: [localId],
        );
        return;
      } catch (_) {
        // Fallback to offline queue below on exception
      }
    }

    // 3. Fallback: Queue offline CREATE action in SQLite pending_actions queue
    final payload = {
      'localId': localId,
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'status': task.status,
      'dueDate': task.dueDate,
      'userId': task.userId,
      'createdAt': task.createdAt ?? DateTime.now().toIso8601String(),
      'updatedAt': task.updatedAt ?? DateTime.now().toIso8601String(),
    };

    await db.insert('pending_actions', {
      'action_type': 'CREATE',
      'payload_json': jsonEncode(payload),
      'task_id': localId.toString(),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final db = await _dbHelper.database;
    final model = TaskModel.fromEntity(task);

    // 1. Update local SQLite task record immediately
    await db.update(
      'tasks',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    // 2. Check if we can sync to cloud
    if (_connectivityService.isConnected.value && task.firestoreId != null) {
      try {
        await _firestore.collection('tasks').doc(task.firestoreId).set({
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'status': task.status,
          'dueDate': task.dueDate,
          'userId': task.userId,
          'createdAt': task.createdAt,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Set is_synced = 1 in SQLite
        await db.update(
          'tasks',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [task.id],
        );
        return;
      } catch (_) {
        // Fallback to queue below
      }
    }

    // 3. Fallback: Queue offline UPDATE action in SQLite
    final payload = {
      'localId': task.id,
      'firestoreId': task.firestoreId,
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'status': task.status,
      'dueDate': task.dueDate,
      'userId': task.userId,
      'createdAt': task.createdAt,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await db.insert('pending_actions', {
      'action_type': 'UPDATE',
      'payload_json': jsonEncode(payload),
      'task_id': task.id?.toString(),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });

    // Mark as unsynced locally
    await db.update(
      'tasks',
      {'is_synced': 0},
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String localId, String? firestoreId) async {
    final db = await _dbHelper.database;
    final int parsedId = int.tryParse(localId) ?? 0;

    // 1. Delete from local SQLite immediately
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [parsedId],
    );

    // 2. Check if we can sync to cloud
    if (_connectivityService.isConnected.value && firestoreId != null) {
      try {
        await _firestore.collection('tasks').doc(firestoreId).delete();
        return;
      } catch (_) {
        // Fallback to queue below
      }
    }

    // 3. Fallback: Queue offline DELETE action in SQLite
    final payload = {
      'localId': parsedId,
      'firestoreId': firestoreId,
    };

    await db.insert('pending_actions', {
      'action_type': 'DELETE',
      'payload_json': jsonEncode(payload),
      'task_id': localId,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  @override
  Future<List<TaskEntity>> searchTasks(String userId, String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'user_id = ? AND (title LIKE ? OR description LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'id DESC',
    );
    return maps.map((m) => TaskModel.fromMap(m).toEntity()).toList();
  }
}
