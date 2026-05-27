/// Pure domain object representing a single notification entry.
/// No framework or package dependencies — only plain Dart.
class NotificationEntity {
  final int? id;
  final String title;
  final String body;

  /// 'due_date' | 'fcm' | 'system'
  final String type;

  /// Local SQLite task ID linked to this notification (if any)
  final String? taskId;

  final bool isRead;
  final String createdAt;

  const NotificationEntity({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    this.taskId,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    int? id,
    String? title,
    String? body,
    String? type,
    String? taskId,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      taskId: taskId ?? this.taskId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'NotificationEntity(id: $id, title: $title, type: $type, isRead: $isRead)';
}
