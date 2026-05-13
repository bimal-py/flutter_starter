import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum LogLevel { none, basic, headers, body }

/// Lightweight Dio logger. Defaults to [LogLevel.body] in debug and
/// [LogLevel.none] in release. Switch level when wiring into [DioClient].
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    LogLevel? level,
    this.compact = false,
    void Function(String?)? logPrint,
  })  : level = level ?? (kDebugMode ? LogLevel.body : LogLevel.none),
        logPrint = logPrint ?? debugPrint;

  final LogLevel level;
  final bool compact;
  final void Function(String?) logPrint;
  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (level == LogLevel.none) return handler.next(options);
    logPrint('--> ${options.method} ${options.uri}');
    if (level == LogLevel.basic) return handler.next(options);

    options.headers.forEach((k, v) => logPrint('$k: $v'));
    if (level == LogLevel.headers) return handler.next(options);

    if (options.data != null) _logPayload(options.data);
    logPrint('--> END ${options.method}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (level == LogLevel.none) return handler.next(response);
    logPrint(
      '<-- ${response.statusCode} ${response.statusMessage ?? ''} ${response.requestOptions.uri}',
    );
    if (level == LogLevel.basic) return handler.next(response);

    response.headers.forEach((k, v) => logPrint('$k: ${v.join(',')}'));
    if (level == LogLevel.headers) return handler.next(response);

    if (response.data != null) _logPayload(response.data);
    logPrint('<-- END HTTP');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (level == LogLevel.none) return handler.next(err);
    logPrint('<-- HTTP FAILED: ${err.message}');
    handler.next(err);
  }

  void _logPayload(dynamic data) {
    if (data is Map) {
      if (compact) {
        logPrint('$data');
      } else {
        _encoder.convert(data).split('\n').forEach(logPrint);
      }
    } else if (data is! FormData) {
      logPrint(data.toString());
    }
  }
}
