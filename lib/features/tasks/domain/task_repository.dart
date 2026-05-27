import 'task_entity.dart';

abstract class TaskRepository {
  /// Load all tasks (used on first load — returns locally cached data).
  Future<List<TaskEntity>> getTasks(String userId);

  /// Cursor-based paginated fetch.
  /// [offset] = how many local rows to skip (SQLite OFFSET).
  /// [lastFirestoreId] = last Firestore document ID seen (cloud cursor).
  /// [pageSize] = number of tasks per page (default 15).
  Future<List<TaskEntity>> getTasksPaginated(
    String userId, {
    required int offset,
    String? lastFirestoreId,
    int pageSize,
  });

  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String localId, String? firestoreId);
  Future<List<TaskEntity>> searchTasks(String userId, String query);
}
