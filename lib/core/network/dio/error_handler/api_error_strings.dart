/// Wire-failure messages consumed by [DioExceptionUtil]. Lives inside the
/// network module so deleting `lib/core/network/` removes them — they're
/// useless without HTTP.
class ApiErrorStrings {
  ApiErrorStrings._();

  static const String noInternet = 'No internet connection';
  static const String requestTimedOut = 'Request timed out';
  static const String sendTimeout = 'Could not send request — please try again';
  static const String connectionFailed = 'Network connection failed';
  static const String requestCancelled = 'Request cancelled';
  static const String badCertificate = 'Invalid security certificate';
  static const String badRequest = 'Invalid request';
  static const String unauthorized = 'Authentication failed';
  static const String forbidden = 'Access denied';
  static const String notFound = 'Resource not found';
  static const String tooManyRequests = 'Too many requests';
  static const String serverError = 'Internal server error';
  static const String serviceUnavailable = 'Service unavailable';
  static const String unknownError = 'Network error occurred';
}
