import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';

/// Gets a Google / Apple credential from the platform SDK.
abstract class ThirdPartyAuthProvider {
  /// Throws [ThirdPartyAuthCancelled] when the user closes the sheet.
  Future<ThirdPartyCredential> retrieveGoogleCredential();

  /// Throws [ThirdPartyAuthCancelled] when the user closes the sheet.
  Future<ThirdPartyCredential> retrieveAppleCredential();

  /// Forgets the Google account so the next sign-in shows the picker again.
  Future<void> signOut();
}

/// The user backed out of the Google / Apple sheet: shown as a short notice,
/// not an error.
class ThirdPartyAuthCancelled extends AppException {
  const ThirdPartyAuthCancelled(this.provider)
    : super(
        message: provider == ThirdPartyProvider.google
            ? AuthError.googleCancelled
            : AuthError.appleCancelled,
      );

  final ThirdPartyProvider provider;
}
