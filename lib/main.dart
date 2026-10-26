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
  // Optional. Remove with lib/modules/fcm/.
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  await initializeEnvHelper();
  await _setupHydratedStorage();
  await _initializeHive();

  Bloc.observer = AppBlocObserver();
  await _setDeviceOrientationToPortrait();
  await configureDependencyInjection();

  // Optional. Remove with lib/modules/notifications/.
  await NotificationService.instance.initialize();

  // Core. A no-op unless FIREBASE_ENABLED=true in .env and
  // firebase_options.dart exists (see firebase_service.dart).
  await FirebaseService.init();

  // Optional. Remove with lib/modules/fcm/. A no-op until Firebase starts.
  // The bridge shows foreground pushes through lib/modules/notifications/.
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

  // Optional. Remove with lib/modules/mobile_ads/.
  // After the first frame, so the app is in front when the initializer
  // gathers UMP consent and shows the iOS ATT prompt (both are dropped if
  // requested earlier). Non-blocking: the app works without ads.
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
