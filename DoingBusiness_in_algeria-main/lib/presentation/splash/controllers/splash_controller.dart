import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  SplashController — simplified
/// ════════════════════════════════════════════════════════════════════════
///  Previous bug:
///    ✘ isShown null → both `if (null) {}` and `null ? a : b` executed,
///      the second line threw NoSuchMethodError (null.? operator on bool?).
///
///  Fix:
///    ✔ Delegate the decision to AuthenticationRepository.screenRedirect()
///      which is the single source of truth for "which screen to show first".
/// ════════════════════════════════════════════════════════════════════════
class SplashController extends GetxController {
  Future<void> switchScreen() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    // AuthenticationRepository.screenRedirect handles all cases safely:
    //   - logged in + verified  → MainWrapper
    //   - logged in + unverified → EmailVerification
    //   - not logged in + onboarded → Login
    //   - not logged in + not onboarded → GetStarted
    AuthenticationRepository.instance.screenRedirect();
  }
}
