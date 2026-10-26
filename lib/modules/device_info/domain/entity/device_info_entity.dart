import 'package:equatable/equatable.dart';

class DeviceInfoEntity extends Equatable {
  const DeviceInfoEntity({required this.platform, required this.data});

  final String platform;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [platform, data];
}
