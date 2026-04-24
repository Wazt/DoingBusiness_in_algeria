import 'package:doingbusiness/presentation/MainWrapper/main_wrapper.dart';
import 'package:doingbusiness/presentation/auth/pages/email_verification.dart';
import 'package:doingbusiness/presentation/auth/pages/login_screen.dart';
import 'package:doingbusiness/presentation/intro/pages/intro_screen.dart';
import 'package:get/get.dart';

/// Navigation port extracted out of `AuthenticationRepository` so the repo
/// can stay pure data/auth logic and be unit-testable without GetX.
///
/// The default implementation uses GetX's global navigator
/// ([Get.offAll]) so today's call sites keep working without change.
/// Tests substitute a fake via `Get.put<RoutingService>(FakeRoutingService())`.
abstract class RoutingService {
  /// Route to the main navigation shell (Home / Search / Saved / Profile).
  void goToMain();

  /// Route to the intro/onboarding carousel.
  void goToIntro();

  /// Route to the login screen.
  void goToLogin();

  /// Route to the email-verification waiting screen.
  void goToEmailVerify({String? email});
}

/// GetX-backed production implementation — replaces the inline
/// `Get.offAll(() => …)` calls previously inside AuthenticationRepository.
class GetxRoutingService implements RoutingService {
  @override
  void goToMain() => Get.offAll(() => MainWrapper());

  @override
  void goToIntro() => Get.offAll(() => const GetStartedPage());

  @override
  void goToLogin() => Get.offAll(() => const LoginScreen());

  @override
  void goToEmailVerify({String? email}) =>
      Get.offAll(() => EmailVerificationScreen(email: email));
}
