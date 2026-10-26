/// The sign-in session as the network layer sees it: the token to send, how
/// to renew it, and what to do once it can't be renewed.
///
/// The auth module registers the implementation. The network layer looks it
/// up per request and never imports the auth module, so deleting auth leaves
/// HTTP working: `isTokenRequired` requests just go out unsigned and a 401 is
/// an ordinary error.
abstract class AuthTokenHandler {
  /// Sent as `Authorization: Bearer …` on `isTokenRequired` requests.
  Future<String?> accessToken();

  /// Trades the refresh token for a new access token and stores both.
  /// Returns null on any failure; the retry interceptor decides what's next.
  Future<String?> refreshAccessToken();

  /// Every retry of an authed 401/403 failed: the session is over.
  Future<void> onSessionExpired();
}
