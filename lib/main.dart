import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/app/hive_bootstrap.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/notifications/notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(
    const ScaleKitBuilder(
      designWidth: 425,
      designHeight: 691,
      child: StarterApp(),
    ),
  );

  await FirebaseService.setupCrashlyticsAndAnalytics();
}

Future<void> initializeEnvHelper() async {
  // loading env file
  await EnvHelper.init();
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
