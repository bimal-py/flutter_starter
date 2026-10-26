import 'package:flutter_starter/core/utils/utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class DioConfig {
  /// `API_BASE_URL` without a trailing slash: requests are built as
  /// `'\$baseUrl/\$endPoint'`, and Django won't match a `//` path.
  String get baseUrl {
    final url = EnvConfig.apiBaseUrl.trim();
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Duration get connectionTimeout => const Duration(seconds: 30);
  Duration get receiveTimeout => const Duration(seconds: 30);
  Duration get sendTimeout => const Duration(seconds: 30);
}
