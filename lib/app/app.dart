import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/app/global_bloc_config.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/theme/theme.dart';

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
    return BlocBuilder<ThemeCubit, ThemeModeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeConfigs.lightTheme(context: context),
          darkTheme: ThemeConfigs.darkTheme(context: context),
          themeMode: themeState.themeMode,
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
  }
}
