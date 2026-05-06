import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/device_info/cubit/cubit.dart';

class DeviceInfoScreen extends StatelessWidget {
  const DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeviceInfoCubit()..loadDeviceInfo(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Device info')),
        body: BlocBuilder<DeviceInfoCubit, DeviceInfoState>(
          builder: (_, state) {
            final info = state.deviceInfo;
            if (info == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = info.data.entries.toList();
            return ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = entries[i];
                return InfoRowTile(label: e.key, value: '${e.value}');
              },
            );
          },
        ),
      ),
    );
  }
}
