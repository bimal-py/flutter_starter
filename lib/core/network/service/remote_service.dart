import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Abstract HTTP gateway. Every method returns the decoded JSON body and
/// throws [ServerException] (message from [ApiErrorStrings] or the server) on
/// any non-2xx, so a returned value already means success. Dio types stay
/// behind this boundary except for upload progress / cancellation.
abstract class RemoteService {
  Future<dynamic> getResponse({
    String? baseUrl,
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
  });

  Future<dynamic> deleteResponse({
    String? baseUrl,
    required String endPoint,
    // Optional request body for DELETE endpoints that expect one (e.g. a
    // bulk-delete that takes a raw array of ids). `Object?` (not Map) so a raw
    // JSON array can be passed through. Stays null for ordinary deletes.
    Object? payloadObj,
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
  });

  /// [contentType] overrides the request's `Content-Type`. Leave it null for the
  /// default — `multipart/form-data` when [files] are present, else
  /// `application/json` — and only set it for the rare endpoint that wants
  /// something else (e.g. `application/x-www-form-urlencoded`, `text/xml`).
  ///
  /// [onSendProgress] reports upload bytes (sent / total) for a multipart body.
  /// [cancelToken] cancels just this request; when null it falls back to the
  /// shared global token, so existing callers are unaffected.
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
  });

  /// POST a JSON-array body (e.g. `bulk_create` endpoints that take a list).
  Future<dynamic> postListResponse({
    String? baseUrl,
    required String endPoint,
    required List<dynamic> payloadList,
    Map<String, dynamic>? queryParameters,
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
    String? contentType,
  });

  Future<dynamic> putResponse({
    String? baseUrl,
    required String endPoint,
    Map<String, dynamic>? payloadObj,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
    String? contentType,
  });

  Future<dynamic> patchResponse({
    String? baseUrl,
    required String endPoint,
    Map<String, dynamic>? payloadObj,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool isTokenRequired = false,
    AsyncValueGetter<String?>? accessToken,
    String? contentType,
  });
}
