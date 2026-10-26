import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/di/di.dart';
import 'package:flutter_starter/core/errors/errors.dart';
import 'package:flutter_starter/core/network/dio/dio.dart';
import 'package:flutter_starter/core/network/service/service.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: RemoteService)
class RemoteServiceImpl extends RemoteService {
  RemoteServiceImpl(this._client, this._config);

  final DioClient _client;
  final DioConfig _config;

  FormData _buildFormData({
    required Map<String, dynamic> body,
    required Map<String, File> files,
  }) {
    final entries = <String, dynamic>{}
      ..addAll(body)
      ..addAll(
        files.map(
          (k, f) => MapEntry(
            k,
            MultipartFile.fromFileSync(
              f.path,
              filename: buildUploadFilename(f.path, body['name']),
            ),
          ),
        ),
      );
    return FormData.fromMap(entries);
  }

  Iterable<Interceptor> _interceptors({
    required bool isTokenRequired,
    AsyncValueGetter<String?>? accessToken,
  }) {
    // Registered by the auth module; null once it is deleted, and then authed
    // requests go out unsigned and a 401 is just an error.
    final tokens = getIt.maybeGet<AuthTokenHandler>();
    return [
      RetryInterceptor(
        dio: _client.dio,
        refreshTokenCallback: tokens?.refreshAccessToken,
        // Triggered only after the retry counter exhausts on a 401/403.
        onAuthFailureExhausted: tokens?.onSessionExpired,
      ),
      AuthInterceptor(
        isTokenRequired: isTokenRequired,
        accessToken: accessToken ?? tokens?.accessToken,
      ),
    ];
  }

  @override
  Future<dynamic> getResponse({
    String? baseUrl,
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
  }) async {
    try {
      final response = await _client
          .addInterceptors(
            _interceptors(
              isTokenRequired: isTokenRequired,
              accessToken: accessToken,
            ),
          )
          .get(
            '${baseUrl ?? _config.baseUrl}/$endPoint',
            queryParameters: queryParameters,
            cancelToken: GlobalCancelTokenManager.token,
            options: Options(extra: {'isTokenRequired': isTokenRequired}),
          );
      return response.data;
    } on DioException catch (err) {
      throw ServerException(
        message: DioExceptionUtil.handleError(err),
        statusCode: err.response?.statusCode,
      );
    }
  }

  @override
  Future<dynamic> deleteResponse({
    String? baseUrl,
    required String endPoint,
    Object? payloadObj,
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
  }) async {
    try {
      final response = await _client
          .addInterceptors(
            _interceptors(
              isTokenRequired: isTokenRequired,
              accessToken: accessToken,
            ),
          )
          .delete(
            '${baseUrl ?? _config.baseUrl}/$endPoint',
            data: payloadObj,
            cancelToken: GlobalCancelTokenManager.token,
            options: Options(extra: {'isTokenRequired': isTokenRequired}),
          );
      return response.statusCode == 204 ? null : response.data;
    } on DioException catch (err) {
      throw ServerException(
        message: DioExceptionUtil.handleError(err),
        statusCode: err.response?.statusCode,
      );
    }
  }

  @override
  Future<dynamic> postResponse({
    String? baseUrl,
    required String endPoint,
    Map<String, dynamic>? payloadObj,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
    String? contentType,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) => _sendWithBody(
    method: 'POST',
    baseUrl: baseUrl,
    endPoint: endPoint,
    payloadObj: payloadObj,
    queryParameters: queryParameters,
    files: files,
    isTokenRequired: isTokenRequired,
    accessToken: accessToken,
    contentType: contentType,
    onSendProgress: onSendProgress,
    cancelToken: cancelToken,
  );

  @override
  Future<dynamic> postListResponse({
    String? baseUrl,
    required String endPoint,
    required List<dynamic> payloadList,
    Map<String, dynamic>? queryParameters,
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
    String? contentType,
  }) async {
    try {
      final dio = _client.addInterceptors(
        _interceptors(
          isTokenRequired: isTokenRequired,
          accessToken: accessToken,
        ),
      );
      final response = await dio.request(
        '${baseUrl ?? _config.baseUrl}/$endPoint',
        queryParameters: queryParameters,
        data: payloadList,
        // No files; the retry interceptor re-sends requestOptions.data as-is.
        options: Options(
          method: 'POST',
          contentType: contentType ?? Headers.jsonContentType,
          extra: {'hasFiles': false, 'isTokenRequired': isTokenRequired},
        ),
        cancelToken: GlobalCancelTokenManager.token,
      );
      return response.data;
    } on DioException catch (err) {
      throw ServerException(
        message: DioExceptionUtil.handleError(err),
        statusCode: err.response?.statusCode,
      );
    }
  }

  @override
  Future<dynamic> putResponse({
    String? baseUrl,
    required String endPoint,
    Map<String, dynamic>? payloadObj,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
    String? contentType,
  }) => _sendWithBody(
    method: 'PUT',
    baseUrl: baseUrl,
    endPoint: endPoint,
    payloadObj: payloadObj,
    queryParameters: queryParameters,
    files: files,
    isTokenRequired: isTokenRequired,
    accessToken: accessToken,
    contentType: contentType,
  );

  @override
  Future<dynamic> patchResponse({
    String? baseUrl,
    required String endPoint,
    Map<String, dynamic>? payloadObj,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
    String? contentType,
  }) => _sendWithBody(
    method: 'PATCH',
    baseUrl: baseUrl,
    endPoint: endPoint,
    payloadObj: payloadObj,
    queryParameters: queryParameters,
    files: files,
    isTokenRequired: isTokenRequired,
    accessToken: accessToken,
    contentType: contentType,
  );

  Future<dynamic> _sendWithBody({
    required String method,
    String? baseUrl,
    required String endPoint,
    Map<String, dynamic>? payloadObj,
    Map<String, dynamic>? queryParameters,
    required Map<String, File> files,
    required bool isTokenRequired,
    AsyncValueGetter<String?>? accessToken,
    String? contentType,
    // Only the multipart upload path passes these; null keeps the prior behaviour
    // (no progress, shared global cancel token) for every other caller.
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final hasFiles = files.isNotEmpty;
      // Build a multipart body when there are files OR the caller explicitly
      // asked for multipart/form-data — lets a fields-only endpoint (no upload)
      // send its fields as form-data instead of JSON.
      final wantsMultipart =
          hasFiles ||
          (contentType?.startsWith(Headers.multipartFormDataContentType) ??
              false);
      final data = wantsMultipart
          ? _buildFormData(body: payloadObj ?? {}, files: files)
          : payloadObj;

      final dio = _client.addInterceptors(
        _interceptors(
          isTokenRequired: isTokenRequired,
          accessToken: accessToken,
        ),
      );
      final options = Options(
        method: method,
        // Caller override wins; otherwise default by body type — multipart for
        // a FormData upload (Dio appends the boundary), JSON for everything
        // else. Never inherit the global JSON default for a multipart body.
        contentType:
            contentType ??
            (hasFiles
                ? Headers.multipartFormDataContentType
                : Headers.jsonContentType),
        extra: {
          'originalBody': payloadObj,
          'hasFiles': hasFiles,
          'files': files,
          'isTokenRequired': isTokenRequired,
        },
      );

      final response = await dio.request(
        '${baseUrl ?? _config.baseUrl}/$endPoint',
        queryParameters: queryParameters,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken ?? GlobalCancelTokenManager.token,
      );
      return response.data;
    } on DioException catch (err) {
      throw ServerException(
        message: DioExceptionUtil.handleError(err),
        statusCode: err.response?.statusCode,
      );
    }
  }
}
