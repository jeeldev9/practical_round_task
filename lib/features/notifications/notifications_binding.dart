import 'package:get/get.dart';

import 'data/notification_repository_impl.dart';
import 'data/notification_service.dart';
import 'domain/notification_repository.dart';
import 'presentation/notification_controller.dart';

class NotificationsBinding implements Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(),
    );

    // NotificationController needs the service (already permanent in InitialBinding)
    Get.lazyPut<NotificationController>(
      () => NotificationController(
        repository: Get.find<NotificationRepository>(),
        notificationService: Get.find<NotificationService>(),
      ),
    );
  }
}
