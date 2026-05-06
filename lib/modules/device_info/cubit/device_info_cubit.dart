import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'device_info_state.dart';

class DeviceInfoCubit extends Cubit<DeviceInfoState> {
  DeviceInfoCubit() : super(const DeviceInfoState());

  Future<void> loadDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    final BaseDeviceInfo info = kIsWeb
        ? await plugin.webBrowserInfo
        : switch (defaultTargetPlatform) {
            TargetPlatform.android => await plugin.androidInfo,
            TargetPlatform.iOS => await plugin.iosInfo,
            TargetPlatform.macOS => await plugin.macOsInfo,
            TargetPlatform.windows => await plugin.windowsInfo,
            TargetPlatform.linux => await plugin.linuxInfo,
            _ => await plugin.deviceInfo,
          };
    emit(state.copyWith(deviceInfo: info));
  }
}
