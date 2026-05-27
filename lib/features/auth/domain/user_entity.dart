class UserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.fcmToken,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, fcmToken: $fcmToken, createdAt: $createdAt)';
  }
}
