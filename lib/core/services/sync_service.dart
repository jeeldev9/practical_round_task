import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../database/database_helper.dart';

class SyncService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loops through and synchronizes SQLite offline queued edits with Firestore
  Future<void> syncPendingActions() async {
    try {
      final DatabaseHelper dbHelper = Get.find<DatabaseHelper>();
      final db = await dbHelper.database;

      // 1. Fetch pending actions sorted oldest first
      final List<Map<String, dynamic>> actions = await db.query(
        'pending_actions',
        orderBy: 'id ASC',
      );

      if (actions.isEmpty) return;

      for (var action in actions) {
        final int actionId = action['id'] as int;
        final String actionType = action['action_type'] as String;
        final Map<String, dynamic> payload = jsonDecode(action['payload_json'] as String) as Map<String, dynamic>;

        try {
          if (actionType == 'CREATE') {
            final int localId = payload['localId'] as int;

            // Send CREATE to Cloud Firestore
            final DocumentReference ref = await _firestore.collection('tasks').add({
              'title': payload['title'],
              'description': payload['description'],
              'priority': payload['priority'],
              'status': payload['status'],
              'dueDate': payload['dueDate'],
              'userId': payload['userId'],
              'createdAt': payload['createdAt'],
              'updatedAt': payload['updatedAt'],
            });

            // Update local SQLite record with generated Document ID
            await db.update(
              'tasks',
              {
                'firestore_id': ref.id,
                'is_synced': 1,
              },
              where: 'id = ?',
              whereArgs: [localId],
            );
          } else if (actionType == 'UPDATE') {
            final int localId = payload['localId'] as int;
            final String? firestoreId = payload['firestoreId'] as String?;

            if (firestoreId != null) {
              await _firestore.collection('tasks').doc(firestoreId).set({
                'title': payload['title'],
                'description': payload['description'],
                'priority': payload['priority'],
                'status': payload['status'],
                'dueDate': payload['dueDate'],
                'userId': payload['userId'],
                'createdAt': payload['createdAt'],
                'updatedAt': payload['updatedAt'],
              });

              // Mark as synced locally
              await db.update(
                'tasks',
                {'is_synced': 1},
                where: 'id = ?',
                whereArgs: [localId],
              );
            }
          } else if (actionType == 'DELETE') {
            final String? firestoreId = payload['firestoreId'] as String?;
            if (firestoreId != null) {
              await _firestore.collection('tasks').doc(firestoreId).delete();
            }
          }

          // Delete processed action from queue on success
          await db.delete(
            'pending_actions',
            where: 'id = ?',
            whereArgs: [actionId],
          );
        } catch (_) {
          // If any individual sync fails (e.g. timeout), break loop to preserve queue order
          break;
        }
      }
    } catch (_) {
      // Catch exceptions silently during service initialization
    }
  }
}
