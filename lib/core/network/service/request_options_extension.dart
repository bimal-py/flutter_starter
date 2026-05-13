import 'dart:io';

import 'package:dio/dio.dart';

/// Accessors for the multipart-retry metadata stashed in `RequestOptions.extra`
/// when [RemoteServiceImpl] uploads files. The retry interceptor reads these
/// to rebuild a fresh FormData after token refresh.
extension RequestOptionsX on RequestOptions {
  bool get hasFiles => extra['hasFiles'] == true;
  Map<String, dynamic>? get originalBody =>
      extra['originalBody'] as Map<String, dynamic>?;
  Map<String, File>? get files => extra['files'] as Map<String, File>?;
}
