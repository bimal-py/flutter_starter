import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/errors/exceptions.dart';
import 'package:flutter_starter/core/network/dio/config/dio_config.dart';
import 'package:flutter_starter/core/network/dio/dio_client.dart';
import 'package:flutter_starter/core/network/dio/error_handler/dio_exception_util.dart';
import 'package:flutter_starter/core/network/dio/interceptors/auth_interceptor.dart';
import 'package:flutter_starter/core/network/dio/interceptors/retry_interceptor.dart';
import 'package:flutter_starter/core/network/service/cancel_token_manager.dart';
import 'package:flutter_starter/core/network/service/remote_service.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: RemoteService)
class RemoteServiceImpl extends RemoteService {
  RemoteServiceImpl(this._client, this._config);

  final DioClient _client;
  final DioConfig _config;

  /// Hook for an auth module (when added) to refresh the access token. Until
  /// then, 401s short-circuit through [LogoutInterceptor]'s `markAsLoggedOut`.
  Future<String?> Function()? refreshTokenCallback;

  FormData _buildFormData({
    required Map<String, dynamic> body,
    required Map<String, File> files,
  }) {
    final entries = <String, dynamic>{}
      ..addAll(body)
      ..addAll(
        files.map((k, f) => MapEntry(k, MultipartFile.fromFileSync(f.path))),
      );
    return FormData.fromMap(entries);
  }

  Iterable<Interceptor> _interceptors({
    required bool authRequired,
    AsyncValueGetter<String?>? accessToken,
  }) =>
      [
        RetryInterceptor(
          dio: _client.dio,
          refreshTokenCallback: refreshTokenCallback,
        ),
        AuthInterceptor(
          authRequired: authRequired,
          accessToken: accessToken,
        ),
      ];

  @override
  Future<dynamic> get({
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  }) async {
    try {
      final response = await _client
          .addInterceptors(_interceptors(
            authRequired: authRequired,
            accessToken: accessToken,
          ))
          .get(
            '${baseUrl ?? _config.baseUrl}/$endpoint',
            queryParameters: queryParameters,
            cancelToken: GlobalCancelTokenManager.token,
          );
      return response.data;
    } on DioException catch (err) {
      throw ServerException(message: DioExceptionUtil.handleError(err));
    }
  }

  @override
  Future<dynamic> delete({
    String? baseUrl,
    required String endpoint,
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  }) async {
    try {
      final response = await _client
          .addInterceptors(_interceptors(
            authRequired: authRequired,
            accessToken: accessToken,
          ))
          .delete(
            '${baseUrl ?? _config.baseUrl}/$endpoint',
            cancelToken: GlobalCancelTokenManager.token,
          );
      return response.statusCode == 204 ? null : response.data;
    } on DioException catch (err) {
      throw ServerException(message: DioExceptionUtil.handleError(err));
    }
  }

  @override
  Future<dynamic> post({
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  }) =>
      _sendWithBody(
        method: 'POST',
        baseUrl: baseUrl,
        endpoint: endpoint,
        body: body,
        queryParameters: queryParameters,
        files: files,
        authRequired: authRequired,
        accessToken: accessToken,
      );

  @override
  Future<dynamic> put({
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  }) =>
      _sendWithBody(
        method: 'PUT',
        baseUrl: baseUrl,
        endpoint: endpoint,
        body: body,
        queryParameters: queryParameters,
        files: files,
        authRequired: authRequired,
        accessToken: accessToken,
      );

  @override
  Future<dynamic> patch({
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  }) =>
      _sendWithBody(
        method: 'PATCH',
        baseUrl: baseUrl,
        endpoint: endpoint,
        body: body,
        queryParameters: queryParameters,
        files: files,
        authRequired: authRequired,
        accessToken: accessToken,
      );

  Future<dynamic> _sendWithBody({
    required String method,
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    required Map<String, File> files,
    required bool authRequired,
    AsyncValueGetter<String?>? accessToken,
  }) async {
    try {
      final hasFiles = files.isNotEmpty;
      final data = hasFiles
          ? _buildFormData(body: body ?? {}, files: files)
          : body;

      final dio = _client.addInterceptors(_interceptors(
        authRequired: authRequired,
        accessToken: accessToken,
      ));
      final options = Options(
        method: method,
        extra: {
          'originalBody': body,
          'hasFiles': hasFiles,
          'files': files,
        },
      );

      final response = await dio.request(
        '${baseUrl ?? _config.baseUrl}/$endpoint',
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: GlobalCancelTokenManager.token,
      );
      return response.data;
    } on DioException catch (err) {
      throw ServerException(message: DioExceptionUtil.handleError(err));
    }
  }
}
