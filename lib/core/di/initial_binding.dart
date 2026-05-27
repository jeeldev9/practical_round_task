import 'package:get/get.dart';

import '../database/database_helper.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../../features/notifications/data/notification_service.dart';

// Auth Imports
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/forgot_password_usecase.dart';
import '../../features/auth/domain/login_usecase.dart';
import '../../features/auth/domain/register_usecase.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put(DatabaseHelper(), permanent: true);
    Get.put(SyncService(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
    Get.put(NotificationService(), permanent: true);

    // Auth DataSources
    final authRemoteDataSource = Get.put(AuthRemoteDataSource(), permanent: true);
    final authLocalDataSource = Get.put(AuthLocalDataSource(), permanent: true);

    // Auth Repository
    final authRepository = Get.put<AuthRepository>(
      AuthRepositoryImpl(authRemoteDataSource, authLocalDataSource),
      permanent: true,
    );

    // Auth UseCases
    final loginUseCase = Get.put(LoginUseCase(authRepository), permanent: true);
    final registerUseCase = Get.put(RegisterUseCase(authRepository), permanent: true);
    final forgotPasswordUseCase = Get.put(ForgotPasswordUseCase(authRepository), permanent: true);

    // Auth Controller
    Get.put(
      AuthController(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        forgotPasswordUseCase: forgotPasswordUseCase,
        authRepository: authRepository,
      ),
      permanent: true,
    );
  }
}
