import 'dart:async';

import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/utils/Network/network_manager.dart';
import 'package:doingbusiness/utils/animations/full_screen_loader.dart';
import 'package:doingbusiness/utils/error_mapper.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// SignInController — with exponential-backoff UI lockout.
///
/// Firebase Auth already rate-limits server-side after ~5 failed attempts per
/// IP per minute (`too-many-requests`), but the UI doesn't indicate that. This
/// controller adds a local counter that disables the submit button for
/// 2^(attempts-1) seconds after each failed login, giving clear feedback to
/// honest users and discouraging a distracted brute-force from the same device.
///
/// Audit reference: `audit_security_deep_dive.html` §06 MEDIUM
/// "No client-side rate-limit on login".
class SignInController extends GetxController {
  static SignInController get instance => Get.find();
  final hidePassword = true.obs;
  final isLoading = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> siginKey = GlobalKey<FormState>();

  // ─── Local rate-limit state ──────────────────────────────────────────
  /// Countdown in seconds until the form can be submitted again. 0 = unlocked.
  final RxInt lockoutSeconds = 0.obs;
  int _failedAttempts = 0;
  Timer? _lockoutTicker;

  bool get isLockedOut => lockoutSeconds.value > 0;

  @override
  void onClose() {
    _lockoutTicker?.cancel();
    email.dispose();
    password.dispose();
    super.onClose();
  }

  Future<void> signIn() async {
    if (isLockedOut) {
      Loaders.warningSnackBar(
        title: 'Please wait',
        message: 'Too many failed attempts. Try again in ${lockoutSeconds.value}s.',
      );
      return;
    }

    try {
      isLoading.value = true;
      FullScreenLoader.openLoadingDialog(
        'Sign in .....',
        'assets/images/loading_animation.json',
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      if (!siginKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      FullScreenLoader.stopLoading();
      _resetBackoff();

      Loaders.successSnackBar(
        title: 'Signed In',
        message: 'Explore Our latest Articles !!!',
      );

      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      FullScreenLoader.stopLoading();
      _applyBackoff();
      Loaders.warningSnackBar(
        title: 'Oh Snap',
        message: ErrorMapper.toUserMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Backoff helpers ─────────────────────────────────────────────────

  void _applyBackoff() {
    _failedAttempts += 1;
    // 1, 2, 4, 8, 16, 32, 64 (capped) — doubles each failure.
    final delay = (1 << (_failedAttempts - 1)).clamp(1, 64);
    lockoutSeconds.value = delay;
    _lockoutTicker?.cancel();
    _lockoutTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (lockoutSeconds.value <= 1) {
        lockoutSeconds.value = 0;
        t.cancel();
      } else {
        lockoutSeconds.value -= 1;
      }
    });
  }

  void _resetBackoff() {
    _failedAttempts = 0;
    lockoutSeconds.value = 0;
    _lockoutTicker?.cancel();
  }
}
