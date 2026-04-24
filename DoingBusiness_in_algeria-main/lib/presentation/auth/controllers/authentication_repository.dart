import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doingbusiness/core/routing/routing_service.dart';
import 'package:doingbusiness/data/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Firebase Auth + account lifecycle.
///
/// Navigation has been extracted into a [RoutingService] (resolved via
/// [Get.find]) so this repo can be unit-tested against a fake routing
/// service. In production the default GetX implementation is wired up in
/// [GeneralBindings].
class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  RoutingService get _router => Get.find<RoutingService>();

  /// Currently signed-in user, or null if not signed in.
  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    super.onReady();
    screenRedirect();
  }

  /// Decides which screen to show on startup.
  /// Null-safe: no more crash when `isShown` hasn't been written yet.
  Future<void> screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        _router.goToMain();
      } else {
        _router.goToEmailVerify(email: user.email);
      }
      return;
    }

    final isShown = deviceStorage.read('isShown') ?? false;
    if (isShown == true) {
      _router.goToLogin();
    } else {
      _router.goToIntro();
    }
  }

  // ─── Email / password flows ──────────────────────────────────────────

  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _authExceptionToMessage(e);
    } catch (_) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _authExceptionToMessage(e);
    } catch (_) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _authExceptionToMessage(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _authExceptionToMessage(e);
    }
  }

  // ─── Reauth + account deletion (GDPR) ────────────────────────────────

  Future<void> reauthenticateWithEmailAndPassword(
      String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw 'You must be signed in.';
    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _authExceptionToMessage(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw 'You must be signed in.';
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _authExceptionToMessage(e);
    }
  }

  /// Fully deletes the account:
  ///   1. Reauth (required by Firebase for security)
  ///   2. Delete Firestore user document
  ///   3. Delete Firebase Auth account
  ///   4. Clear local storage + route to onboarding
  /// GDPR Article 17 compliant; matches Google Play's account-deletion policy.
  Future<void> deleteUserAccount(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw 'You must be signed in.';

    try {
      await reauthenticateWithEmailAndPassword(email, password);

      await UserRepository.instance.deleteUserRecord(user.uid);

      // Remove FCM tokens so backend stops pushing to this user
      // (defence in depth — tokens auto-invalidate too).
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .set({'fcmTokens': FieldValue.delete()}, SetOptions(merge: true))
          .catchError((_) {});

      await user.delete();

      await deviceStorage.erase();
      _router.goToIntro();
    } on FirebaseAuthException catch (e) {
      throw _authExceptionToMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _router.goToLogin();
  }

  // ─── Error mapping — never expose raw FirebaseException to UI ────────

  String _authExceptionToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':          return 'The email address is invalid.';
      case 'user-disabled':          return 'This account has been disabled.';
      case 'user-not-found':         return 'No account found with this email.';
      case 'wrong-password':         return 'Incorrect password.';
      case 'invalid-credential':     return 'Email or password is incorrect.';
      case 'email-already-in-use':   return 'An account with this email already exists.';
      case 'operation-not-allowed':  return 'This sign-in method is currently disabled.';
      case 'weak-password':          return 'Password is too weak.';
      case 'too-many-requests':      return 'Too many attempts — please wait a moment.';
      case 'requires-recent-login':  return 'Please sign in again to confirm this action.';
      case 'network-request-failed': return 'No internet connection.';
      default:                       return 'Authentication failed. Please try again.';
    }
  }
}
