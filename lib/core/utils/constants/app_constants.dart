/// App identity values — name, store identifiers, Hive box names.
///
/// URLs live in [AppUrls] (static) or [ApiEndpoints] (env-driven).
class AppConstants {
  AppConstants._();

  static const String appName = 'Flutter Starter';
  static const String defaultNullValue = '-';
  static const Duration splashDuration = Duration(seconds: 2);

  // Hive
  static const String appBoxName = 'app_box';

  // Store identifiers — replace with your own before shipping.
  static const String appIosAppId = '0000000000';
  static const String appAndroidPackageId = 'com.example.flutter_starter';
}
