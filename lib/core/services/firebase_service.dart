import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_starter/core/utils/constants/env_config.dart';
import 'package:flutter_starter/core/utils/helpers/helpers.dart';

// To enable Firebase:
//   1. Run `dart pub global activate flutterfire_cli` (one-time install).
//   2. From the project root, run `flutterfire configure` and follow the prompts.
//      That generates `lib/firebase_options.dart` (gitignored).
//   3. Set `FIREBASE_ENABLED=true` in `.env`.
//   4. Uncomment the import + `options:` line below.
//
// Until step 2 is done, this file compiles without `firebase_options.dart` so
// the starter is buildable out of the box.
//
// import 'package:flutter_starter/firebase_options.dart';

/// Initialises Firebase if `FIREBASE_ENABLED=true` in `.env` AND
/// `firebase_options.dart` is present. Returns `true` when Firebase came up
/// successfully so callers can decide whether to initialise Crashlytics /
/// Analytics afterwards.
class FirebaseService {
  FirebaseService._();

  static final CustomLogger _log = CustomLogger(title: 'Firebase');

  static bool _initialised = false;
  static bool get isInitialised => _initialised;

  static Future<bool> init() async {
    if (kIsWeb) return false;
    if (!EnvConfig.firebaseEnabled) return false;

    try {
      await Firebase.initializeApp(
        // options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialised = true;
      return true;
    } catch (e, st) {
      _log.e('init failed: $e\n$st');
      return false;
    }
  }

  /// Wires Crashlytics + an `app_open` analytics event. Call AFTER [init].
  /// Crashlytics collection is ON in release builds and OFF in debug.
  static Future<void> setupCrashlyticsAndAnalytics() async {
    if (!_initialised) return;

    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }

    await FirebaseAnalytics.instance.logAppOpen();
  }
}
