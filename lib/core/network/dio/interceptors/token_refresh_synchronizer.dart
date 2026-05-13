import 'dart:async';

/// Serializes concurrent token-refresh calls. Multiple parallel 401s should
/// trigger ONE refresh attempt; subsequent callers await the in-flight
/// completer rather than each issuing their own refresh.
class TokenRefreshSynchronizer {
  TokenRefreshSynchronizer._();

  static Completer<String?>? _refreshCompleter;

  static Future<String?> refreshToken(
    Future<String?> Function() refreshCallback,
  ) async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;
    try {
      final newToken = await refreshCallback();
      completer.complete(newToken);
      return newToken;
    } catch (e, st) {
      completer.completeError(e, st);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }
}
