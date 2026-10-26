import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';
import 'package:injectable/injectable.dart';

/// Plugs the signed-in session into the network layer: [RemoteServiceImpl]
/// signs `isTokenRequired` requests with [accessToken], renews it on a
/// 401/403 and logs out once that fails for good.
@LazySingleton(as: AuthTokenHandler)
class AuthTokenHandlerImpl implements AuthTokenHandler {
  AuthTokenHandlerImpl(this._session, this._logoutHandler, this._dioConfig);

  final LocalAuthSessionRepository _session;
  final LogoutHandler _logoutHandler;
  final DioConfig _dioConfig;

  @override
  Future<String?> accessToken() => _session.getAccessToken();

  // Returns null on any failure — the RetryInterceptor decides whether to
  // log out once retries are exhausted.
  @override
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _session.getRefreshToken() ?? '';
    if (refreshToken.isEmpty) return null;

    try {
      // Fresh client without auth/retry interceptors — a 401 here must not
      // re-enter refresh.
      final response = await getIt<DioClient>().dio.post(
        '${_dioConfig.baseUrl}/${AuthApiRoute.refresh}',
        // SimpleJWT's TokenRefreshView reads `refresh`.
        data: {'refresh': refreshToken},
      );

      final newAccessToken = _extract(response.data, const [
        'access_token',
        'access',
      ]);
      final newRefreshToken = _extract(response.data, const [
        'refresh_token',
        'refresh',
      ]);

      if (newAccessToken == null) return null;

      await _session.saveTokens(
        accessToken: newAccessToken,
        // Without rotation the server keeps the refresh token as it was.
        refreshToken: newRefreshToken ?? refreshToken,
      );
      return newAccessToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> onSessionExpired() =>
      _logoutHandler.logout(wasStillAuthenticated: false);

  String? _extract(dynamic body, List<String> keys) {
    if (body is! Map) return null;
    final root = body['data'] is Map ? body['data'] as Map : body;
    for (final key in keys) {
      final value = root[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
