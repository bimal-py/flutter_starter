/// Cross-cutting domain failure messages. Used by repositories and use cases
/// when local logic fails or a 2xx response has an unexpected shape. Network
/// failure messages live in `ApiErrorStrings` (`core/network/dio/`).
///
/// A module's own messages live in its `utils/constants/<feature>_error.dart`
/// (e.g. `AuthError`).
class AppErrorStrings {
  AppErrorStrings._();

  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Try again';
  static const String invalidResponseShape = 'Unexpected response from server';
  static const String missingRequiredField = 'Server response was incomplete';
  static const String operationFailed = 'Operation could not be completed';
  static const String noInternetConnection = 'No internet connection';
  static const String pageNotFound = "This page doesn't exist.";
}
