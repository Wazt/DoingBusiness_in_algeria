import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/utils/Network/network_manager.dart';
import 'package:doingbusiness/utils/animations/full_screen_loader.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  SignInController get instance => Get.find();
  final hidePassword = true.obs;
  final isLoading = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();

  GlobalKey<FormState> siginKey = GlobalKey<FormState>();

  Future<void> signIn() async {
    //check if the form if validate
    try {
      FullScreenLoader.openLoadingDialog(
          "Sign in .....", "assets/images/loading_animation.json");

      //check for internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();

        return;
      }
      //Form validation
      if (!siginKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();

        return;
      }
      await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      FullScreenLoader.stopLoading();

      Loaders.successSnackBar(
          title: 'Signed In', message: 'Explore Our latest Articles !!!');

      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.warningSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
