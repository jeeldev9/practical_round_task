import 'package:get/get.dart';

import '../auth/data/datasources/auth_local_datasource.dart';
import '../auth/presentation/controllers/auth_controller.dart';
import 'data/profile_remote_datasource.dart';
import 'data/profile_repository_impl.dart';
import 'domain/profile_repository.dart';
import 'domain/update_profile_usecase.dart';
import 'presentation/profile_controller.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileRemoteDataSource());

    Get.lazyPut<ProfileRepository>(() => ProfileRepositoryImpl(
          Get.find<ProfileRemoteDataSource>(),
          Get.find<AuthLocalDataSource>(),
        ));

    Get.lazyPut(() => UpdateProfileUseCase(Get.find<ProfileRepository>()));

    Get.lazyPut(() => ProfileController(
          updateProfileUseCase: Get.find<UpdateProfileUseCase>(),
          authController: Get.find<AuthController>(),
        ));
  }
}
