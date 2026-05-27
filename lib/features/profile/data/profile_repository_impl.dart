import '../../auth/data/datasources/auth_local_datasource.dart';
import '../../auth/data/user_model.dart';
import '../domain/profile_repository.dart';
import 'profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  final AuthLocalDataSource local;

  ProfileRepositoryImpl(this.remote, this.local);

  @override
  Future<void> updateDisplayName(String displayName) async {
    // 1. Update remotely in Firebase (Auth & Firestore)
    await remote.updateDisplayName(displayName);

    // 2. Synchronize local SQFlite caching
    final UserModel? cachedUser = await local.getCachedUser();
    if (cachedUser != null) {
      final updatedUser = UserModel(
        uid: cachedUser.uid,
        email: cachedUser.email,
        displayName: displayName,
        photoUrl: cachedUser.photoUrl,
        fcmToken: cachedUser.fcmToken,
        createdAt: cachedUser.createdAt,
      );
      await local.saveUser(updatedUser);
    }
  }
}
