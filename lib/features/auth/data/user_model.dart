import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.fcmToken,
    required super.createdAt,
  });

  // Factory from Firebase Auth User
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      fcmToken: null, // FCM token is updated separately when messaging starts
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  // Factory from SQLite Cache Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['display_name'] as String?,
      photoUrl: map['photo_url'] as String?,
      fcmToken: map['fcm_token'] as String?,
      createdAt: map['cached_at'] != null
          ? DateTime.parse(map['cached_at'] as String)
          : DateTime.now(),
    );
  }

  // Factory from Cloud Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final timestamp = data['createdAt'] as Timestamp?;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      fcmToken: data['fcmToken'] as String?,
      createdAt: timestamp != null ? timestamp.toDate() : DateTime.now(),
    );
  }

  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'fcm_token': fcmToken,
      'cached_at': createdAt.toIso8601String(),
    };
  }

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert to Domain Entity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      fcmToken: fcmToken,
      createdAt: createdAt,
    );
  }
}
