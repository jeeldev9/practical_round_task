import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/task_controller.dart';
import '../../domain/task_entity.dart';

class TaskDetailScreen extends GetView<TaskController> {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receive selected task from routing arguments
    final TaskEntity task = Get.arguments as TaskEntity;

    // Reactively compute local task details in case status changes
    return Obx(() {
      // Fetch latest reactive state in case details or status updated
      final TaskEntity currentTask = controller.tasks.firstWhere(
        (t) => t.id == task.id || (task.firestoreId != null && t.firestoreId == task.firestoreId),
        orElse: () => task,
      );

      final isCompleted = currentTask.status == 1;

      Color priorityColor;
      String priorityText;
      switch (currentTask.priority) {
        case 3:
          priorityColor = AppColors.priorityHigh;
          priorityText = 'High';
          break;
        case 2:
          priorityColor = AppColors.priorityMedium;
          priorityText = 'Medium';
          break;
        case 1:
        default:
          priorityColor = AppColors.priorityLow;
          priorityText = 'Low';
          break;
      }

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Task Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            // Edit Button
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                controller.populateFields(currentTask);
                Get.toNamed(AppRoutes.createEditTask, arguments: currentTask);
              },
            ),
            // Delete Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              onPressed: () {
                _showDeleteConfirmation(context, currentTask);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Task Header / Status Check
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isCompleted ? AppColors.success : Theme.of(context).colorScheme.outline,
                            size: 32,
                          ),
                          onPressed: () => controller.toggleTaskStatus(currentTask),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCompleted ? 'Task Completed' : 'Task Active',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCompleted ? 'Mark active to edit details' : 'Complete to close task',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Task Details Box
                Text(
                  currentTask.title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // Priority & Due Date Badges row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$priorityText Priority',
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (currentTask.dueDate != null && currentTask.dueDate!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentTask.dueDate!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    // Synced badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (currentTask.isSynced == 1 ? AppColors.success : AppColors.priorityMedium).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        currentTask.isSynced == 1 ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: currentTask.isSynced == 1 ? AppColors.success : AppColors.priorityMedium,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description Title & Panel
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTask.description != null && currentTask.description!.isNotEmpty
                      ? currentTask.description!
                      : 'No description provided.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showDeleteConfirmation(BuildContext context, TaskEntity task) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Task',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to permanently delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTask(task);
              Get.back(); // Closes dialog
              Get.back(); // Returns to task list screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
