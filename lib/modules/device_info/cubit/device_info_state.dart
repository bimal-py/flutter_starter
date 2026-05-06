part of 'device_info_cubit.dart';

class DeviceInfoState extends Equatable {
  const DeviceInfoState({this.deviceInfo});

  final BaseDeviceInfo? deviceInfo;

  DeviceInfoState copyWith({BaseDeviceInfo? deviceInfo}) =>
      DeviceInfoState(deviceInfo: deviceInfo ?? this.deviceInfo);

  @override
  List<Object?> get props => [deviceInfo];
}
