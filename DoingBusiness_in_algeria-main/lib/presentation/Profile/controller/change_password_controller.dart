import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/utils/Network/network_manager.dart';
import 'package:doingbusiness/utils/animations/full_screen_loader.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  ChangePasswordController — NEW (was empty; UI was calling
///                              ForgetPasswordController which logged user out)
/// ════════════════════════════════════════════════════════════════════════
///  Behavior:
///    1. User enters current password (for reauth) + new password + confirm
///    2. Reauth via AuthenticationRepository.reauthenticateWithEmailAndPassword
///    3. Change password via updatePassword(newPassword)
///    4. Show success snackbar; the user stays logged in.
/// ════════════════════════════════════════════════════════════════════════
class ChangePasswordController extends GetxController {
  static ChangePasswordController get instance => Get.find();

  final formKey = GlobalKey<FormState>();

  final currentPassword = TextEditingController();
  final newPassword     = TextEditingController();
  final confirmPassword = TextEditingController();

  final hideCurrent = true.obs;
  final hideNew     = true.obs;
  final hideConfirm = true.obs;

  Future<void> submit() async {
    try {
      FullScreenLoader.openLoadingDialog(
        'Updating password...',
        'assets/images/loading_animation.json',
      );

      // 1. Connectivity
      final connected = await NetworkManager.instance.isConnected();
      if (!connected) {
        FullScreenLoader.stopLoading();
        Loaders.warningSnackBar(
          title: 'No internet',
          message: 'Please check your connection and try again.',
        );
        return;
      }

      // 2. Form validation
      if (!formKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      // 3. Reauth with current password
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) {
        FullScreenLoader.stopLoading();
        Loaders.errorSnackBar(
          title: 'Not signed in',
          message: 'Please sign in again to change your password.',
        );
        return;
      }

      await AuthenticationRepository.instance
          .reauthenticateWithEmailAndPassword(user!.email!, currentPassword.text.trim());

      // 4. Update password
      await AuthenticationRepository.instance.updatePassword(newPassword.text.trim());

      FullScreenLoader.stopLoading();

      // 5. Clear fields + feedback
      currentPassword.clear();
      newPassword.clear();
      confirmPassword.clear();

      Loaders.successSnackBar(
        title: 'Password updated',
        message: 'Your password has been changed successfully.',
      );
      Get.back();
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Could not update', message: e.toString());
    }
  }

  @override
  void onClose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
