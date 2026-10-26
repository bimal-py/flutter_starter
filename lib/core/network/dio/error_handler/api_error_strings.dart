/// Wire-failure messages consumed by [DioExceptionUtil]. Lives inside the
/// network module so deleting `lib/core/network/` removes them — they're
/// useless without HTTP.
class ApiErrorStrings {
  ApiErrorStrings._();

  static const String noInternet = 'No internet connection';
  static const String cannotReachServer =
      'Can’t reach the server. Check your internet connection and try again.';
  static const String requestTimedOut = 'Request timed out. Please try again.';
  static const String sendTimeout = 'Could not send request — please try again';
  static const String connectionFailed = 'Network connection failed';
  static const String requestCancelled = 'Request cancelled';
  static const String badCertificate = 'Invalid security certificate';
  static const String badRequest = 'Invalid request';
  static const String unauthorized = 'Authentication failed';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String forbidden = 'You don’t have permission to do this.';
  static const String notFound = 'Not found.';
  static const String tooManyRequests = 'Too many requests';
  static const String serverError = 'Server error. Please try again shortly.';
  static const String serviceUnavailable = 'Service unavailable';
  static const String unknownError = 'Something went wrong. Please try again.';

  /// The backend's catch-all `message`; a more specific error is preferred.
  static const String genericServerMessage = 'Failed to proceed the request.';
}
