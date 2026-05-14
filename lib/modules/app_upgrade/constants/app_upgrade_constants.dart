import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/utils/constants/app_constants.dart';

class AppUpgradeConstants {
  AppUpgradeConstants._();

  // Remote Config parameter keys — must match the Firebase Console exactly.
  static const String latestVersionRcKey = 'latest_released_app_version';
  static const String updateMessageRcKey = 'update_message';
  static const String enabledOnIosRcKey = 'enabled_on_ios';
  static const String enabledOnAndroidRcKey = 'enabled_on_android';
  static const String forceUpdateRcKey = 'force_update';

  /// Key inside the shared `app_box` where the last-ignored version is stored.
  static const String ignoredAppVersionKey = 'ignored_app_version';

  static String get appStoreUrl =>
      'https://apps.apple.com/app/id${AppConstants.appIosAppId}';
  static String get googlePlayUrl =>
      'https://play.google.com/store/apps/details?id=${AppConstants.appAndroidPackageId}';
  static String get storeUrl => Platform.isIOS ? appStoreUrl : googlePlayUrl;

  /// Fallback HTML if Remote Config is unreachable on first launch.
  static const String defaultUpdateMessage =
      '<p>A new version is available with improvements and bug fixes.</p>';

  /// Refresh window. Debug builds skip the cache so console changes show up
  /// instantly while you iterate; release builds throttle to 1 hour.
  static const Duration minFetchInterval = kDebugMode
      ? Duration.zero
      : Duration(hours: 1);
  static const Duration fetchTimeout = Duration(minutes: 1);
}
