import 'package:get/get.dart';

import 'data/task_repository_impl.dart';
import 'domain/create_task_usecase.dart';
import 'domain/delete_task_usecase.dart';
import 'domain/get_tasks_paginated_usecase.dart';
import 'domain/get_tasks_usecase.dart';
import 'domain/search_tasks_usecase.dart';
import 'domain/task_repository.dart';
import 'domain/update_task_usecase.dart';
import 'presentation/controllers/task_controller.dart';

class TasksBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskRepository>(() => TaskRepositoryImpl());

    Get.lazyPut(() => GetTasksUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => GetTasksPaginatedUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => CreateTaskUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => UpdateTaskUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => DeleteTaskUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => SearchTasksUseCase(Get.find<TaskRepository>()));

    Get.lazyPut(() => TaskController(
          getTasksUseCase: Get.find<GetTasksUseCase>(),
          getTasksPaginatedUseCase: Get.find<GetTasksPaginatedUseCase>(),
          createTaskUseCase: Get.find<CreateTaskUseCase>(),
          updateTaskUseCase: Get.find<UpdateTaskUseCase>(),
          deleteTaskUseCase: Get.find<DeleteTaskUseCase>(),
        ));
  }
}
