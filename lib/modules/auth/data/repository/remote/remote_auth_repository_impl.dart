import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/data/mapper/mapper.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';
import 'package:flutter_starter/modules/user/user.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RemoteAuthRepository)
class RemoteAuthRepositoryImpl implements RemoteAuthRepository {
  RemoteAuthRepositoryImpl(
    this._remote,
    this._session,
    this._logoutInterceptor,
    this._thirdParty,
    this._remoteUsers,
    this._users,
  );

  final RemoteService _remote;
  final LocalAuthSessionRepository _session;
  final LogoutInterceptor _logoutInterceptor;
  final ThirdPartyAuthProvider _thirdParty;
  final RemoteUserRepository _remoteUsers;
  final LocalUserRepository _users;

  @override
  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  }) => _signIn(
    endPoint: AuthApiRoute.login,
    payload: {'email': email, 'password': password},
    remember: remember,
  );

  @override
  Future<VerificationCodeEntity> sendVerificationCode({
    required String email,
  }) async {
    final response = await _remote.postResponse(
      endPoint: AuthApiRoute.sendVerificationCode,
      payloadObj: {'email': email},
    );
    return VerificationCodeMapper.fromJsonToEntity(_data(response));
  }

  @override
  Future<bool> register({
    required String email,
    required String code,
    required String password,
  }) async {
    _logoutInterceptor.clearLoggedOut();
    // A failure here means no account was created.
    final response = await _remote.postResponse(
      endPoint: AuthApiRoute.register,
      payloadObj: {
        'email': email,
        'code': code,
        // The form has no name field yet: use the part before the @.
        'full_name': email.split('@').first,
        'password': password,
        'confirm_password': password,
      },
    );
    // The account exists now. If signing in fails, the user just logs in.
    try {
      await _finishSignIn(response, remember: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> loginWithGoogle({required bool remember}) async {
    final credential = await _thirdParty.retrieveGoogleCredential();
    return _socialSignIn(
      endPoint: AuthApiRoute.googleLogin,
      payload: {'id_token': credential.token},
      remember: remember,
    );
  }

  @override
  Future<void> loginWithApple({required bool remember}) async {
    final credential = await _thirdParty.retrieveAppleCredential();
    return _socialSignIn(
      endPoint: AuthApiRoute.appleLogin,
      payload: {
        'code': credential.token,
        'is_iphone': credential.isFromIos,
        if (credential.fullName != null) 'full_name': credential.fullName,
        if (credential.redirectUri != null)
          'redirect_uri': credential.redirectUri,
      },
      remember: remember,
    );
  }

  Future<void> _socialSignIn({
    required String endPoint,
    required Map<String, dynamic> payload,
    required bool remember,
  }) async {
    try {
      await _signIn(endPoint: endPoint, payload: payload, remember: remember);
    } catch (_) {
      // Let the user pick another Google account on the next try.
      await _thirdParty.signOut();
      rethrow;
    }
  }

  /// Sign-in answers with tokens only; then `users/me/` says who signed in.
  Future<void> _signIn({
    required String endPoint,
    required Map<String, dynamic> payload,
    required bool remember,
  }) async {
    // A forced logout blocks token requests; a fresh sign-in lifts it.
    _logoutInterceptor.clearLoggedOut();
    final response = await _remote.postResponse(
      endPoint: endPoint,
      payloadObj: payload,
    );
    await _finishSignIn(response, remember: remember);
  }

  /// After a sign-in reply: save the tokens, load who signed in
  /// (`users/me/`), keep the user, then save the session. The session goes
  /// last: it is what tells the app someone signed in.
  Future<void> _finishSignIn(dynamic response, {required bool remember}) async {
    try {
      final tokens = _data(response)['tokens'];
      await _saveTokens(tokens is Map<String, dynamic> ? tokens : const {});
      final user = await _remoteUsers.fetchUser();
      await _users.saveUser(user);
      await _session.saveSession(
        AuthSessionEntity(
          userId: user.id,
          email: user.email,
          remember: remember,
        ),
      );
      final email = user.email;
      if (remember && email != null) {
        await _session.saveRememberedEmail(email);
      } else {
        await _session.clearRememberedEmail();
      }
    } catch (_) {
      await _session.clearSession();
      await _users.clear();
      rethrow;
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final access = data['access'];
    final refresh = data['refresh'];
    if (access is! String || refresh is! String) {
      throw const AuthenticationException(message: AuthError.missingTokens);
    }
    await _session.saveTokens(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<VerificationCodeEntity> requestPasswordReset({
    required String email,
  }) async {
    final response = await _remote.postResponse(
      endPoint: AuthApiRoute.passwordReset,
      payloadObj: {'email': email},
    );
    return VerificationCodeMapper.fromJsonToEntity(_data(response));
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _remote.postResponse(
      endPoint: AuthApiRoute.passwordResetConfirm,
      payloadObj: {'email': email, 'code': code, 'new_password': newPassword},
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Every device stays signed in, so the current tokens stay valid.
    await _remote.postResponse(
      endPoint: AuthApiRoute.password,
      payloadObj: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      isTokenRequired: true,
    );
  }

  // `data` of the envelope, or an empty map.
  static Map<String, dynamic> _data(dynamic response) =>
      ApiResponseEnvelope.asObject(response) ?? const {};
}
