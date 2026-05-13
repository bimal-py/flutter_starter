import 'package:flutter_starter/core/utils/utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class DioConfig {
  String get baseUrl => EnvConfig.apiBaseUrl;
  Duration get connectionTimeout => const Duration(seconds: 30);
  Duration get receiveTimeout => const Duration(seconds: 30);
  Duration get sendTimeout => const Duration(seconds: 30);
}
