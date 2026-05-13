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
  const ServerException({required super.message, super.code});
}

class AuthenticationException extends AppException {
  const AuthenticationException({required super.message, super.code});
}

class ParseException extends AppException {
  const ParseException({required super.message, super.code});
}
