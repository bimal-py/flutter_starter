import 'package:flutter_starter/core/errors/exceptions.dart';
import 'package:flutter_starter/modules/auth/domain/entity/auth_user.dart';
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart';
import 'package:flutter_starter/modules/auth/domain/repository/local/user_session_store.dart';
import 'package:injectable/injectable.dart';

/// Working stub. Accepts any non-empty credentials and fabricates an
/// [AuthUser]; exercises the real Hive + secure-storage round-trip so the
/// pipeline (bloc → bootstrapper → state) is testable end-to-end without a
/// backend. **Swap before shipping** — write your own
/// `@LazySingleton(as: AuthRepository)` class (REST / Firebase / Supabase /
/// …) and delete this one.
///
/// Google / Apple sign-in throw "not configured" — a real
/// implementation wires `ThirdPartyAuthProvider` into its own constructor.
@LazySingleton(as: AuthRepository)
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository(this._store);

  final UserSessionStore _store;

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw const AuthenticationException(
        message: 'Email and password are required',
      );
    }
    await _persistFakeSession(email: email);
  }

  @override
  Future<void> registerEmail({required String email}) async {
    if (email.isEmpty) {
      throw const AuthenticationException(message: 'Email is required');
    }
  }

  @override
  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    String code = '',
    String? phoneNumber,
  }) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      throw const AuthenticationException(message: 'Missing required fields');
    }
    await _persistFakeSession(email: email, displayName: fullName);
  }

  @override
  Future<void> forgetPassword({required String email}) async {
    if (email.isEmpty) {
      throw const AuthenticationException(message: 'Email is required');
    }
  }

  @override
  Future<void> resetPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      throw const AuthenticationException(
        message: 'Both passwords are required',
      );
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    throw const AuthenticationException(
      message:
          'Google sign-in is not configured. Wire ThirdPartyAuthProvider in your AuthRepository implementation.',
    );
  }

  @override
  Future<void> loginWithApple() async {
    throw const AuthenticationException(
      message:
          'Apple sign-in is not configured. Wire ThirdPartyAuthProvider in your AuthRepository implementation.',
    );
  }

  @override
  Future<AuthUser?> getLoggedInUser() => _store.getUser();

  @override
  Stream<AuthUser?> watchUser() => _store.watchUser();

  @override
  Future<void> logout({bool wasStillAuthenticated = true}) =>
      _store.clearSession();

  Future<void> _persistFakeSession({
    required String email,
    String? displayName,
  }) async {
    final user = AuthUser(
      id: email.hashCode.toRadixString(16),
      email: email,
      displayName: displayName ?? email.split('@').first,
      isEmailVerified: true,
    );
    await _store.saveSession(
      user: user,
      accessToken: 'fake-access-${email.hashCode}',
      refreshToken: 'fake-refresh-${email.hashCode}',
    );
  }
}
