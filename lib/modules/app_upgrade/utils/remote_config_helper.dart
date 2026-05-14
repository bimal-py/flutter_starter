import 'dart:math' as math;

import 'package:flutter_starter/core/utils/constants/app_constants.dart';
import 'package:flutter_starter/modules/app_upgrade/constants/app_upgrade_constants.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Version math + Hive-backed "ignored version" persistence. Lives outside
/// the cubit so it stays unit-testable.
class RemoteConfigHelper {
  Future<String> currentAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    // Drop "+build" suffix so semver comparison stays clean.
    return info.version.split('+').first;
  }

  /// Strict dotted-int compare. Malformed input → false ("not lower") so a
  /// bad Remote Config value can't force-trigger the popup.
  bool isVersionLower(String current, String target) {
    try {
      final c = current.split('.').map(int.parse).toList();
      final t = target.split('.').map(int.parse).toList();
      final length = math.max(c.length, t.length);
      for (var i = 0; i < length; i++) {
        final cv = i < c.length ? c[i] : 0;
        final tv = i < t.length ? t[i] : 0;
        if (cv < tv) return true;
        if (cv > tv) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  String? readIgnoredVersion() {
    try {
      final raw = Hive.box<dynamic>(AppConstants.appBoxName)
          .get(AppUpgradeConstants.ignoredAppVersionKey);
      return raw is String ? raw : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> markVersionIgnored(String version) async {
    try {
      await Hive.box<dynamic>(AppConstants.appBoxName)
          .put(AppUpgradeConstants.ignoredAppVersionKey, version);
    } catch (_) {}
  }
}
