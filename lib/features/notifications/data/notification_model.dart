import '../domain/notification_entity.dart';

/// Data Transfer Object — maps between raw SQLite Maps and [NotificationEntity].
class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final String type;
  final String? taskId;
  final int isRead; // SQLite stores booleans as 0/1
  final String createdAt;

  const NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    this.taskId,
    required this.isRead,
    required this.createdAt,
  });

  // ── Mapping ────────────────────────────────────────────────────────────────

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      body: map['body'] as String,
      type: map['type'] as String,
      taskId: map['task_id'] as String?,
      isRead: map['is_read'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'type': type,
      'task_id': taskId,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      taskId: entity.taskId,
      isRead: entity.isRead ? 1 : 0,
      createdAt: entity.createdAt,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      type: type,
      taskId: taskId,
      isRead: isRead == 1,
      createdAt: createdAt,
    );
  }
}
