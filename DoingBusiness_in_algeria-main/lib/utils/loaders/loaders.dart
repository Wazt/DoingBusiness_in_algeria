import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loaders {
  static hideSnackBar() =>
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey,
          ),
          child: Center(
            child: Text(message),
          ),
        ),
      ),
    );
  }

  static successSnackBar({required title, message = "", duration = 3}) {
    Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: AppColors.mediumGreen,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.check, color: Colors.white),
      margin: EdgeInsets.all(10),
    );
  }

  static warningSnackBar({required title, message = "", duration = 3}) {
    Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: AppColors.warningOrange,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.warning, color: Colors.white),
      margin: EdgeInsets.all(10),
    );
  }

  static errorSnackBar({required title, message = "", duration = 3}) {
    Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: AppColors.dangerRed,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.warning, color: Colors.white),
      margin: EdgeInsets.all(10),
    );
  }
}
