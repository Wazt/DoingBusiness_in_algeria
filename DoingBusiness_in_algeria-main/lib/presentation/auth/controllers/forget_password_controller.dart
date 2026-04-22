import 'package:doingbusiness/utils/error_mapper.dart';
import 'package:doingbusiness/presentation/Profile/pages/email_sent.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/utils/Network/network_manager.dart';
import 'package:doingbusiness/utils/animations/full_screen_loader.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  sendPasswordResetEmail() async {
    try {
      FullScreenLoader.openLoadingDialog('Processing your request ...',
          "assets/images/loading_animation.json");
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      if (!forgetPasswordFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance
          .sendPasswordResetEmail(email.text.trim());

      await AuthenticationRepository.instance.logout();

      FullScreenLoader.stopLoading();

      Loaders.successSnackBar(
          title: 'Email sent',
          message: 'Email link Sent to Reset your password');
      Get.to(EmailSent(
        email: email.text.trim(),
      ));
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'oh Snap', message: ErrorMapper.toUserMessage(e));
    }
  }

  resentPasswordResetEmail(String email) async {
    try {
      FullScreenLoader.openLoadingDialog('Processing your request ...',
          "assets/images/loading_animation.json");
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      FullScreenLoader.stopLoading();

      Loaders.successSnackBar(
          title: 'Email sent',
          message: 'Email link Sent to Reset your password');
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'oh Snap', message: ErrorMapper.toUserMessage(e));
    }
  }
}
