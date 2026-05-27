import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import 'datasources/auth_local_datasource.dart';
import 'datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl(this.remote, this.local);

  @override
  Stream<UserEntity?> get authStateChanges {
    return remote.authStateChanges.map((model) => model?.toEntity());
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final userModel = await remote.signInWithEmailPassword(email, password);
    await local.saveUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> register(String email, String password, String name) async {
    final userModel = await remote.registerWithEmailPassword(email, password, name);
    await local.saveUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remote.sendPasswordResetEmail(email);
  }

  @override
  Future<void> logout() async {
    // 1. Get current Firebase user uid safely before logging out
    final currentUser = await remote.getCurrentUser();
    final uid = currentUser?.uid;

    // 2. Call remote.signOut()
    await remote.signOut();

    // 3. Call local.deleteUser(uid)
    if (uid != null) {
      await local.deleteUser(uid);
    } else {
      // Fallback: delete the most recently cached user
      final cached = await local.getCachedUser();
      if (cached != null) {
        await local.deleteUser(cached.uid);
      }
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // 1. Try remote.getCurrentUser()
      final remoteUser = await remote.getCurrentUser();
      if (remoteUser != null) {
        // Keep SQLite cache updated with latest cloud records
        await local.saveUser(remoteUser);
        return remoteUser.toEntity();
      }
    } catch (_) {
      // remote fails (e.g. offline) - fallback to local cache
    }

    // 2. Fallback to local.getCachedUser()
    final localUser = await local.getCachedUser();
    return localUser?.toEntity();
  }
}
