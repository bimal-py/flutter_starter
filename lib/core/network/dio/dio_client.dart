import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/di/di.dart';
import 'package:flutter_starter/core/network/dio/config/config.dart';
import 'package:flutter_starter/core/network/dio/interceptors/interceptors.dart';
import 'package:injectable/injectable.dart';

@injectable
class DioClient {
  DioClient(DioConfig config)
    : _dio = Dio()
        ..options.baseUrl = config.baseUrl
        ..options.connectTimeout = config.connectionTimeout
        ..options.receiveTimeout = config.receiveTimeout
        ..options.sendTimeout = config.sendTimeout
        ..options.contentType = Headers.jsonContentType {
    // Request bodies carry passwords and tokens: never log them in release
    // (and keep `flutter test` output readable). `Platform` throws on web.
    if (kDebugMode &&
        (kIsWeb || !Platform.environment.containsKey('FLUTTER_TEST'))) {
      _dio.interceptors.add(
        LogInterceptor(request: true, responseBody: true, requestBody: true),
      );
    }
  }

  final Dio _dio;

  Dio get dio => _dio;

  Dio addInterceptors(Iterable<Interceptor> interceptors) {
    // Strip everything except LogInterceptor so successive calls don't stack
    // logout/retry/auth interceptors onto the same Dio instance.
    _dio.interceptors.removeWhere((i) => i is! LogInterceptor);
    _dio.interceptors.add(getIt<LogoutInterceptor>());
    _dio.interceptors.addAll(interceptors);
    return _dio;
  }
}
