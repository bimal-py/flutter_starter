import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/app/global_bloc_config.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';

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
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
