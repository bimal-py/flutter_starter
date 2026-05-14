import 'package:flutter_starter/modules/auth/domain/entity/auth_user.dart';

/// Backend-agnostic auth contract — swap implementations for REST / Firebase /
/// Supabase / `InMemoryAuthRepository`. Implementations persist via
/// [UserSessionStore], emit on [watchUser] when that storage changes, and
/// translate provider errors to [AuthenticationException] before they cross
/// this boundary.
abstract class AuthRepository {
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Optional two-step registration: ship a verification code to [email].
  /// No-op for backends that don't gate sign-up behind a code.
  Future<void> registerEmail({required String email});

  /// Finalise registration. Pass an empty [code] when the backend doesn't
  /// require email verification.
  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    String code = '',
    String? phoneNumber,
  });

  Future<void> forgetPassword({required String email});

  Future<void> resetPassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> loginWithGoogle();
  Future<void> loginWithApple();

  Future<AuthUser?> getLoggedInUser();

  Stream<AuthUser?> watchUser();

  /// [wasStillAuthenticated] = false signals a session that's already invalid
  /// server-side (revocation, 401 from interceptor) so the impl can skip the
  /// server-hop and clear local state only.
  Future<void> logout({bool wasStillAuthenticated = true});
}
