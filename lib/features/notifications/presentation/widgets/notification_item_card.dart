import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/notification_entity.dart';
import '../notification_controller.dart';

class NotificationItemCard extends GetView<NotificationController> {
  final NotificationEntity notification;

  const NotificationItemCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(context),
      onDismissed: (_) => _onDismissed(),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surface)
                : (isDark
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.07)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? theme.colorScheme.outlineVariant.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.4),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon
                _buildTypeIcon(context),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with unread dot
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.poppins(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Body
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Time
                      Text(
                        _relativeTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    final (icon, color) = _iconAndColor();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  (IconData, Color) _iconAndColor() {
    switch (notification.type) {
      case 'due_date':
        return (Icons.calendar_today_rounded, AppColors.primary);
      case 'fcm':
        return (Icons.notifications_rounded, AppColors.accent);
      default:
        return (Icons.info_outline_rounded, AppColors.info);
    }
  }

  Widget _buildDismissBackground(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded,
              color: AppColors.error, size: 24),
          const SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void _onTap() {
    if (!notification.isRead && notification.id != null) {
      controller.markAsRead(notification.id!);
    }
    if (notification.taskId != null) {
      Get.toNamed(AppRoutes.taskDetail);
    }
  }

  void _onDismissed() {
    // Remove from local list optimistically
    controller.notifications.remove(notification);
    // Update badge if it was unread
    if (!notification.isRead) {
      controller.unreadCount.value =
          (controller.unreadCount.value - 1).clamp(0, 9999);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _relativeTime(String isoString) {
    try {
      final created = DateTime.parse(isoString).toLocal();
      final diff = DateTime.now().difference(created);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${created.day}/${created.month}/${created.year}';
    } catch (_) {
      return '';
    }
  }
}
