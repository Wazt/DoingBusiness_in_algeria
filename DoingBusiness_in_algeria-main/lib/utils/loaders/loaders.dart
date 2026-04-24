import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Lightweight helpers for snackbars.
/// All parameters are explicitly typed so strict-inference is happy and
/// the signatures match what callers actually use (String title/message,
/// int duration in seconds).
class Loaders {
  Loaders._();

  static void hideSnackBar() =>
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static void customToast({required String message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey,
          ),
          child: Center(child: Text(message)),
        ),
      ),
    );
  }

  static SnackbarController successSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    return Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: AppColors.mediumGreen,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.check, color: Colors.white),
      margin: const EdgeInsets.all(10),
    );
  }

  static SnackbarController warningSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    return Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: AppColors.warningOrange,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.warning, color: Colors.white),
      margin: const EdgeInsets.all(10),
    );
  }

  static SnackbarController errorSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    return Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: AppColors.dangerRed,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.warning, color: Colors.white),
      margin: const EdgeInsets.all(10),
    );
  }
}
