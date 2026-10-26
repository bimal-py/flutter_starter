import 'dart:io';

import 'package:dio/dio.dart';

/// Accessors for the metadata [RemoteServiceImpl] stashes in
/// `RequestOptions.extra`. The retry interceptor reads the multipart entries
/// to rebuild a fresh FormData after a token refresh.
extension RequestOptionsX on RequestOptions {
  bool get hasFiles => extra['hasFiles'] == true;
  Map<String, dynamic>? get originalBody =>
      extra['originalBody'] as Map<String, dynamic>?;
  Map<String, File>? get files => extra['files'] as Map<String, File>?;

  // Gates token-refresh on 401 — false for endpoints like login/register.
  bool get isTokenRequired => extra['isTokenRequired'] == true;
}
