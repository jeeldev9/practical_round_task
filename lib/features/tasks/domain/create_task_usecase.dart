import 'task_entity.dart';
import 'task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) async {
    if (task.title.trim().isEmpty) {
      throw 'Task title cannot be empty';
    }
    await repository.createTask(task);
  }
}
