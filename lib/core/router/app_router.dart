import 'package:flutter/material.dart';
import 'package:flutter_starter/common/widgets/widgets.dart';
import 'package:flutter_starter/core/errors/errors.dart';
import 'package:flutter_starter/core/router/router.dart';
import 'package:flutter_starter/core/services/services.dart';
import 'package:flutter_starter/core/utils/utils.dart';
import 'package:flutter_starter/modules/about/about.dart';
import 'package:flutter_starter/modules/auth/auth.dart';
import 'package:flutter_starter/modules/dashboard/dashboard.dart';
import 'package:flutter_starter/modules/onboarding/onboarding.dart';
import 'package:flutter_starter/modules/settings/settings.dart';
import 'package:flutter_starter/modules/website_view/website_view.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final _log = CustomLogger(title: 'Router');

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.splash.path,
  // With Firebase on, the analytics observer logs each screen view by its
  // route name.
  observers: [AppNavigatorObserver(), ?FirebaseService.analyticsObserver],
  routes: [
    // Optional. Remove with lib/modules/onboarding/ (splash too), and set
    // initialLocation to your first screen.
    GoRoute(
      name: Routes.splash.name,
      path: Routes.splash.path,
      builder: (context, state) => const SplashScreen(),
    ),
    // Optional. Remove with lib/modules/onboarding/.
    GoRoute(
      name: Routes.onboarding.name,
      path: Routes.onboarding.path,
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Optional. Remove with lib/modules/auth/.
    GoRoute(
      name: Routes.login.name,
      path: Routes.login.path,
      builder: (context, state) => const LoginScreen(),
    ),
    // Optional. Remove with lib/modules/dashboard/; the children move to
    // the top level, with a leading `/` in their paths.
    GoRoute(
      name: Routes.dashboard.name,
      path: Routes.dashboard.path,
      builder: (context, state) => const DashboardScreen(),
      routes: [
        // Optional. Remove with lib/modules/settings/ (the playground too).
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
        // Optional. Remove with lib/modules/about/.
        GoRoute(
          name: Routes.about.name,
          path: Routes.about.path,
          builder: (context, state) => const AboutScreen(),
        ),
        // Optional. Remove with lib/modules/website_view/.
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
  // An unknown location. go_router's error text is for the log, not users.
  errorBuilder: (context, state) {
    _log.e('No route for ${state.uri}: ${state.error}');
    return const ErrorScreen(message: AppErrorStrings.pageNotFound);
  },
);
