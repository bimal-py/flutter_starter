class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

class ServerException extends AppException {
  const ServerException({required super.message, super.code, this.statusCode});

  /// HTTP status of the reply; null when the server wasn't reached
  /// (offline, timeout).
  final int? statusCode;

  /// The server answered and refused the request (4xx): the request itself
  /// was the problem, not the connection or the server.
  bool get isRejected =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;
}

class AuthenticationException extends AppException {
  const AuthenticationException({required super.message, super.code});
}

class ParseException extends AppException {
  const ParseException({required super.message, super.code});
}
