import 'package:flutter_starter/modules/auth/utils/constants/constants.dart';

/// Client-side checks that match the backend rules, so obvious mistakes are
/// caught before a round trip. Each returns null when the value is fine.
class AuthValidators {
  AuthValidators._();

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static String? email(String? value) =>
      isValidEmail(value ?? '') ? null : AuthError.emailInvalid;

  /// A new password, by the backend's rules: 8 or more characters, letters
  /// and a number, an uppercase and a lowercase letter.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.length < 8) return AuthError.passwordTooShort;
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return AuthError.passwordNeedsLettersAndNumbers;
    }
    if (!RegExp('[A-Z]').hasMatch(v) || !RegExp('[a-z]').hasMatch(v)) {
      return AuthError.passwordNeedsUpperAndLower;
    }
    return null;
  }

  /// The repeat of [password]; [requiredMessage] when it is left empty.
  static String? confirmPassword(
    String? value,
    String password, {
    required String requiredMessage,
  }) {
    if ((value ?? '').isEmpty) return requiredMessage;
    return value == password ? null : AuthError.passwordsDoNotMatch;
  }

  static String? requiredPassword(String? value) =>
      (value ?? '').isEmpty ? AuthError.passwordRequired : null;
}
