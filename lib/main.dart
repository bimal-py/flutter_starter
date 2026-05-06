import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/app/hive_bootstrap.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Order matters: env must be loaded before anything that reads env flags.
  await EnvHelper.init();

  await _setupHydratedStorage();
  await _initializeHive();

  Bloc.observer = AppBlocObserver();

  await _setDeviceOrientationToPortrait();
  await configureDependencyInjection();

  // Optional. No-op unless FIREBASE_ENABLED=true in .env AND
  // firebase_options.dart has been generated. See firebase_service.dart.
  await FirebaseService.init();

  runApp(
    const ScaleKitBuilder(
      designWidth: 425,
      designHeight: 691,
      child: StarterApp(),
    ),
  );

  // Crashlytics / Analytics init runs after runApp so it doesn't block
  // first-frame paint. Safe to call: it's a no-op if Firebase isn't up.
  await FirebaseService.setupCrashlyticsAndAnalytics();
}

Future<void> _setupHydratedStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
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
