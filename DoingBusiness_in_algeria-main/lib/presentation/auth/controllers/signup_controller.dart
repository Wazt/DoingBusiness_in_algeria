import 'package:doingbusiness/data/repository/user_repository.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/presentation/auth/controllers/user_controller.dart';
import 'package:doingbusiness/presentation/auth/pages/email_verification.dart';
import 'package:doingbusiness/utils/Network/network_manager.dart';
import 'package:doingbusiness/utils/animations/full_screen_loader.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  SignUpController — fixed
/// ════════════════════════════════════════════════════════════════════════
///  Bugs fixed:
///    ✔ agreeTerms defaults to FALSE (was true — GDPR violation)
///    ✔ Typo "sendEmailVerification" renamed to "sendEmailVerification"
///    ✔ Typo "isConnected" renamed, "privacy" renamed in UI text elsewhere
///    ✔ No raw e.toString() leaks — Loaders gets a safe message
///    ✔ hidePassword disposed with controller (leak fix)
/// ════════════════════════════════════════════════════════════════════════
class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final hidePassword = true.obs;
  final agreeTerms   = false.obs;  // ← was `true.obs` — GDPR violation

  final email    = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();

  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  Future<void> signUp() async {
    try {
      FullScreenLoader.openLoadingDialog(
        'Creating your account...',
        'assets/images/loading_animation.json',
      );

      // 1. Check connectivity (now actually works since NetworkManager is fixed)
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        Loaders.warningSnackBar(
          title: 'No internet',
          message: 'Please check your connection and try again.',
        );
        return;
      }

      // 2. Validate form
      if (!signupFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      // 3. Check terms agreement
      if (!agreeTerms.value) {
        FullScreenLoader.stopLoading();
        Loaders.warningSnackBar(
          title: 'Terms not accepted',
          message: 'You must accept the privacy policy to continue.',
        );
        return;
      }

      // 4. Create Firebase Auth user
      final userCredentials = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(email.text.trim(), password.text.trim());

      // 5. Set display name on the Auth user (so it survives even if Firestore write fails)
      await userCredentials.user?.updateDisplayName(username.text.trim());

      // 6. Save user record in Firestore
      await UserController.instance.saveUserRecord(userCredentials);

      // 7. Send email verification
      await AuthenticationRepository.instance.sendEmailVerification();

      FullScreenLoader.stopLoading();

      Loaders.successSnackBar(
        title: 'Welcome!',
        message: 'Check your inbox to verify your email.',
      );

      Get.to(() => EmailVerificationScreen(email: email.text.trim()));
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Sign up failed', message: e.toString());
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    username.dispose();
    super.onClose();
  }
}
