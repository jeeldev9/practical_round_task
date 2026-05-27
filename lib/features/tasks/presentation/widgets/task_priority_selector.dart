import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/task_controller.dart';

class TaskPrioritySelector extends GetView<TaskController> {
  const TaskPrioritySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedPriority.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Priority',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPriorityButton(
                  context,
                  priority: 1,
                  label: 'Low',
                  color: AppColors.priorityLow,
                  isSelected: selected == 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPriorityButton(
                  context,
                  priority: 2,
                  label: 'Medium',
                  color: AppColors.priorityMedium,
                  isSelected: selected == 2,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPriorityButton(
                  context,
                  priority: 3,
                  label: 'High',
                  color: AppColors.priorityHigh,
                  isSelected: selected == 3,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildPriorityButton(
    BuildContext context, {
    required int priority,
    required String label,
    required Color color,
    required bool isSelected,
  }) {
    return OutlinedButton(
      onPressed: () => controller.selectedPriority.value = priority,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        backgroundColor: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }
}
