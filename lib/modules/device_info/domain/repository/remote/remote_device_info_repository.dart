import 'package:flutter_starter/modules/device_info/domain/entity/entity.dart';

abstract class RemoteDeviceInfoRepository {
  Future<DeviceInfoEntity> getDeviceInfo();
}
