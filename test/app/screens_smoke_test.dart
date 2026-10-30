import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/about/about.dart';
import 'package:flutter_starter/modules/auth/auth.dart';
import 'package:flutter_starter/modules/dashboard/dashboard.dart';
import 'package:flutter_starter/modules/onboarding/onboarding.dart';
import 'package:flutter_starter/modules/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _MemoryStorage implements Storage {
  final _values = <String, dynamic>{};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}
}

/// Every main screen, built with the real theme and DI on a phone-sized
/// window: catches layout crashes (overflow, unbounded widths) and screens
/// that throw while building.
///
/// `CAPTURE_DIR=<folder> flutter test test/app/screens_smoke_test.dart`
/// also saves each screen as a PNG with the app's real fonts (the source of
/// the README's demo).
void main() {
  final captureDir = Platform.environment['CAPTURE_DIR'];
  late Directory hiveDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.loadFromString(envString: 'API_BASE_URL=https://api.example.com');
    FlutterSecureStorage.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Flutter Starter',
      packageName: 'com.example.flutter_starter',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    HydratedBloc.storage = _MemoryStorage();
    hiveDir = await Directory.systemTemp.createTemp('starter_hive');
    Hive.init(hiveDir.path);
    await Hive.openAllBoxes();
    await configureDependencyInjection();
    if (captureDir != null) await _loadRealFonts();
  });
  tearDownAll(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  final boundary = GlobalKey();

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    bool dark = false,
  }) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: ScaleKitBuilder(
          designWidth: 425,
          designHeight: 691,
          child: GlobalBlocConfig(
            child: Builder(
              builder: (context) {
                final themes = AppThemeBuilder.compose(
                  context: context,
                  source: const SeedOnlySource(
                    seed: AppColors.seed,
                    accent: AppColors.accent,
                  ),
                  fonts: LocalizedFonts.defaults(),
                );
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: themes.light,
                  darkTheme: themes.dark,
                  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
                  builder: (context, child) =>
                      LoadingOverlayWidget(child: child!),
                  home: screen,
                );
              },
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> capture(WidgetTester tester, String name) async {
    final dir = captureDir;
    if (dir == null) return;
    await tester.runAsync(() async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: 3);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$dir/$name.png').writeAsBytes(png!.buffer.asUint8List());
    });
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  }

  final screens = <String, (Widget Function(), bool)>{
    'onboarding': (() => const OnboardingScreen(), false),
    'login': (() => const LoginScreen(), false),
    'settings': (() => const SettingsScreen(), false),
    'theme_playground': (() => const ThemePlaygroundScreen(), false),
    'about': (() => const AboutScreen(), false),
    'dashboard': (() => const DashboardScreen(), false),
    'dashboard_dark': (() => const DashboardScreen(), true),
  };

  for (final MapEntry(key: name, value: (build, dark)) in screens.entries) {
    testWidgets('$name lays out without errors', (tester) async {
      await pumpScreen(tester, build(), dark: dark);
      expect(tester.takeException(), isNull);
      await capture(tester, name);
      await unmount(tester);
    });
  }

  testWidgets('signing in with an empty form says what is missing', (
    tester,
  ) async {
    await pumpScreen(tester, const LoginScreen());
    await tester.tap(find.text(AuthStrings.signIn));
    await tester.pump();
    expect(find.text(AuthError.emailInvalid), findsOneWidget);
    expect(find.text(AuthError.passwordRequired), findsOneWidget);
    await unmount(tester);
  });
}

/// Tests draw text with a box font; screenshots need the real ones.
Future<void> _loadRealFonts() async {
  Future<void> load(String family, List<String> assets) async {
    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }

  const weights = [
    'Thin',
    'ExtraLight',
    'Light',
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold',
    'Black',
  ];
  await load('Inter', [
    for (final weight in weights) 'assets/fonts/inter/Inter-$weight.ttf',
  ]);
  await load('packages/lucide_icons_flutter/Lucide', [
    'packages/lucide_icons_flutter/assets/lucide.ttf',
  ]);
  await load('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
}
