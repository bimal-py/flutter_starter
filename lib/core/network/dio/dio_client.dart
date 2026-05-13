import 'package:dio/dio.dart';
import 'package:flutter_starter/core/di/injection.dart';
import 'package:flutter_starter/core/network/dio/config/dio_config.dart';
import 'package:flutter_starter/core/network/dio/interceptors/logging_interceptor.dart';
import 'package:flutter_starter/core/network/dio/interceptors/logout_interceptor.dart';
import 'package:injectable/injectable.dart';

/// Thin Dio wrapper that pre-installs logging + logout interceptors. Use
/// [addInterceptors] from [RemoteServiceImpl] to layer auth/retry on top
/// per-request without rebuilding Dio.
@injectable
class DioClient {
  DioClient(DioConfig config)
      : _dio = Dio()
          ..options.baseUrl = config.baseUrl
          ..options.connectTimeout = config.connectionTimeout
          ..options.receiveTimeout = config.receiveTimeout
          ..options.sendTimeout = config.sendTimeout
          ..interceptors.add(LoggingInterceptor());

  final Dio _dio;

  Dio get dio => _dio;

  Dio addInterceptors(Iterable<Interceptor> interceptors) {
    _dio.interceptors.add(getIt<LogoutInterceptor>());
    _dio.interceptors.addAll(interceptors);
    return _dio;
  }
}
