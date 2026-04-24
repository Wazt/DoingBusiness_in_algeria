import 'package:cloud_functions/cloud_functions.dart';
import 'package:doingbusiness/utils/error_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for [ErrorMapper]. The goal is to guarantee no stack trace
/// or raw FirebaseException detail ever leaks to user-facing snackbars —
/// each code path must return a short, human-readable message.
void main() {
  group('ErrorMapper.toUserMessage · FirebaseAuthException', () {
    final cases = <String, String>{
      'invalid-email': 'The email address is invalid.',
      'user-disabled': 'This account has been disabled.',
      'user-not-found': 'No account found with this email.',
      'wrong-password': 'Incorrect password.',
      'invalid-credential': 'Email or password is incorrect.',
      'email-already-in-use':
          'An account with this email already exists.',
      'operation-not-allowed':
          'This sign-in method is currently disabled.',
      'weak-password': 'Password is too weak.',
      'too-many-requests': 'Too many attempts — please wait a moment.',
      'requires-recent-login':
          'Please sign in again to confirm this action.',
      'network-request-failed': 'No internet connection.',
    };

    cases.forEach((code, expectedMessage) {
      test('maps "$code" to user-safe message', () {
        final e = FirebaseAuthException(code: code, message: 'raw firebase msg');
        expect(ErrorMapper.toUserMessage(e), expectedMessage);
      });
    });

    test('unknown code falls back to generic auth message', () {
      final e = FirebaseAuthException(code: 'some-new-code');
      expect(
        ErrorMapper.toUserMessage(e),
        'Authentication failed. Please try again.',
      );
    });
  });

  group('ErrorMapper.toUserMessage · FirebaseFunctionsException', () {
    test('unauthenticated', () {
      final e = FirebaseFunctionsException(
        code: 'unauthenticated',
        message: 'raw',
      );
      expect(
        ErrorMapper.toUserMessage(e),
        'You must be signed in to do this.',
      );
    });

    test('permission-denied', () {
      final e = FirebaseFunctionsException(
        code: 'permission-denied',
        message: 'raw',
      );
      expect(
        ErrorMapper.toUserMessage(e),
        'You do not have permission to perform this action.',
      );
    });

    test('invalid-argument surfaces the server message', () {
      final e = FirebaseFunctionsException(
        code: 'invalid-argument',
        message: 'URL must be a LinkedIn post.',
      );
      expect(
        ErrorMapper.toUserMessage(e),
        'URL must be a LinkedIn post.',
      );
    });

    test('resource-exhausted surfaces the server message or falls back', () {
      final e1 = FirebaseFunctionsException(
        code: 'resource-exhausted',
        message: 'Wait 30 seconds.',
      );
      expect(ErrorMapper.toUserMessage(e1), 'Wait 30 seconds.');

      final e2 = FirebaseFunctionsException(code: 'resource-exhausted', message: '');
      expect(
        ErrorMapper.toUserMessage(e2),
        'Rate limit reached. Please wait a moment.',
      );
    });

    test('unavailable returns a retry-friendly message', () {
      final e = FirebaseFunctionsException(code: 'unavailable', message: '');
      expect(
        ErrorMapper.toUserMessage(e),
        'The server is temporarily unavailable. Please try again.',
      );
    });
  });

  group('ErrorMapper.toUserMessage · Firestore FirebaseException', () {
    test('permission-denied', () {
      final e = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      expect(
        ErrorMapper.toUserMessage(e),
        'You do not have permission to access this.',
      );
    });

    test('not-found', () {
      final e = FirebaseException(plugin: 'cloud_firestore', code: 'not-found');
      expect(ErrorMapper.toUserMessage(e), 'That resource was not found.');
    });

    test('unknown code returns generic data error', () {
      final e = FirebaseException(plugin: 'cloud_firestore', code: 'weird');
      expect(
        ErrorMapper.toUserMessage(e),
        'A data error occurred. Please try again.',
      );
    });
  });

  group('ErrorMapper.toUserMessage · pass-through + fallback', () {
    test('PlatformException returns a generic system message', () {
      final e = PlatformException(code: 'anything');
      expect(
        ErrorMapper.toUserMessage(e),
        'A system error occurred. Please try again.',
      );
    });

    test('String messages are passed through (legacy auth repo)', () {
      const msg = 'You must be signed in.';
      expect(ErrorMapper.toUserMessage(msg), msg);
    });

    test('Unknown error types get a generic fallback', () {
      final e = Object();
      expect(
        ErrorMapper.toUserMessage(e),
        'Something went wrong. Please try again.',
      );
    });

    test('Never surfaces "Instance of" style output for arbitrary classes',
        () {
      final e = Exception('boom');
      final msg = ErrorMapper.toUserMessage(e);
      expect(msg.contains('Instance of'), isFalse);
      expect(msg.contains('Exception'), isFalse);
    });
  });
}
