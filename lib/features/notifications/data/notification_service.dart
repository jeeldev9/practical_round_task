import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notification_entity.dart';
import '../domain/notification_repository.dart';

/// Handles both local (scheduled) notifications and incoming FCM messages.
///
/// Lifecycle:
/// 1. Call [initialize] once in `main()` before `runApp()`.
/// 2. Inject via GetX as a permanent singleton from [InitialBinding].
/// 3. Other controllers reference this via `Get.find<NotificationService>()`.
class NotificationService extends GetxService {
  // ── Constants ───────────────────────────────────────────────────────────────
  static const String _channelId = 'smart_task_channel';
  static const String _channelName = 'Smart Task Manager';
  static const String _channelDesc = 'Task reminders and alerts';

  // ── Internals ───────────────────────────────────────────────────────────────
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Public so NotificationController can store them in the repo
  NotificationRepository? _repository;

  void setRepository(NotificationRepository repo) {
    _repository = repo;
  }

  // ── Initialization ──────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // 1. Timezone init (required for scheduled notifications)
    tz.initializeTimeZones();

    // 2. Android notification channel + plugin init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: darwinInit);

    await _localPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Create Android notification channel
    await _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // 4. Request FCM permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Listen to foreground FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundFCM);

    // 6. Handle notification tap from background/terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFCMTap);

    // 7. Check if app was launched from a notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleFCMTap(initialMessage);
    }

    // 8. Print FCM token for testing (visible in debug console)
    final token = await _fcm.getToken();
    debugPrint('╔══════════════════════════════════════════════════════╗');
    debugPrint('║  FCM TOKEN (copy this to send test notifications)    ║');
    debugPrint('╠══════════════════════════════════════════════════════╣');
    debugPrint('║  $token');
    debugPrint('╚══════════════════════════════════════════════════════╝');

    debugPrint('[NotificationService] Initialized successfully.');
  }

  // ── Local Notifications ─────────────────────────────────────────────────────

  /// Show an immediate local notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localPlugin.show(id, title, body, details, payload: payload);
  }

  /// Schedule a local notification to fire at [scheduledDate].
  /// Used to send a due-date reminder at 9 AM on the day of the due date.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Don't schedule if the time is already in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
        '[NotificationService] Scheduled notification $id at $scheduledDate');
  }

  /// Cancel a previously scheduled notification by its [id].
  Future<void> cancelNotification(int id) async {
    await _localPlugin.cancel(id);
    debugPrint('[NotificationService] Cancelled notification $id');
  }

  // ── FCM Handlers ────────────────────────────────────────────────────────────

  Future<void> _handleForegroundFCM(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? 'Notification';
    final body = notification.body ?? '';

    // Show a local pop-up for foreground FCM messages
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: message.data['task_id'],
    );

    // Persist to SQLite history
    await _persistNotification(
      title: title,
      body: body,
      type: 'fcm',
      taskId: message.data['task_id'],
    );
  }

  void _handleFCMTap(RemoteMessage message) {
    // Navigate to notifications screen when user taps a FCM notification
    Get.toNamed('/notifications');
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to notifications screen when user taps a local notification
    Get.toNamed('/notifications');
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Persist a notification entry into SQLite via the repository.
  Future<void> _persistNotification({
    required String title,
    required String body,
    required String type,
    String? taskId,
  }) async {
    if (_repository == null) return;
    await _repository!.insert(
      NotificationEntity(
        title: title,
        body: body,
        type: type,
        taskId: taskId,
        isRead: false,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Helper used by [TaskController] to schedule a due-date reminder and
  /// persist it to the notifications history.
  Future<void> scheduleTaskDueReminder({
    required int notificationId,
    required String taskTitle,
    required DateTime dueDate,
    required String taskId,
  }) async {
    // Fire at 9 AM on the due date
    final reminderTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 9);

    await scheduleNotification(
      id: notificationId,
      title: '📅 Task Due Today',
      body: '"$taskTitle" is due today. Don\'t forget to complete it!',
      scheduledDate: reminderTime,
      payload: taskId,
    );

    // Also save it to notification history (will appear in the screen)
    await _persistNotification(
      title: '📅 Due Date Reminder Set',
      body:
          'You\'ll be reminded about "$taskTitle" on ${dueDate.toLocal().toString().split(' ')[0]}.',
      type: 'due_date',
      taskId: taskId,
    );
  }
}
