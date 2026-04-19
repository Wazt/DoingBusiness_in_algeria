import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ════════════════════════════════════════════════════════════════════════
///  NotificationRepository — fixed
/// ════════════════════════════════════════════════════════════════════════
///  Previous bug:
///    ✘ Only AndroidInitializationSettings was passed — iOS notifications
///      silently broken (the plugin needs DarwinInitializationSettings too).
///
///  Fix:
///    ✔ Both platforms initialized
///    ✔ Android 13+ runtime permission explicitly requested via
///      AndroidFlutterLocalNotificationsPlugin (FCM doesn't cover this).
/// ════════════════════════════════════════════════════════════════════════
class NotificationRepository {
  NotificationRepository._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(initializationSettings);

    // Android 13+ (API 33+) — POST_NOTIFICATIONS is a runtime permission
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Create default channel up front so users see sensible defaults
    // in Android System Settings → App → Notifications.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'doingbusiness_default',
          'General notifications',
          description: 'News and updates from Grant Thornton',
          importance: Importance.high,
        ));
  }

  static FlutterLocalNotificationsPlugin get plugin => _plugin;
}
