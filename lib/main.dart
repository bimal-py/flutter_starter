import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/fcm/fcm.dart';
import 'package:flutter_starter/modules/mobile_ads/mobile_ads.dart';
import 'package:flutter_starter/modules/notifications/notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Optional. Delete lib/modules/fcm/ + this line to remove push notifications.
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  await initializeEnvHelper();
  await _setupHydratedStorage();
  await _initializeHive();

  Bloc.observer = AppBlocObserver();
  await _setDeviceOrientationToPortrait();
  await configureDependencyInjection();

  // Optional. Delete lib/modules/notifications/ + this line to remove.
  await NotificationService.instance.initialize();

  // Optional. No-op unless FIREBASE_ENABLED=true in .env AND firebase_options.dart has been generated. See firebase_service.dart.
  await FirebaseService.init();

  // Optional. No-op when FIREBASE_ENABLED=false. Bridge requires Notifications.
  await FcmService.instance.initialize(
    onForegroundMessage: buildNotificationBridge(),
  );

  runApp(
    const ScaleKitBuilder(
      designWidth: 425,
      designHeight: 691,
      child: StarterApp(),
    ),
  );

  // Mobile Ads SDK — deferred to after the first frame so the app is
  // foregrounded/active when the initializer gathers UMP consent and shows the
  // iOS ATT prompt (both are silently dropped if requested before that).
  // Non-blocking — the app works without ads and init failures are swallowed.
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(MobileAdsInitializer.instance.init()),
  );

  await FirebaseService.setupCrashlyticsAndAnalytics();
}

Future<void> initializeEnvHelper() => EnvHelper.init();

Future<void> _setupHydratedStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();
  await Hive.openAllBoxes();
}

Future<void> _setDeviceOrientationToPortrait() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
