import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/package_info/cubit/cubit.dart';

class PackageInfoScreen extends StatelessWidget {
  const PackageInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackageInfoCubit()..loadPackageInfo(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Package info')),
        body: BlocBuilder<PackageInfoCubit, PackageInfoState>(
          builder: (_, state) {
            final info = state.packageInfo;
            if (info == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final rows = <(String, String)>[
              ('App name', info.appName),
              ('Package', info.packageName),
              ('Version', info.version),
              ('Build', info.buildNumber),
            ];
            return ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  InfoRowTile(label: rows[i].$1, value: rows[i].$2),
            );
          },
        ),
      ),
    );
  }
}
