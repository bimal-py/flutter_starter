import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';
import 'package:flutter_starter/modules/user/user.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LogoutHandler)
class LogoutHandlerImpl implements LogoutHandler {
  LogoutHandlerImpl(
    this._session,
    this._users,
    this._dioConfig,
    this._logoutInterceptor,
    this._thirdParty,
  );

  final LocalAuthSessionRepository _session;
  final LocalUserRepository _users;
  final DioConfig _dioConfig;
  final LogoutInterceptor _logoutInterceptor;
  final ThirdPartyAuthProvider _thirdParty;

  /// Signs out at once, online or not: the server is told in the background
  /// (it never holds the user here), then the session and everything saved
  /// for it goes.
  @override
  Future<void> logout({bool wasStillAuthenticated = true}) async {
    if (wasStillAuthenticated) {
      try {
        // Read before anything is cleared; sent without waiting.
        final tellServer = await _serverLogout();
        unawaited(tellServer().catchError((_) {}));
      } catch (_) {
        // Nothing to send: sign out locally.
      }
    }
    GlobalCancelTokenManager.cancelAllRequests('logout');
    _logoutInterceptor.markAsLoggedOut();
    await _session.clearSession();
    await _users.clear();
    try {
      await _thirdParty.signOut().timeout(_quick);
    } catch (_) {
      // Google / Apple unreachable: their sign-in is asked again anyway.
    }
  }

  /// Offline, nothing waits longer than this.
  static const Duration _quick = Duration(seconds: 2);

  // Fresh client without auth/retry interceptors: a 401 here must not
  // re-enter the refresh flow. The tokens are read now; the returned call
  // sends them.
  Future<Future<void> Function()> _serverLogout() async {
    final accessToken = await _session.getAccessToken() ?? '';
    final refreshToken = await _session.getRefreshToken() ?? '';
    final dio = getIt<DioClient>().dio;
    return () async {
      if (accessToken.isEmpty || refreshToken.isEmpty) return;
      await dio.post(
        '${_dioConfig.baseUrl}/${AuthApiRoute.logout}',
        data: {'refresh': refreshToken},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    };
  }
}
