import 'package:doingbusiness/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

/// ════════════════════════════════════════════════════════════════════════
///  Replaces the default Flutter counter template test (which tested a
///  counter that doesn't exist in this app, so it never could have passed).
/// ════════════════════════════════════════════════════════════════════════
void main() {
  group('FieldsValidators.validatingEmail', () {
    test('rejects null', () {
      expect(FieldsValidators.validatingEmail(null), isNotNull);
    });
    test('rejects empty', () {
      expect(FieldsValidators.validatingEmail(''), isNotNull);
    });
    test('rejects malformed', () {
      expect(FieldsValidators.validatingEmail('not-an-email'), isNotNull);
      expect(FieldsValidators.validatingEmail('a@b'), isNotNull);
      expect(FieldsValidators.validatingEmail('@example.com'), isNotNull);
      expect(FieldsValidators.validatingEmail('user@.com'), isNotNull);
    });
    test('accepts valid', () {
      expect(FieldsValidators.validatingEmail('user@example.com'), isNull);
      expect(FieldsValidators.validatingEmail('first.last+tag@sub.example.co'), isNull);
    });
    test('trims leading/trailing whitespace', () {
      expect(FieldsValidators.validatingEmail('  user@example.com  '), isNull);
    });
  });

  group('FieldsValidators.validatingPassword', () {
    test('rejects null / empty', () {
      expect(FieldsValidators.validatingPassword(null), isNotNull);
      expect(FieldsValidators.validatingPassword(''), isNotNull);
    });
    test('rejects < 8 chars', () {
      expect(FieldsValidators.validatingPassword('Ab1!'), isNotNull);
      expect(FieldsValidators.validatingPassword('Abc12!d'), isNotNull);
    });
    test('rejects missing uppercase', () {
      expect(FieldsValidators.validatingPassword('abcd123!'), isNotNull);
    });
    test('rejects missing lowercase', () {
      expect(FieldsValidators.validatingPassword('ABCD123!'), isNotNull);
    });
    test('rejects missing digit', () {
      expect(FieldsValidators.validatingPassword('Abcdefg!'), isNotNull);
    });
    test('rejects missing special', () {
      expect(FieldsValidators.validatingPassword('Abcd1234'), isNotNull);
    });
    test('rejects common weak passwords', () {
      expect(FieldsValidators.validatingPassword('Password123!'), isNotNull);
      expect(FieldsValidators.validatingPassword('P@ssw0rd1'), isNotNull);
    });
    test('accepts strong password', () {
      expect(FieldsValidators.validatingPassword('Tz9#kL8mQ2!'), isNull);
    });
  });

  group('FieldsValidators.validatingField', () {
    test('rejects null / empty / whitespace-only', () {
      expect(FieldsValidators.validatingField('Username', null), isNotNull);
      expect(FieldsValidators.validatingField('Username', ''), isNotNull);
      expect(FieldsValidators.validatingField('Username', '   '), isNotNull);
    });
    test('rejects 1-char', () {
      expect(FieldsValidators.validatingField('Username', 'a'), isNotNull);
    });
    test('accepts valid', () {
      expect(FieldsValidators.validatingField('Username', 'Ali'), isNull);
    });
  });

  group('FieldsValidators.validatingPasswordConfirmation', () {
    test('rejects mismatch', () {
      expect(
        FieldsValidators.validatingPasswordConfirmation('Tz9#kL8m', 'differentPassword1!'),
        isNotNull,
      );
    });
    test('accepts match', () {
      expect(
        FieldsValidators.validatingPasswordConfirmation('Tz9#kL8m', 'Tz9#kL8m'),
        isNull,
      );
    });
  });
}
