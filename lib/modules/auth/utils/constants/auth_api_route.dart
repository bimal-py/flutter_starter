class AuthApiRoute {
  AuthApiRoute._();

  static const String login = 'auth/login/';

  /// Email sign-up: code first, then register.
  static const String sendVerificationCode = 'auth/send/verify-email/';
  static const String register = 'auth/register/';
  static const String googleLogin = 'auth/google/';
  static const String appleLogin = 'auth/apple/';
  static const String logout = 'auth/logout/';
  static const String passwordReset = 'auth/password/reset/';
  static const String passwordResetConfirm = 'auth/password/reset/confirm/';

  /// Change password (no password yet → Forgot password).
  static const String password = 'auth/password/';

  /// SimpleJWT refresh.
  static const String refresh = 'auth/token/refresh/';
}
