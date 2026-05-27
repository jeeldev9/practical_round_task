import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    super.id,
    super.firestoreId,
    required super.title,
    super.description,
    super.priority = 1,
    super.status = 0,
    super.dueDate,
    required super.userId,
    super.isSynced = 0,
    super.createdAt,
    super.updatedAt,
  });

  // Factory from SQLite cached map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      firestoreId: map['firestore_id'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      priority: map['priority'] as int? ?? 1,
      status: map['status'] as int? ?? 0,
      dueDate: map['due_date'] as String?,
      userId: map['user_id'] as String? ?? '',
      isSynced: map['is_synced'] as int? ?? 0,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  // Factory from Cloud Firestore Document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel(
      id: null, // SQLite local ID is null for incoming Firestore records initially
      firestoreId: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      priority: data['priority'] as int? ?? 1,
      status: data['status'] as int? ?? 0,
      dueDate: data['dueDate'] as String?,
      userId: data['userId'] as String? ?? '',
      isSynced: 1, // Directly loaded from Firestore, so it is synced
      createdAt: data['createdAt'] as String?,
      updatedAt: data['updatedAt'] as String?,
    );
  }

  // Convert to SQLite cached map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'firestore_id': firestoreId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'due_date': dueDate,
      'user_id': userId,
      'is_synced': isSynced,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convert to Cloud Firestore write map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'dueDate': dueDate,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Convert to domain entity
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      firestoreId: firestoreId,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      userId: userId,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Factory from standard domain entity
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      firestoreId: entity.firestoreId,
      title: entity.title,
      description: entity.description,
      priority: entity.priority,
      status: entity.status,
      dueDate: entity.dueDate,
      userId: entity.userId,
      isSynced: entity.isSynced,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
