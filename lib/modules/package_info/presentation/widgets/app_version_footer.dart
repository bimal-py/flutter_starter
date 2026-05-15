import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/package_info/cubit/cubit.dart';

/// Centered "Version x.y.z (build)" text. Reads from the globally-provided
/// [PackageInfoCubit] and renders nothing until the info has loaded.
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
              'Version ${info.version} (${info.buildNumber})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}
