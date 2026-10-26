import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/package_info/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/package_info/utils/constants/constants.dart';

/// Centered "Version x.y.z (build)". Reads the app-wide [PackageInfoCubit]
/// and renders nothing until the info has loaded: no shimmer or error for a
/// line of diagnostics.
class AppVersionFooter extends StatelessWidget {
  const AppVersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackageInfoCubit, PackageInfoState>(
      builder: (_, state) {
        final info = state.packageInfo;
        if (info == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Center(
            child: Text(
              PackageInfoStrings.version(info.version, info.buildNumber),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}
