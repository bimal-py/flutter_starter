import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/network/dio/interceptors/token_refresh_synchronizer.dart';
import 'package:flutter_starter/core/network/service/request_options_extension.dart';

typedef RetryEvaluator = FutureOr<bool> Function(DioException error);

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    RetryOptions? options,
    this.shouldLog = true,
    this.refreshTokenCallback,
  }) : options = options ?? const RetryOptions();

  final Dio dio;
  final RetryOptions options;
  final bool shouldLog;
  final Future<String?> Function()? refreshTokenCallback;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    var extra = RetryOptions.fromExtra(err.requestOptions, options);

    if (err.response?.statusCode == 401 && refreshTokenCallback != null) {
      final newToken =
          await TokenRefreshSynchronizer.refreshToken(refreshTokenCallback!);
      if (newToken != null && newToken.isNotEmpty) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      } else {
        return super.onError(err, handler);
      }
    }

    final shouldRetry = extra.retries > 0 && await options.retryEvaluator(err);
    if (!shouldRetry) return super.onError(err, handler);

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
              await MultipartFile.fromFile(entry.value.path),
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
        options: _toOptions(err.requestOptions),
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

  Options _toOptions(RequestOptions r) => Options(
        method: r.method,
        sendTimeout: r.sendTimeout,
        receiveTimeout: r.receiveTimeout,
        extra: r.extra,
        headers: r.headers,
        responseType: r.responseType,
        contentType: r.contentType,
        validateStatus: r.validateStatus,
        receiveDataWhenStatusError: r.receiveDataWhenStatusError,
        followRedirects: r.followRedirects,
        maxRedirects: r.maxRedirects,
        requestEncoder: r.requestEncoder,
        responseDecoder: r.responseDecoder,
        listFormat: r.listFormat,
      );
}

class RetryOptions {
  const RetryOptions({
    this.retries = 3,
    RetryEvaluator? retryEvaluator,
    this.retryInterval = const Duration(seconds: 1),
  }) : _retryEvaluator = retryEvaluator;

  factory RetryOptions.noRetry() => const RetryOptions(retries: 0);

  factory RetryOptions.fromExtra(
    RequestOptions request,
    RetryOptions defaultOptions,
  ) =>
      (request.extra[extraKey] as RetryOptions?) ?? defaultOptions;

  static const extraKey = 'cache_retry_request';

  final int retries;
  final Duration retryInterval;
  final RetryEvaluator? _retryEvaluator;

  RetryEvaluator get retryEvaluator => _retryEvaluator ?? defaultRetryEvaluator;

  /// Retry on cancel-/badResponse-free errors AND on 401/403 (so the next
  /// retry can pick up a refreshed token).
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
