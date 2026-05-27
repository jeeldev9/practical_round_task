import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/task_controller.dart';

class PerformanceStats extends GetView<TaskController> {
  const PerformanceStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Performance',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          // Calculate dynamically from the active list
          final pendingCount = controller.tasks.where((t) => t.status == 0).length;
          final completedCount = controller.tasks.where((t) => t.status == 1).length;
          final highPriorityCount = controller.tasks.where((t) => t.priority == 3 && t.status == 0).length;

          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Pending',
                  value: pendingCount.toString(),
                  icon: Icons.pending_actions,
                  color: AppColors.priorityMedium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Completed',
                  value: completedCount.toString(),
                  icon: Icons.task_alt,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'High Priority',
                  value: highPriorityCount.toString(),
                  icon: Icons.priority_high,
                  color: AppColors.priorityHigh,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.5),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
