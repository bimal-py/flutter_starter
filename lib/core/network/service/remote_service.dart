import 'dart:io';

import 'package:flutter/foundation.dart';

/// Abstract HTTP gateway. Implementations should throw [ServerException]
/// (with messages from [ApiErrorStrings]) on wire failures, and not leak
/// Dio types past this boundary.
abstract class RemoteService {
  Future<dynamic> get({
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  });

  Future<dynamic> delete({
    String? baseUrl,
    required String endpoint,
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  });

  Future<dynamic> post({
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  });

  Future<dynamic> put({
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  });

  Future<dynamic> patch({
    String? baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, File> files = const {},
    bool authRequired = false,
    AsyncValueGetter<String?>? accessToken,
  });
}
