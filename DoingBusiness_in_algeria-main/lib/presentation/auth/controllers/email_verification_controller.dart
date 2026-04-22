import 'dart:async';
import 'dart:math';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/utils/error_mapper.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:doingbusiness/utils/pages/success_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  EmailVerificationController — fixed
/// ════════════════════════════════════════════════════════════════════════
///  Previous bugs:
///    ✘ Timer.periodic(1 second) hammered FirebaseAuth.reload() forever
///    ✘ Timer was never cancelled on screen close
///    ✘ Typo in method name "sendEmailVerification"
///
///  New behavior:
///    ✔ Polling every 3 seconds (was 1 — reduces load by 3x)
///    ✔ Auto-stops after 10 minutes so an abandoned screen doesn't drain battery
///    ✔ Timer always cancelled in onClose()
///    ✔ Resend button is rate-limited (30s cooldown) so users can't flood Firebase
/// ════════════════════════════════════════════════════════════════════════
class EmailVerificationController extends GetxController {
  static EmailVerificationController get instance => Get.find();

  Timer? _pollingTimer;
  Timer? _autoStopTimer;
  DateTime? _lastResentAt;

  final isResending = false.obs;
  final canResendIn = 0.obs;  // seconds until resend is allowed
  Timer? _cooldownTicker;

  @override
  void onInit() {
    sendEmailVerification();
    _startPolling();
    super.onInit();
  }

  Future<void> sendEmailVerification() async {
    // Rate-limit: one resend every 30 seconds max.
    final now = DateTime.now();
    if (_lastResentAt != null && now.difference(_lastResentAt!).inSeconds < 30) {
      final wait = 30 - now.difference(_lastResentAt!).inSeconds;
      Loaders.warningSnackBar(
        title: 'Please wait',
        message: 'You can request a new email in $wait seconds.',
      );
      return;
    }

    try {
      isResending.value = true;
      await AuthenticationRepository.instance.sendEmailVerification();
      _lastResentAt = now;
      _startCooldownTicker();
      Loaders.successSnackBar(title: 'Email sent', message: 'Check your inbox.');
    } catch (e) {
      Loaders.errorSnackBar(title: 'Could not send email', message: ErrorMapper.toUserMessage(e));
    } finally {
      isResending.value = false;
    }
  }

  /// Polls with exponential-ish backoff (3 → 5 → 8 → 10 s, capped) and
  /// ±400 ms jitter on each tick to avoid thundering herd when many
  /// clients hit the "verify" screen at the same second boundary.
  /// Auto-stops after 10 minutes.
  int _pollAttempt = 0;
  final Random _rng = Random();

  void _startPolling() {
    _scheduleNextPoll();

    // Auto-stop after 10 minutes to save battery / quota
    _autoStopTimer = Timer(const Duration(minutes: 10), () {
      _pollingTimer?.cancel();
    });
  }

  void _scheduleNextPoll() {
    // Backoff tiers in seconds: 3, 5, 8, 10 (clamped).
    const tiers = [3, 5, 8, 10];
    final base = tiers[_pollAttempt.clamp(0, tiers.length - 1)];
    final jitterMs = _rng.nextInt(800) - 400; // ±400ms
    final delay = Duration(milliseconds: base * 1000 + jitterMs);
    _pollingTimer = Timer(delay, () async {
      _pollAttempt++;
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user?.emailVerified ?? false) {
          _pollingTimer?.cancel();
          _autoStopTimer?.cancel();
          Get.off(() => const SuccessScreen());
          return;
        }
      } catch (_) {
        // Transient network issue — next tick will retry.
      }
      _scheduleNextPoll();
    });
  }

  void _startCooldownTicker() {
    _cooldownTicker?.cancel();
    canResendIn.value = 30;
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (canResendIn.value <= 0) {
        t.cancel();
      } else {
        canResendIn.value--;
      }
    });
  }

  /// Manual check on button press (user is impatient / polling stopped)
  Future<void> checkEmailVerificationStatus() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      Get.off(() => const SuccessScreen());
    } else {
      // Restart polling if it had auto-stopped
      if (_pollingTimer?.isActive != true) _startPolling();
      Loaders.warningSnackBar(
        title: 'Not yet verified',
        message: 'We couldn\'t confirm verification. Please check your inbox.',
      );
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    _autoStopTimer?.cancel();
    _cooldownTicker?.cancel();
    super.onClose();
  }
}
