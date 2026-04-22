import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Central mapping from backend / platform exceptions to short,
/// user-safe messages. Use this anywhere you'd otherwise call
/// `Loaders.errorSnackBar(message: e.toString())` — which leaks Firebase/axios
/// internals into the UI.
///
/// Audit reference: see `audit_security_deep_dive.html` §07 MEDIUM finding
/// "Sensitive data exposure — residual e.toString() outside auth module".
class ErrorMapper {
  ErrorMapper._();

  /// Turn any error into a short, user-facing string.
  /// Never returns a stack trace or raw infra details.
  /// Logs the original `error` + `stack` via [debugPrint] so developers
  /// can still diagnose (and in release, Crashlytics captures them via
  /// `PlatformDispatcher.instance.onError`).
  static String toUserMessage(Object error, [StackTrace? stack]) {
    // Log the raw error so it's visible to developers / Crashlytics.
    debugPrint('[ErrorMapper] $error');
    if (stack != null) debugPrint(stack.toString());

    // ─── Firebase Auth ─────────────────────────────────────────────────
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'operation-not-allowed':
          return 'This sign-in method is currently disabled.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'too-many-requests':
          return 'Too many attempts — please wait a moment.';
        case 'requires-recent-login':
          return 'Please sign in again to confirm this action.';
        case 'network-request-failed':
          return 'No internet connection.';
        default:
          return 'Authentication failed. Please try again.';
      }
    }

    // ─── Cloud Functions (callables) ──────────────────────────────────
    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'unauthenticated':
          return 'You must be signed in to do this.';
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'invalid-argument':
          // Safe to surface the server-provided message here — our Cloud
          // Functions throw HttpsError with controlled messages.
          return error.message ?? 'The request was rejected by the server.';
        case 'not-found':
          return 'That resource does not exist.';
        case 'already-exists':
          return error.message ?? 'This already exists.';
        case 'resource-exhausted':
          return error.message ?? 'Rate limit reached. Please wait a moment.';
        case 'deadline-exceeded':
        case 'unavailable':
          return 'The server is temporarily unavailable. Please try again.';
        case 'internal':
          return 'An internal error occurred. Please try again later.';
        default:
          return 'Server error. Please try again.';
      }
    }

    // ─── Firestore ────────────────────────────────────────────────────
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to access this.';
        case 'unavailable':
        case 'deadline-exceeded':
          return 'The database is temporarily unavailable. Please try again.';
        case 'not-found':
          return 'That resource was not found.';
        default:
          return 'A data error occurred. Please try again.';
      }
    }

    // ─── Platform channel errors ──────────────────────────────────────
    if (error is PlatformException) {
      return 'A system error occurred. Please try again.';
    }

    // ─── String thrown by existing code (legacy) ─────────────────────
    // Our own `authentication_repository` throws strings on purpose —
    // these are already user-safe messages, so pass through.
    if (error is String) return error;

    // ─── Anything else: generic, stack-trace-free message ─────────────
    return 'Something went wrong. Please try again.';
  }
}
