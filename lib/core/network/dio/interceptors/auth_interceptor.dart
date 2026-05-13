import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Injects `Authorization: Bearer <token>` on requests that opt in via
/// [authRequired]. Token is read lazily via [accessToken] so the storage
/// lookup happens per-request and the caller controls the source.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.authRequired, this.accessToken});

  final bool authRequired;
  final AsyncValueGetter<String?>? accessToken;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (authRequired) {
      final token = await accessToken?.call();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }
}
