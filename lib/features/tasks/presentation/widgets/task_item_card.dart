import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/task_entity.dart';
import '../controllers/task_controller.dart';

class TaskItemCard extends GetView<TaskController> {
  final TaskEntity task;

  const TaskItemCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 1;

    // Map Priority Levels to custom colors
    Color priorityColor;
    String priorityText;
    switch (task.priority) {
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

    return Dismissible(
      key: Key(task.id?.toString() ?? task.firestoreId ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteTask(task),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(AppRoutes.taskDetail, arguments: task),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Check circle status switcher
                IconButton(
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted ? AppColors.success : Theme.of(context).colorScheme.outline,
                    size: 26,
                  ),
                  onPressed: () => controller.toggleTaskStatus(task),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Priority Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              priorityText,
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (task.dueDate != null && task.dueDate!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            // Due Date Badge
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.dueDate!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          // Synced indicator
                          Icon(
                            task.isSynced == 1 ? Icons.cloud_done : Icons.cloud_off,
                            size: 14,
                            color: task.isSynced == 1 ? AppColors.success : AppColors.priorityMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
