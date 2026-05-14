import 'package:flutter_starter/modules/auth/domain/entity/auth_user.dart';

/// Local persistence contract: the [AuthUser] snapshot + access/refresh tokens.
/// Default is `HiveSecureSessionStore` (Hive `app_box` for the user,
/// `flutter_secure_storage` for tokens). Swap by implementing this and passing
/// into your [AuthRepository].
abstract class UserSessionStore {
  Future<void> saveUser(AuthUser user);
  Future<AuthUser?> getUser();
  Future<void> clearUser();

  /// Implementations must emit the current value on subscribe, emit `null`
  /// after [clearUser] / [clearSession], and use a broadcast controller.
  Stream<AuthUser?> watchUser();

  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> clearAccessToken();

  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  });

  /// Clears user + both tokens and emits `null` on [watchUser] exactly once.
  Future<void> clearSession();
}
