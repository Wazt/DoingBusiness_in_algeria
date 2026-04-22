import 'package:doingbusiness/core/configs/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  RxBool isDarkMode = false.obs;

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences _storage = await SharedPreferences.getInstance();
    isDarkMode.value = _storage.getBool('isDarkMode') ?? false;
  }

  Future<void> darkModeSwitch(bool value) async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    isDarkMode.value = value;
    Get.changeTheme(isDarkMode.value ? AppTheme.dark() : AppTheme.light());
    await _storage.setBool("isDarkMode", isDarkMode.value);
  }

  // NOTE: Delete-account flow lives in
  // lib/presentation/Profile/pages/delete_user_account.dart — it shows a
  // password dialog and calls AuthenticationRepository.deleteUserAccount(...).
  // The previous inline `deleteAccountController` dialog here was dead code
  // (the "Delete" button did nothing) and has been removed.
}
