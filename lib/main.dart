import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/data/notification_service.dart';
import 'firebase_options.dart';

// TOP-LEVEL FCM Background Handler (annotated with @pragma('vm:entry-point') — NOT inside any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize Firebase Crashlytics & Error Handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 3. Initialize Firebase Analytics
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics.logAppOpen();

  // 4. Set FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 5. Force Portrait Mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 6. Initialize local notifications plugin + FCM listeners
  await NotificationService().initialize();

  // 7. Read saved theme preference BEFORE runApp so the correct theme
  //    is applied from the very first frame — no flash/jump.
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);
  
  final savedTheme = prefs.getString('theme_preference') ?? 'System';
  final ThemeMode initialThemeMode = switch (savedTheme) {
    'Light' => ThemeMode.light,
    'Dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  runApp(MyApp(themeMode: initialThemeMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;

  const MyApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Task Manager',
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
