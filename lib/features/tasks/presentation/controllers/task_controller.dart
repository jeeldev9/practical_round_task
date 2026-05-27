import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../notifications/data/notification_service.dart';
import '../../domain/create_task_usecase.dart';
import '../../domain/delete_task_usecase.dart';
import '../../domain/get_tasks_paginated_usecase.dart';
import '../../domain/get_tasks_usecase.dart';
import '../../domain/task_entity.dart';
import '../../domain/update_task_usecase.dart';

class TaskController extends GetxController {
  final GetTasksUseCase getTasksUseCase;
  final GetTasksPaginatedUseCase getTasksPaginatedUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskController({
    required this.getTasksUseCase,
    required this.getTasksPaginatedUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  });

  // Reactive State variables
  final RxList<TaskEntity> tasks = <TaskEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Pagination State ─────────────────────────────────────────────────────────
  static const int _pageSize = 15;
  final RxBool isFetchingMore = false.obs;  // bottom spinner while loading next page
  final RxBool hasMore = true.obs;           // false when last page reached
  int _currentOffset = 0;                    // SQLite OFFSET cursor
  String? _lastFirestoreId;                  // Firestore document cursor

  // Reactive Filters (instant in-memory calculations)
  final RxString searchQuery = ''.obs;
  final RxInt selectedPriorityFilter = 0.obs; // 0 = All, 1 = Low, 2 = Medium, 3 = High
  final RxInt selectedStatusFilter = (-1).obs; // -1 = All, 0 = Active, 1 = Completed

  // Input Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();

  // Reactive Selected Fields for Editor
  final RxInt selectedPriority = 1.obs; // 1 = Low, 2 = Medium, 3 = High
  final Rx<DateTime?> selectedDueDate = Rx<DateTime?>(null);

