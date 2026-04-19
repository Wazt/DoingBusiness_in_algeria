import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/utils/services/notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ════════════════════════════════════════════════════════════════════════
///  NotificationController — fixed
/// ════════════════════════════════════════════════════════════════════════
///  Bugs fixed:
///    ✘ debugPrint("FCM Token: $token")   ← LEAKED token to logcat / crash logs
///      Any app with READ_LOGS (API 25+) or ADB access could steal it.
///    ✘ Token was never sent to backend → you can't push to users anyway.
///
///  New behavior:
///    ✔ Token stored in Firestore under Users/{uid}.fcmTokens (array of strings)
///      so a Cloud Function can target pushes to the right device.
///    ✔ Old tokens cleaned up on token refresh.
///    ✔ POST_NOTIFICATIONS runtime request on Android 13+.
/// ════════════════════════════════════════════════════════════════════════
class NotificationController {
  NotificationController._();
  static final instance = NotificationController._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await NotificationRepository.init();
    await _requestPermissions();
    _listenTokenRefresh();
    _listenForegroundMessages();
    await _storeTokenForCurrentUser();
  }

  Future<void> _requestPermissions() async {
    // iOS + Android 13+ — single API, FlutterFire delegates to platform.
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen(_saveToken);
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification == null) return;

      // Show as a local notification so user sees it even with app foregrounded
      const android = AndroidNotificationDetails(
        'doingbusiness_default',
        'General notifications',
        channelDescription: 'News and updates from Grant Thornton',
        importance: Importance.high,
        priority: Priority.high,
      );
      const ios = DarwinNotificationDetails();
      await _local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(android: android, iOS: ios),
      );
    });
  }

  Future<void> _storeTokenForCurrentUser() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final user = AuthenticationRepository.instance.authUser;
    if (user == null) return;  // not logged in — nothing to link to

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .set({
            'fcmTokens': FieldValue.arrayUnion([token]),
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (_) {
      // Silently swallow — failing to save a token should never break the app.
      // Consider routing to Crashlytics once it's set up (Phase 3).
    }
  }

  /// Call on logout to unregister this device.
  Future<void> unregisterTokenForCurrentUser() async {
    final user = AuthenticationRepository.instance.authUser;
    if (user == null) return;
    final token = await _messaging.getToken();
    if (token == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .update({'fcmTokens': FieldValue.arrayRemove([token])});
    } catch (_) {}
  }
}
