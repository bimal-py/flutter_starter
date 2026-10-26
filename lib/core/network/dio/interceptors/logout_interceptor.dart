import 'package:dio/dio.dart';
import 'package:flutter_starter/core/network/service/service.dart';
import 'package:injectable/injectable.dart';

/// Short-circuits token-carrying requests after the user logs out. The auth
/// module calls [markAsLoggedOut] on logout and [clearLoggedOut] on the next
/// sign-in; blocked requests fail fast with a cancel-type [DioException].
@singleton
class LogoutInterceptor extends Interceptor {
  bool _isLoggedOut = false;

  void markAsLoggedOut() => _isLoggedOut = true;
  void clearLoggedOut() => _isLoggedOut = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only block requests that would have carried a token — login/register
    // and other unauthed calls have no stale credential to worry about and
    // should still go through (otherwise a forced logout would lock the
    // user out of re-logging in until the app restarts).
    if (_isLoggedOut && options.isTokenRequired) {
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
