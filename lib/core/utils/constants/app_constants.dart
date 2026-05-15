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

  // About screen — replace with your own copy before shipping.
  static const String aboutAppText =
      'Flutter Starter is an opinionated template that bundles the parts of '
      'every production Flutter app you keep rebuilding — theming, routing, '
      'BLoC + Hydrated persistence, DI, networking, auth, notifications, '
      'and more.\n\n'
      'Use it as a launchpad: keep what fits, delete what doesn\'t.';

  static const String developerName = 'Bimal Khatri';
  static const String developerRole = 'Software Developer';
}
