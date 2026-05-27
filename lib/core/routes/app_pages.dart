import 'package:get/get.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/notifications/notifications_binding.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/profile_binding.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/settings_binding.dart';
import '../../features/tasks/presentation/screens/create_edit_task_screen.dart';
import '../../features/tasks/presentation/screens/dashboard_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../../features/tasks/tasks_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: AppRoutes.taskList,
      page: () => const TaskListScreen(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: AppRoutes.taskDetail,
      page: () => const TaskDetailScreen(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: AppRoutes.createEditTask,
      page: () => const CreateEditTaskScreen(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
  ];
}
