import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';
import 'package:injectable/injectable.dart';

/// Placeholder until the app ships social login. The real implementation
/// wraps `google_sign_in` (return the ID token) and `sign_in_with_apple`
/// (return the authorization code, [ThirdPartyCredential.isFromIos], the
/// first-time full name and, on Android, the redirect URI), and throws
/// [ThirdPartyAuthCancelled] when the user closes the sheet. Register it with
/// `@LazySingleton(as: ThirdPartyAuthProvider)` and delete this file.
@LazySingleton(as: ThirdPartyAuthProvider)
class ThirdPartyAuthProviderStub implements ThirdPartyAuthProvider {
  @override
  Future<ThirdPartyCredential> retrieveGoogleCredential() async {
    throw const AuthenticationException(message: AuthError.googleNotConfigured);
  }

  @override
  Future<ThirdPartyCredential> retrieveAppleCredential() async {
    throw const AuthenticationException(message: AuthError.appleNotConfigured);
  }

  @override
  Future<void> signOut() async {}
}
