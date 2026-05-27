import 'notification_entity.dart';

/// Abstract contract for the Notification repository.
/// The data layer (SQLite impl) fulfills this interface.
abstract class NotificationRepository {
  /// Fetch all notifications ordered by createdAt DESC.
  Future<List<NotificationEntity>> getAll();

  /// Persist a new notification entry.
  Future<void> insert(NotificationEntity notification);

  /// Mark a single notification as read by its local [id].
  Future<void> markAsRead(int id);

  /// Mark every stored notification as read.
  Future<void> markAllAsRead();

  /// Delete all stored notifications.
  Future<void> deleteAll();

  /// Returns count of unread notifications (for badge display).
  Future<int> getUnreadCount();
}
