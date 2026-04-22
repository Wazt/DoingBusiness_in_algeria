import 'dart:async';
import 'dart:ui';

import 'package:doingbusiness/bindings/general_bindings.dart';
import 'package:doingbusiness/core/configs/theme/app_theme.dart';
import 'package:doingbusiness/firebase_options.dart';
import 'package:doingbusiness/presentation/Profile/controller/profile_controller.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/presentation/splash/pages/splash_screen.dart';
import 'package:doingbusiness/utils/services/notification_repository.dart';
import 'package:doingbusiness/utils/services/notifications.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Get.snackbar(
    message.notification!.title ?? "Notification",
    message.notification!.body ?? "You have a new message",
  );
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  // Run the whole app inside a guarded Zone so unhandled async errors land
  // in Crashlytics instead of getting silently swallowed or leaking to UI.
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await GetStorage.init();
      await NotificationRepository.init();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Get.put(AuthenticationRepository());

      // ─── App Check ────────────────────────────────────────────────────
      // Attests that requests come from a real, unmodified app binary.
      // Without this, an attacker who steals an admin ID token can call the
      // LinkedIn Cloud Functions from curl. With it enabled on both sides
      // (functions use enforceAppCheck:true), those requests are rejected.
      //
      // Dev builds use the debug provider — Firebase Console shows a debug
      // token in the Flutter console on first run; you register it manually.
      // Release builds use Play Integrity (Android) / App Attest (iOS).
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
        appleProvider:
            kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
      );

      // ─── Crashlytics ───────────────────────────────────────────────────
      // Sends unhandled Flutter + platform errors to the Crashlytics console.
      // Disabled in debug to avoid noise from hot-reload errors.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(kReleaseMode);
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await NotificationController.instance.initialize();

      runApp(MyApp());
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Obx(
      () => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialBinding: GeneralBindings(),
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: profileController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const SplashPage()),
    );
  }
}
