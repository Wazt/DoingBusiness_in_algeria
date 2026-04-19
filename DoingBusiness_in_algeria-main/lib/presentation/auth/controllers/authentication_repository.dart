import 'package:flutter/foundation.dart';
import 'package:doingbusiness/presentation/MainWrapper/main_wrapper.dart';
import 'package:doingbusiness/presentation/auth/pages/email_verification.dart';
import 'package:doingbusiness/presentation/auth/pages/login_screen.dart';
import 'package:doingbusiness/presentation/intro/pages/intro_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    screenRedirect();
  }

  void screenRedirect() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    final user = _auth.currentUser;
    if (user != null) {
      if (user.emailVerified) {
        Get.offAll(MainWrapper());
      } else {
        Get.offAll(EmailVerificationScreen(
          email: _auth.currentUser?.email,
        ));
      }
    } else {
      final isShown = deviceStorage.read('isShown');

      if (isShown == null) {
        Get.offAll(const GetStartedPage());
      }

      isShown ? Get.offAll(LoginScreen()) : Get.offAll(const GetStartedPage());
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } on FirebaseException catch (e) {
      throw e.code;
    }
  }

  //Login with email and password

  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw 'something went wrong';
    }
  }

  //send email verification

  Future<void> sendEmailVerificaiton() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'something went wrong';
    }
  }

  //Forgot password logic

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'something went wrong';
    }
  }

  //logout function
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(LoginScreen());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential;
      return logout();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
