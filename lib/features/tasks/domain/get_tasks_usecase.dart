import 'task_entity.dart';
import 'task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<List<TaskEntity>> call(String userId) async {
    return repository.getTasks(userId);
  }
}
