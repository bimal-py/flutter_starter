import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';

abstract class RemoteAuthRepository {
  /// Signs in and persists the session.
  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  });

  /// Emails a 6-digit sign-up code. While an earlier code is still valid the
  /// server keeps it and reports [VerificationCodeEntity.alreadySent].
  Future<VerificationCodeEntity> sendVerificationCode({required String email});

  /// Creates the account with the emailed [code] and signs in. False when
  /// the account was created but signing in failed: the user logs in instead.
  Future<bool> register({
    required String email,
    required String code,
    required String password,
  });

  /// Google sign-in; the account is created on first use.
  Future<void> loginWithGoogle({required bool remember});

  /// Apple sign-in, same rules as [loginWithGoogle].
  Future<void> loginWithApple({required bool remember});

  /// Emails a reset code, or keeps the one still valid
  /// ([VerificationCodeEntity.alreadySent]).
  Future<VerificationCodeEntity> requestPasswordReset({required String email});

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Signed-in change; every device stays signed in.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
