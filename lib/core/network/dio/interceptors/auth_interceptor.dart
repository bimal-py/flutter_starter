import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Injects `Authorization: Bearer <token>` on requests that opt in via
/// [isTokenRequired]. Token is read lazily via [accessToken] so the storage
/// lookup happens per-request and a refreshed token is picked up at once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.isTokenRequired, this.accessToken});

  final bool isTokenRequired;
  final AsyncValueGetter<String?>? accessToken;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!isTokenRequired) return super.onRequest(options, handler);

    final token = await accessToken?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
