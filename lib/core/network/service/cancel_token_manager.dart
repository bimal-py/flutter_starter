import 'package:dio/dio.dart';

/// Lets callers cancel every in-flight request (e.g. on logout). Mint a fresh
/// token after cancelling so subsequent calls don't all immediately fail.
class GlobalCancelTokenManager {
  GlobalCancelTokenManager._();

  static CancelToken? _cancelToken;

  static CancelToken get token => _cancelToken ??= CancelToken();

  static void cancelAllRequests([String reason = 'cancelled']) {
    _cancelToken?.cancel(reason);
    _cancelToken = CancelToken();
  }
}
