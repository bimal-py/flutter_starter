/// Cross-cutting domain failure messages. Used by repositories and use cases
/// when local logic fails or a 2xx response has an unexpected shape. Network
/// failure messages live in [ApiErrorStrings] inside the network module.
///
/// Module-specific error strings should live alongside each module
/// (e.g. `lib/modules/<feature>/utils/<feature>_error_strings.dart`).
class AppErrorStrings {
  AppErrorStrings._();

  static const String somethingWentWrong = 'Something went wrong';
  static const String invalidResponseShape = 'Unexpected response from server';
  static const String missingRequiredField = 'Server response was incomplete';
  static const String operationFailed = 'Operation could not be completed';
}
