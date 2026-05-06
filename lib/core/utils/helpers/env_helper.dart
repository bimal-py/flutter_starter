import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Thin wrapper over `flutter_dotenv`. Call [EnvHelper.init] once at startup
/// (in `main()`), then read values via [EnvHelper.get].
class EnvHelper {
  EnvHelper._();

  static Future<void> init() => dotenv.load(fileName: '.env');

  static String get(String name) => dotenv.env[name] ?? '';

  static bool getBool(String name, {bool defaultValue = false}) {
    final raw = dotenv.env[name]?.toLowerCase();
    if (raw == null) return defaultValue;
    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}
