import 'package:doingbusiness/bindings/general_bindings.dart';
import 'package:doingbusiness/core/configs/theme/app_theme.dart';
import 'package:doingbusiness/firebase_options.dart';
import 'package:doingbusiness/presentation/Profile/controller/profile_controller.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/presentation/splash/pages/splash_screen.dart';
import 'package:doingbusiness/utils/services/notification_repository.dart';
import 'package:doingbusiness/utils/services/notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  Get.snackbar(
    message.notification!.title ?? "Notification",
    message.notification!.body ?? "You have a new message",
  );
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await LocalNotification.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((FirebaseApp value) => Get.put(AuthenticationRepository()));

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationController().initializeFirebaseMessaging();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    //Get.put(NotificationController());
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
