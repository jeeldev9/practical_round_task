import 'task_entity.dart';
import 'task_repository.dart';

class GetTasksPaginatedUseCase {
  final TaskRepository repository;

  GetTasksPaginatedUseCase(this.repository);

  Future<List<TaskEntity>> call(
    String userId, {
    required int offset,
    String? lastFirestoreId,
    int pageSize = 15,
  }) async {
    return repository.getTasksPaginated(
      userId,
      offset: offset,
      lastFirestoreId: lastFirestoreId,
      pageSize: pageSize,
    );
  }
}