  // FocusNodes
  final titleFocus = FocusNode();
  final descriptionFocus = FocusNode();

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // Load ALL tasks — used by dashboard stats and initial data.
  // Pagination (loadMoreTasks) is only for task list screen's infinite scroll.
  Future<void> loadTasks() async {
    final authController = Get.find<AuthController>();
    final String? userId = authController.currentUser.value?.uid;
    if (userId == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final loaded = await getTasksUseCase(userId);
      tasks.assignAll(loaded);

      // Reset pagination cursors so task list screen starts fresh
      _currentOffset = loaded.length;
      _lastFirestoreId = loaded.isNotEmpty ? loaded.last.firestoreId : null;
      hasMore.value = loaded.length >= _pageSize;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Append next page — called when user scrolls to the bottom of the list.
  Future<void> loadMoreTasks() async {
    // Guard: don't trigger if already fetching or no more pages
    if (isFetchingMore.value || !hasMore.value) return;

    final authController = Get.find<AuthController>();
    final String? userId = authController.currentUser.value?.uid;
    if (userId == null) return;

    isFetchingMore.value = true;

    try {
      final nextPage = await getTasksPaginatedUseCase(
        userId,
        offset: _currentOffset,
        lastFirestoreId: _lastFirestoreId,
        pageSize: _pageSize,
      );

      if (nextPage.isEmpty || nextPage.length < _pageSize) {
        hasMore.value = false;
      }

      if (nextPage.isNotEmpty) {
        tasks.addAll(nextPage);
        _currentOffset += nextPage.length;
        _lastFirestoreId = nextPage.last.firestoreId;
      }
    } catch (e) {
      // Non-critical: silently fail, user can scroll again to retry
      debugPrint('[TaskController] loadMoreTasks error: $e');
    } finally {
      isFetchingMore.value = false;
    }
  }

  /// Reset pagination and reload from page 1 — used for pull-to-refresh.
  Future<void> refreshTasks() async {
    hasMore.value = true;
    await loadTasks();
  }

  // Computed property to calculate instant in-memory reactive search & filters
  List<TaskEntity> get filteredTasks {
    return tasks.where((task) {
      // 1. Search Query filter (matches in title or description)
      final cleanQuery = searchQuery.value.toLowerCase().trim();
      if (cleanQuery.isNotEmpty) {
        final matchesTitle = task.title.toLowerCase().contains(cleanQuery);
        final matchesDesc = task.description?.toLowerCase().contains(cleanQuery) ?? false;
        if (!matchesTitle && !matchesDesc) return false;
      }

      // 2. Status filter
      if (selectedStatusFilter.value != -1) {
        if (task.status != selectedStatusFilter.value) return false;
      }

      // 3. Priority filter
      if (selectedPriorityFilter.value != 0) {
        if (task.priority != selectedPriorityFilter.value) return false;
      }

      return true;
    }).toList();
  }

  // Populate editor form inputs for editing
  void populateFields(TaskEntity task) {
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
    selectedPriority.value = task.priority;

    if (task.dueDate != null) {
      selectedDueDate.value = DateTime.parse(task.dueDate!);
      dueDateController.text = DateFormat('yyyy-MM-dd').format(selectedDueDate.value!);
    } else {
      selectedDueDate.value = null;
      dueDateController.text = '';
    }
  }

  // Clear inputs when initializing creation form
  void clearFields() {
    titleController.clear();
    descriptionController.clear();
    dueDateController.clear();
    selectedPriority.value = 1;
    selectedDueDate.value = null;
  }

  // Save Task (Create new or Update existing)
  Future<void> saveTask(TaskEntity? existingTask) async {
    final String cleanTitle = titleController.text.trim();
    if (cleanTitle.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Task title cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final authController = Get.find<AuthController>();
    final String? userId = authController.currentUser.value?.uid;
    if (userId == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final dueDateStr = selectedDueDate.value != null
          ? DateFormat('yyyy-MM-dd').format(selectedDueDate.value!)
          : null;

      if (existingTask == null) {
        // Create Usecase Dispatch
        final newTask = TaskEntity(
          title: cleanTitle,
          description: descriptionController.text.trim(),
          priority: selectedPriority.value,
          status: 0, // Defaults to active
          dueDate: dueDateStr,
          userId: userId,
          isSynced: 0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        await createTaskUseCase(newTask);

        // Schedule due-date reminder for new tasks
        if (selectedDueDate.value != null) {
          await _scheduleReminder(cleanTitle, selectedDueDate.value!, dueDateStr);
        }
      } else {
        // Update Usecase Dispatch
        final updatedTask = existingTask.copyWith(
          title: cleanTitle,
          description: descriptionController.text.trim(),
          priority: selectedPriority.value,
          dueDate: dueDateStr,
          isSynced: 0,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await updateUseCase(updatedTask);

        // Re-schedule reminder if due date is set
        if (existingTask.id != null) {
          await _cancelReminder(existingTask.id!);
        }
        if (selectedDueDate.value != null) {
          await _scheduleReminder(cleanTitle, selectedDueDate.value!, dueDateStr);
        }
      }

      await loadTasks(); // Refresh local list
      Get.back(); // Returns to list/dashboard screen
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete Task
  Future<void> deleteTask(TaskEntity task) async {
    try {
      // Remove instantly from list to provide rapid visual feedback
      tasks.removeWhere((t) => t.id == task.id || (task.firestoreId != null && t.firestoreId == task.firestoreId));

      // Cancel any scheduled reminder for this task
      if (task.id != null) await _cancelReminder(task.id!);

      await deleteTaskUseCase(
        task.id?.toString() ?? '',
        task.firestoreId,
      );

      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Re-load to undo changes if operation failed
      await loadTasks();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Toggle status between active (0) and completed (1)
  Future<void> toggleTaskStatus(TaskEntity task) async {
    final int newStatus = task.status == 0 ? 1 : 0;

    // Update inside local list instantly to give rapid visual check feedback
    final index = tasks.indexWhere((t) => t.id == task.id || (task.firestoreId != null && t.firestoreId == task.firestoreId));
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(status: newStatus);
    }

    try {
      final updatedTask = task.copyWith(
        status: newStatus,
        isSynced: 0,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await updateUseCase(updatedTask);
    } catch (_) {
      // Re-load list if sync failed unexpectedly
      await loadTasks();
    }
  }

  // Usecase callback helper mapping
  Future<void> updateUseCase(TaskEntity task) async {
    await updateTaskUseCase(task);
  }

  // ── Notification Helpers ───────────────────────────────────────────────────

  /// Schedule a due-date reminder for the given task.
  /// Uses the SQLite task [id] as the notification ID so it's stable.
  Future<void> _scheduleReminder(
    String title,
    DateTime dueDate,
    String? taskId,
  ) async {
    try {
      final service = Get.find<NotificationService>();
      // Use a hash of title+dueDate as a stable int notification ID
      final notifId = title.hashCode.abs() ^ dueDate.millisecondsSinceEpoch.hashCode.abs();
      await service.scheduleTaskDueReminder(
        notificationId: notifId,
        taskTitle: title,
        dueDate: dueDate,
        taskId: taskId ?? '',
      );
    } catch (e) {
      // Non-critical: don't fail task save if notification scheduling fails
      debugPrint('[TaskController] Notification scheduling failed: $e');
    }
  }

  /// Cancel a previously scheduled reminder.
  Future<void> _cancelReminder(int taskId) async {
    try {
      final service = Get.find<NotificationService>();
      await service.cancelNotification(taskId);
    } catch (_) {}
  }

  // Date selection
  void selectDueDate(DateTime date) {
    selectedDueDate.value = date;
    dueDateController.text = DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();

    titleFocus.dispose();
    descriptionFocus.dispose();

    super.onClose();
  }
}
