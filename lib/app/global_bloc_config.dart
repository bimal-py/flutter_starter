import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/app_setting/app_setting.dart';
import 'package:flutter_starter/modules/app_upgrade/app_upgrade.dart';
import 'package:flutter_starter/modules/auth/auth.dart';
import 'package:flutter_starter/modules/device_info/device_info.dart';
import 'package:flutter_starter/modules/package_info/package_info.dart';

class GlobalBlocConfig extends StatelessWidget {
  const GlobalBlocConfig({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        // Optional. Remove with lib/modules/app_setting/.
        BlocProvider<AppSettingCubit>(create: (_) => AppSettingCubit()),
        // Optional. Remove with lib/modules/package_info/.
        BlocProvider<PackageInfoCubit>(
          lazy: false,
          create: (_) => PackageInfoCubit()..load(),
        ),
        // Optional. Remove with lib/modules/device_info/.
        BlocProvider<DeviceInfoCubit>(
          lazy: false,
          create: (_) => DeviceInfoCubit()..load(),
        ),
        // Optional. Remove with lib/modules/app_upgrade/.
        BlocProvider<AppUpgradeCubit>(create: (_) => AppUpgradeCubit()),
        // Optional. Remove with lib/modules/auth/. Eager, so the saved
        // session is restored at launch.
        BlocProvider<AuthBloc>(lazy: false, create: (_) => AuthBloc()),
      ],
      child: child,
    );
  }
}
