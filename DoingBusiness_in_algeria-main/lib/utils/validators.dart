/// ════════════════════════════════════════════════════════════════════════
///  FIELD VALIDATORS — returns String? (null = valid, string = error message)
/// ════════════════════════════════════════════════════════════════════════
///  Usage in a TextFormField:
///    validator: FieldsValidators.validatingEmail,          // tear-off (preferred)
///    validator: (v) => FieldsValidators.validatingEmail(v),// also fine
///
///  NEVER use:
///    validator: (v) { FieldsValidators.validatingEmail(v); }  // ← ignores result
/// ════════════════════════════════════════════════════════════════════════
class FieldsValidators {
  FieldsValidators._();

  /// Required, non-empty text field (username, address, etc.)
  static String? validatingField(String fieldName, String? value) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length < 2) return '$fieldName is too short';
    return null;
  }

  /// RFC-5322-ish email validator. Strict enough to catch obvious mistakes.
  static String? validatingEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email';
    return null;
  }

  /// Password policy — aligned with NIST SP 800-63B-4 (2024).
  ///   - At least 8 characters (was 6)
  ///   - At least 1 uppercase, 1 lowercase, 1 digit, 1 special character
  ///   - Block the 50 most common weak passwords
  static String? validatingPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Add an uppercase letter';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Add a lowercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Add a digit';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>~_\-+=\[\]\\/]'))) {
      return 'Add a special character';
    }
    if (_commonWeakPasswords.contains(value.toLowerCase())) {
      return 'This password is too common — pick something unique';
    }
    return null;
  }

  /// Confirms a second password field matches the first.
  static String? validatingPasswordConfirmation(String? value, String? original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Phone number — flexible, accepts international format with optional +.
  static String? validatingPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Tiny deny-list — keep short, NIST recommends backing this with a
  /// real breached-password service (HaveIBeenPwned) if you go further.
  static const _commonWeakPasswords = <String>{
    'password', 'password1', 'password123', '12345678', '123456789',
    'qwerty123', 'abc12345', 'iloveyou', 'admin123', 'welcome1',
    'letmein1', 'sunshine', 'password!', 'p@ssw0rd', 'p@ssword1',
  };
}
