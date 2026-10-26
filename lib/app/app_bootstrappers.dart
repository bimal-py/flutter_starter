import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/app_upgrade/app_upgrade.dart';
import 'package:flutter_starter/modules/auth/auth.dart';

/// App-wide listeners wrapped around every route. They sit above the
/// navigator: to show a dialog or a loader they use the router's navigator
/// (`router.routerDelegate.navigatorKey`). Each one is optional and goes
/// with its module.
class AppBootstrappers extends StatelessWidget {
  const AppBootstrappers({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Optional. Remove with lib/modules/app_upgrade/.
    return AppUpgradeBootstrapper(
      // Optional. Remove with lib/modules/auth/. Wire navigation on auth
      // edges here, e.g.
      //   onUnauthenticated: (_) => router.goNamed(Routes.login.name),
      // or re-run a route guard: onChanged: (_, _) => router.refresh().
      child: AuthBootstrapper(child: child),
    );
  }
}
