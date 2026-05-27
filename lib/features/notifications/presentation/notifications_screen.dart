import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_task_manager/features/notifications/presentation/notification_controller.dart';

import '../../../../core/theme/app_colors.dart';
import 'widgets/notification_item_card.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.loadNotifications,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return NotificationItemCard(notification: notification);
              },
            ),
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () => Get.back(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Obx(() {
            final count = controller.unreadCount.value;
            return Text(
              count > 0 ? '$count unread' : 'All caught up',
              style: TextStyle(
                fontSize: 12,
                color: count > 0
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            );
          }),
        ],
      ),
      actions: [
        // Mark all as read
        Obx(() {
          if (controller.unreadCount.value == 0) return const SizedBox.shrink();
          return TextButton.icon(
            onPressed: controller.markAllAsRead,
            icon: const Icon(Icons.done_all_rounded,
                size: 18, color: AppColors.primary),
            label: const Text(
              'Read all',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          );
        }),

        // Clear all
        Obx(() {
          if (controller.notifications.isEmpty) return const SizedBox.shrink();
          return IconButton(
            tooltip: 'Clear all',
            icon: Icon(Icons.delete_sweep_rounded,
                color: theme.colorScheme.onSurfaceVariant),
            onPressed: _confirmClearAll,
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated bell icon container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!\nCreate tasks with due dates to get reminders.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently delete all notifications from your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Get.back();
              controller.clearAll();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
