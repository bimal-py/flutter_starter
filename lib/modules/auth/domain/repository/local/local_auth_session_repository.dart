import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';

abstract class LocalAuthSessionRepository {
  Future<AuthSessionEntity?> getSession();

  /// Current session first, then every change (null after logout).
  Stream<AuthSessionEntity?> watchSession();

  Future<void> saveSession(AuthSessionEntity session);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> clearSession();

  /// The email from the last login with "Remember me" on, kept across
  /// logouts so the login form can be prefilled.
  String? rememberedEmail();

  Future<void> saveRememberedEmail(String email);

  Future<void> clearRememberedEmail();
}
