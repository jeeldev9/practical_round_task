class TaskEntity {
  final int? id;
  final String? firestoreId;
  final String title;
  final String? description;
  final int priority; // 1 = Low, 2 = Medium, 3 = High
  final int status;   // 0 = Active, 1 = Completed
  final String? dueDate;
  final String userId;
  final int isSynced; // 0 = false, 1 = true
  final String? createdAt;
  final String? updatedAt;

  const TaskEntity({
    this.id,
    this.firestoreId,
    required this.title,
    this.description,
    this.priority = 1,
    this.status = 0,
    this.dueDate,
    required this.userId,
    this.isSynced = 0,
    this.createdAt,
    this.updatedAt,
  });

  TaskEntity copyWith({
    int? id,
    String? firestoreId,
    String? title,
    String? description,
    int? priority,
    int? status,
    String? dueDate,
    String? userId,
    int? isSynced,
    String? createdAt,
    String? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TaskEntity(id: $id, firestoreId: $firestoreId, title: $title, priority: $priority, status: $status, dueDate: $dueDate, isSynced: $isSynced)';
  }
}
