import 'package:flutter/material.dart';
import 'package:flutter_starter/common/widgets/widgets.dart';
import 'package:flutter_starter/core/router/observers/app_navigator_observer.dart';
import 'package:flutter_starter/core/router/routes.dart';
import 'package:flutter_starter/modules/auth/auth.dart';
import 'package:flutter_starter/modules/dashboard/dashboard.dart';
import 'package:flutter_starter/modules/device_info/device_info.dart';
import 'package:flutter_starter/modules/onboarding/onboarding.dart';
import 'package:flutter_starter/modules/package_info/package_info.dart';
import 'package:flutter_starter/modules/settings/settings.dart';
import 'package:flutter_starter/modules/website_view/website_view.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.splash.path,
  observers: [AppNavigatorObserver()],
  routes: [
    GoRoute(
      name: Routes.splash.name,
      path: Routes.splash.path,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: Routes.onboarding.name,
      path: Routes.onboarding.path,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      name: Routes.login.name,
      path: Routes.login.path,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: Routes.dashboard.name,
      path: Routes.dashboard.path,
      builder: (context, state) => const DashboardScreen(),
      routes: [
        GoRoute(
          name: Routes.settings.name,
          path: Routes.settings.path,
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              name: Routes.themePlayground.name,
              path: Routes.themePlayground.path,
              builder: (context, state) => const ThemePlaygroundScreen(),
            ),
          ],
        ),
        GoRoute(
          name: Routes.deviceInfo.name,
          path: Routes.deviceInfo.path,
          builder: (context, state) => const DeviceInfoScreen(),
        ),
        GoRoute(
          name: Routes.packageInfo.name,
          path: Routes.packageInfo.path,
          builder: (context, state) => const PackageInfoScreen(),
        ),
        GoRoute(
          name: Routes.websiteView.name,
          path: Routes.websiteView.path,
          builder: (context, state) {
            final url = state.extra is String ? state.extra as String : '';
            return WebsiteViewScreen(url: url);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(message: state.error?.toString()),
);
