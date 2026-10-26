import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';

/// Themed router app. Rebuilds when the theme cubit changes.
class StarterAppView extends StatelessWidget {
  const StarterAppView({super.key});

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
                  textScaler: MediaQuery.of(context).textScaler
                      .clamp(maxScaleFactor: 1.2),
                ),
                // One status-bar style for the whole app, from the theme's
                // app bar; screens never set their own.
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value:
                      Theme.of(context).appBarTheme.systemOverlayStyle ??
                      (Theme.of(context).brightness == Brightness.dark
                          ? SystemUiOverlayStyle.light
                          : SystemUiOverlayStyle.dark),
                  // Inside MaterialApp, so the popup loader gets the app theme.
                  child: LoadingOverlayWidget(
                    child: AppBootstrappers(child: child!),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
