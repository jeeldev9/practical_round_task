import 'task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(String localId, String? firestoreId) async {
    await repository.deleteTask(localId, firestoreId);
  }
}
