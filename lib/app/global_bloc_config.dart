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
        BlocProvider<AppSettingCubit>(create: (_) => AppSettingCubit()),
        BlocProvider<PackageInfoCubit>(
          lazy: false,
          create: (_) => PackageInfoCubit()..loadPackageInfo(),
        ),
        BlocProvider<DeviceInfoCubit>(
          lazy: false,
          create: (_) => DeviceInfoCubit()..loadDeviceInfo(),
        ),
        // Optional. Delete with lib/modules/app_upgrade/ to remove update popup.
        BlocProvider<AppUpgradeCubit>(create: (_) => AppUpgradeCubit()),
        // Optional. The bloc resolves use cases via getIt — write your own
        // `@LazySingleton(as: AuthRepository)` class before shipping (REST /
        // Firebase / Supabase). Delete with lib/modules/auth/ to remove.
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
      ],
      child: child,
    );
  }
}
