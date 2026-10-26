import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter/modules/device_info/domain/domain.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RemoteDeviceInfoRepository)
class RemoteDeviceInfoRepositoryImpl implements RemoteDeviceInfoRepository {
  @override
  Future<DeviceInfoEntity> getDeviceInfo() async {
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
    return DeviceInfoEntity(
      platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
      data: info.data.map((k, v) => MapEntry(k, v ?? '')),
    );
  }
}
