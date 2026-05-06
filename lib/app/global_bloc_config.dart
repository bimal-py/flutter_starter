import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/app_setting/app_setting.dart';
import 'package:flutter_starter/modules/theme/theme.dart';

/// App-wide blocs/cubits provided once near the root so any descendant can
/// `context.read<T>()`. Add cross-cutting state here (theme, locale, auth, ...).
class GlobalBlocConfig extends StatelessWidget {
  const GlobalBlocConfig({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<AppSettingCubit>(create: (_) => getIt<AppSettingCubit>()),
      ],
      child: child,
    );
  }
}
