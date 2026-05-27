import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/task_controller.dart';

class TaskSearchFilters extends GetView<TaskController> {
  const TaskSearchFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Search tasks by title...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Filter Segment (Priority & Status)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Status Filters
              _buildFilterChip(
                context,
                label: 'All Status',
                isSelected: () => controller.selectedStatusFilter.value == -1,
                onSelected: (_) => controller.selectedStatusFilter.value = -1,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Active',
                isSelected: () => controller.selectedStatusFilter.value == 0,
                onSelected: (_) => controller.selectedStatusFilter.value = 0,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Completed',
                isSelected: () => controller.selectedStatusFilter.value == 1,
                onSelected: (_) => controller.selectedStatusFilter.value = 1,
              ),

              // Vertical Divider
              Container(
                height: 24,
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
              ),

              // Priority Filters
              _buildFilterChip(
                context,
                label: 'All Priorities',
                isSelected: () => controller.selectedPriorityFilter.value == 0,
                onSelected: (_) => controller.selectedPriorityFilter.value = 0,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Low',
                isSelected: () => controller.selectedPriorityFilter.value == 1,
                onSelected: (_) => controller.selectedPriorityFilter.value = 1,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Medium',
                isSelected: () => controller.selectedPriorityFilter.value == 2,
                onSelected: (_) => controller.selectedPriorityFilter.value = 2,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'High',
                isSelected: () => controller.selectedPriorityFilter.value == 3,
                onSelected: (_) => controller.selectedPriorityFilter.value = 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool Function() isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return Obx(() {
      final selected = isSelected();
      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
      );
    });
  }
}
