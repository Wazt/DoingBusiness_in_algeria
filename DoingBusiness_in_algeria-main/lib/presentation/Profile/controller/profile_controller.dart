import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/core/configs/theme/app_theme.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  RxBool isDarkMode = false.obs;
  //final _storage = GetStorage();

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

  Future<void> deleteAccountController() async {
    try {
      Get.dialog(
        barrierColor: Colors.black.withOpacity(0.5), // Dim background color
        barrierDismissible: false,
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, size: 50, color: Colors.red),
                SizedBox(height: 10),
                Text(
                  "Attention!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                    "Are you sure you want to delete your account? This action is irreversible, and all your data will be permanently deleted. Please confirm to proceed"),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mediumGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () =>
                          AuthenticationRepository.instance.deleteUserAccount(),
                      child: Text("Delete"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      throw e.toString();
    }
  }
}
