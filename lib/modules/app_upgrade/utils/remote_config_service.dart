import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_starter/modules/app_upgrade/constants/app_upgrade_constants.dart';

/// `FirebaseRemoteConfig` singleton, Firebase-gated. When Firebase hasn't been
/// initialised (`FIREBASE_ENABLED=false`), `init()` returns silently and every
/// getter falls back to a safe default — the rest of the module no-ops.
class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    if (Firebase.apps.isEmpty) return;

    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setDefaults(<String, dynamic>{
        AppUpgradeConstants.latestVersionRcKey: '0.0.0',
        AppUpgradeConstants.updateMessageRcKey:
            AppUpgradeConstants.defaultUpdateMessage,
        AppUpgradeConstants.enabledOnIosRcKey: true,
        AppUpgradeConstants.enabledOnAndroidRcKey: true,
        AppUpgradeConstants.forceUpdateRcKey: false,
      });
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: AppUpgradeConstants.fetchTimeout,
          minimumFetchInterval: AppUpgradeConstants.minFetchInterval,
        ),
      );
      await rc.fetchAndActivate();
      _remoteConfig = rc;
      _initialized = true;
    } catch (_) {
      // Offline / fetch failure — leave _initialized=false so the next call
      // retries. The SDK still serves defaults via its in-memory instance.
    }
  }

  String get latestReleasedVersion =>
      _remoteConfig?.getString(AppUpgradeConstants.latestVersionRcKey) ??
      '0.0.0';

  String get updateMessage {
    final v = _remoteConfig?.getString(AppUpgradeConstants.updateMessageRcKey);
    if (v == null || v.isEmpty) return AppUpgradeConstants.defaultUpdateMessage;
    return v;
  }

  bool get enabledOnIos =>
      _remoteConfig?.getBool(AppUpgradeConstants.enabledOnIosRcKey) ?? false;

  bool get enabledOnAndroid =>
      _remoteConfig?.getBool(AppUpgradeConstants.enabledOnAndroidRcKey) ??
      false;

  bool get forceUpdate =>
      _remoteConfig?.getBool(AppUpgradeConstants.forceUpdateRcKey) ?? false;
}
