class AuthError {
  AuthError._();

  // Thrown from the data layer — surfaced by AppErrorHandler.
  static const String invalidAuthResponse =
      'Unexpected response from the server. Please try again.';
  static const String missingTokens = 'Sign-in failed. Please try again.';
  static const String googleAuthFailed =
      'Google sign-in failed. Please try again.';
  static const String appleAuthFailed =
      'Apple sign-in failed. Please try again.';
  static const String googleNotConfigured =
      'Google sign-in isn’t set up in this build.';
  static const String appleNotConfigured =
      'Apple sign-in isn’t set up in this build.';
  static const String appleNotSupported =
      'Sign in with Apple isn’t available on this device.';
  static const String googleCancelled = 'Google sign-in was cancelled.';
  static const String appleCancelled = 'Apple sign-in was cancelled.';

  // Input checks before a request.
  static const String emailInvalid = 'Enter a valid email address';
  static const String passwordRequired = 'Enter your password';
  static const String currentPasswordRequired = 'Enter your current password';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordNeedsLettersAndNumbers =
      'Use letters and numbers';
  static const String passwordNeedsUpperAndLower =
      'Use an uppercase and a lowercase letter';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String codeRequired = 'Enter the code we emailed you';
  static const String termsRequired =
      'Accept the terms and conditions to continue';

  // Shown in the UI.
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
}
