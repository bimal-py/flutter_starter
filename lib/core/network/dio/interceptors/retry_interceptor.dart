import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/network/dio/interceptors/interceptors.dart';
import 'package:flutter_starter/core/network/service/service.dart';

typedef RetryEvaluator = FutureOr<bool> Function(DioException error);

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    RetryOptions? options,
    this.shouldLog = true,
    this.refreshTokenCallback,
    this.onAuthFailureExhausted,
  }) : options = options ?? const RetryOptions();

  final Dio dio;
  final RetryOptions options;
  final bool shouldLog;
  final Future<String?> Function()? refreshTokenCallback;
  // Fired (fire-and-forget) once the retry counter is exhausted on an authed
  // 401/403. Lets the session clear AFTER every retry chance is used — we no
  // longer log out on the first refresh failure, so transient backend hiccups
  // don't kick the user back to login.
  final Future<void> Function()? onAuthFailureExhausted;

  static const String _refreshAttemptedKey = 'auth_refresh_attempted';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    var extra = RetryOptions.fromExtra(err.requestOptions, options);
    final statusCode = err.response?.statusCode;
    final isAuthError = statusCode == 401 || statusCode == 403;
    final isTokenRequired = err.requestOptions.isTokenRequired;

    // Refresh once per request lifecycle; subsequent retries reuse the new
    // token. Refreshing on every auth error within the same request would just
    // hit the same wall and waste a network round-trip. The backend returns 403
    // (not 401) for a missing/expired token, so refresh on both.
    if (isAuthError &&
        refreshTokenCallback != null &&
        isTokenRequired &&
        err.requestOptions.extra[_refreshAttemptedKey] != true) {
      err.requestOptions.extra[_refreshAttemptedKey] = true;
      final newToken = await TokenRefreshSynchronizer.refreshToken(
        refreshTokenCallback!,
      );
      if (newToken != null && newToken.isNotEmpty) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      }
      // Refresh failed → fall through to the retry counter. Logout only fires
      // once retries are exhausted below.
    }

    final shouldRetry = extra.retries > 0 && await options.retryEvaluator(err);
    if (!shouldRetry) {
      if (isAuthError && isTokenRequired && onAuthFailureExhausted != null) {
        unawaited(onAuthFailureExhausted!());
      }
      return super.onError(err, handler);
    }

    if (extra.retryInterval.inMilliseconds > 0) {
      await Future.delayed(extra.retryInterval);
    }

    extra = extra.copyWith(retries: extra.retries - 1);
    err.requestOptions.extra = err.requestOptions.extra
      ..addAll(extra.toExtra());

    if (shouldLog) {
      developer.log(
        '[${err.requestOptions.uri}] retry (remaining: ${extra.retries}) — ${err.message}',
      );
    }

    try {
      dynamic newData = err.requestOptions.data;
      if (err.requestOptions.hasFiles) {
        final originalBody = err.requestOptions.originalBody;
        final files = err.requestOptions.files;
        final formData = FormData.fromMap(originalBody ?? {});
        for (final entry in files!.entries) {
          formData.files.add(
            MapEntry(
              entry.key,
              await MultipartFile.fromFile(
                entry.value.path,
                // Same short, safe filename as the first attempt — otherwise a
                // retried upload leaks the long temp name.
                filename: buildUploadFilename(
                  entry.value.path,
                  originalBody?['name'],
                ),
              ),
            ),
          );
        }
        newData = formData;
      }

      final response = await dio.request(
        err.requestOptions.path,
        cancelToken: err.requestOptions.cancelToken,
        data: newData,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
        onSendProgress: err.requestOptions.onSendProgress,
        queryParameters: err.requestOptions.queryParameters,
        options: _toOptions(
          err.requestOptions,
          rebuiltFormData: err.requestOptions.hasFiles,
        ),
      );
      handler.resolve(response);
    } catch (e) {
      handler.reject(
        e is DioException
            ? e
            : DioException(requestOptions: err.requestOptions, error: e),
      );
    }
  }

  Options _toOptions(RequestOptions r, {bool rebuiltFormData = false}) {
    final headers = Map<String, dynamic>.from(r.headers);
    var contentType = r.contentType;
    if (rebuiltFormData) {
      // The retried FormData has a fresh boundary — drop the stale content-type
      // so Dio re-derives `multipart/form-data; boundary=...` for the new body.
      headers.remove(Headers.contentTypeHeader);
      contentType = Headers.multipartFormDataContentType;
    }
    return Options(
      method: r.method,
      sendTimeout: r.sendTimeout,
      receiveTimeout: r.receiveTimeout,
      extra: r.extra,
      headers: headers,
      responseType: r.responseType,
      contentType: contentType,
      validateStatus: r.validateStatus,
      receiveDataWhenStatusError: r.receiveDataWhenStatusError,
      followRedirects: r.followRedirects,
      maxRedirects: r.maxRedirects,
      requestEncoder: r.requestEncoder,
      responseDecoder: r.responseDecoder,
      listFormat: r.listFormat,
    );
  }
}

class RetryOptions {
  const RetryOptions({
    this.retries = 3,
    this._retryEvaluator,
    this.retryInterval = const Duration(seconds: 1),
  });

  factory RetryOptions.noRetry() => const RetryOptions(retries: 0);

  factory RetryOptions.fromExtra(
    RequestOptions request,
    RetryOptions defaultOptions,
  ) => (request.extra[extraKey] as RetryOptions?) ?? defaultOptions;

  static const extraKey = 'cache_retry_request';

  final int retries;
  final Duration retryInterval;
  final RetryEvaluator? _retryEvaluator;

  RetryEvaluator get retryEvaluator => _retryEvaluator ?? defaultRetryEvaluator;

  // Retry transport errors and 401/403 (so a refreshed token can be used).
  static FutureOr<bool> defaultRetryEvaluator(DioException error) {
    final code = error.response?.statusCode;
    if (code == 401 || code == 403) return true;
    return error.type != DioExceptionType.cancel &&
        error.type != DioExceptionType.badResponse;
  }

  RetryOptions copyWith({int? retries, Duration? retryInterval}) =>
      RetryOptions(
        retries: retries ?? this.retries,
        retryInterval: retryInterval ?? this.retryInterval,
      );

  Map<String, dynamic> toExtra() => {extraKey: this};
}
