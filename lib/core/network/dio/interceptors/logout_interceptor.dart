import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Short-circuits every request after the user logs out. An auth module (when
/// added) calls [markAsLoggedOut] to engage; subsequent requests fail-fast
/// with a cancel-type [DioException] instead of hitting the network.
@singleton
class LogoutInterceptor extends Interceptor {
  bool _isLoggedOut = false;

  void markAsLoggedOut() => _isLoggedOut = true;
  void clearLoggedOut() => _isLoggedOut = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isLoggedOut) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'User logged out — request blocked',
          type: DioExceptionType.cancel,
        ),
      );
    }
    super.onRequest(options, handler);
  }
}
