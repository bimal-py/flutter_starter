/// Pluggable OAuth provider contract (Google, Apple, GitHub, …). The starter
/// ships no concrete implementations — those drag in heavy platform deps —
/// so wire one and pass it into your [AuthRepository] constructor when needed.
///
/// `true` means the provider step succeeded and produced enough data
/// (server auth code / id token) for the repository to finish the login
/// server-side.
abstract class ThirdPartyAuthProvider {
  Future<bool> loginWithGoogle();

  /// Implementations on Android need the `state` + SHA-256 `nonce` dance for
  /// security; iOS gets it for free natively.
  Future<bool> loginWithApple();

  /// Called as part of logout so the next sign-in re-prompts the account
  /// picker instead of silently reusing the cached account.
  Future<void> signOut();
}
