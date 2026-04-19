import 'package:flutter/foundation.dart';
import 'package:doingbusiness/utils/services/notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:get/get.dart';

class NotificationController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final controller = Get.put(LocalNotification());
  void initializeFirebaseMessaging() async {
    // Request permission for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Get the device token
    _getToken();

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        debugPrint('Foreground Notification: ${message.notification!.title}');
        debugPrint('Body: ${message.notification!.body}');
      }
      if (message.data.isNotEmpty) {
        debugPrint('Data: ${message.data}');
      }

      Get.snackbar(
        message.notification!.title ?? "Notification",
        message.notification!.body ?? "You have a new message",
      );
    });

    // Handle background/terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked!');
      Get.snackbar(
        message.notification!.title ?? "Notification",
        message.notification!.body ?? "You have a new message",
      );
      //_navigateToNotificationScreen(message);
    });
  }

  void _getToken() async {
    String? token = await _messaging.getToken();
    debugPrint("FCM Token: $token");
    // Send token to server or save it securely
  }
}
