import 'package:get/get.dart';

import '../data/notification_service.dart';
import '../domain/notification_entity.dart';
import '../domain/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository;
  final NotificationService notificationService;

  NotificationController({
    required this.repository,
    required this.notificationService,
  });

  // ── Reactive State ──────────────────────────────────────────────────────────

  final RxList<NotificationEntity> notifications = <NotificationEntity>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Wire the service so it can persist FCM messages into our repo
    notificationService.setRepository(repository);
    loadNotifications();
  }

  // ── Data Operations ─────────────────────────────────────────────────────────

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final list = await repository.getAll();
      notifications.assignAll(list);
      unreadCount.value = await repository.getUnreadCount();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await repository.markAsRead(id);
      // Update local list without a full reload
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadCount.value = (unreadCount.value - 1).clamp(0, 9999);
      }
    } catch (_) {
      await loadNotifications(); // Fallback to full reload on error
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
      notifications.assignAll(
        notifications.map((n) => n.copyWith(isRead: true)).toList(),
      );
      unreadCount.value = 0;
    } catch (e) {
      Get.snackbar('Error', 'Could not mark all as read.');
    }
  }

  Future<void> clearAll() async {
    try {
      await repository.deleteAll();
      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      Get.snackbar('Error', 'Could not clear notifications.');
    }
  }

  /// Refresh unread count — called from other controllers after inserting a
  /// new notification (e.g., from TaskController after scheduling a reminder).
  Future<void> refreshUnreadCount() async {
    unreadCount.value = await repository.getUnreadCount();
  }
}
