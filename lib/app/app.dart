import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/app/global_bloc_config.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/app_upgrade/app_upgrade.dart';
import 'package:flutter_starter/modules/auth/auth.dart';

class StarterApp extends StatelessWidget {
  const StarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingOverlayWidget(
      child: GlobalBlocConfig(child: const _StarterAppView()),
    );
  }
}

class _StarterAppView extends StatelessWidget {
  const _StarterAppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return DynamicColorBuilder(
          builder: (deviceLight, deviceDark) {
            final composed = AppThemeBuilder.compose(
              context: context,
              source: themeState.effectiveSource,
              deviceLightScheme: deviceLight,
              deviceDarkScheme: deviceDark,
              fonts: LocalizedFonts.defaults(),
              extensionBuilder: context.read<ThemeCubit>().extensionBuilder,
            );
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: composed.light,
              darkTheme: composed.dark,
              themeMode: themeState.variant.toThemeMode(),
              routerConfig: router,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(
                    context,
                  ).textScaler.clamp(maxScaleFactor: 1.2),
                ),
                // Optional. Remove with the app_upgrade module.
                child: AppUpgradeBootstrapper(
                  // Optional. Remove with the auth module. Wire callbacks
                  // for route redirects on auth-state edges, e.g.:
                  //   onUnauthenticated: (_) => router.goNamed('login'),
                  //   onAuthenticated:   (_, _) => router.goNamed('dashboard'),
                  child: AuthBootstrapper(child: child!),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
