import 'task_entity.dart';
import 'task_repository.dart';

class SearchTasksUseCase {
  final TaskRepository repository;

  SearchTasksUseCase(this.repository);

  Future<List<TaskEntity>> call(String userId, String query) async {
    return repository.searchTasks(userId, query);
  }
}
