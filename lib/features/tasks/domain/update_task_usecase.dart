import 'task_entity.dart';
import 'task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) async {
    if (task.title.trim().isEmpty) {
      throw 'Task title cannot be empty';
    }
    await repository.updateTask(task);
  }
}
