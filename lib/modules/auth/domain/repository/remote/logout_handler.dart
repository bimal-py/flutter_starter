abstract class LogoutHandler {
  /// Always clears the local session, even if the server call fails.
  /// [wasStillAuthenticated] false skips the server call (session already
  /// invalid, e.g. the refresh token expired).
  Future<void> logout({bool wasStillAuthenticated = true});
}
