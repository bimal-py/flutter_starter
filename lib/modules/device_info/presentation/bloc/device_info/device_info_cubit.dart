import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/device_info/domain/domain.dart';

part 'device_info_state.dart';

class DeviceInfoCubit extends Cubit<DeviceInfoState> {
  DeviceInfoCubit() : super(const DeviceInfoState());

  final GetDeviceInfoUseCase _getDeviceInfoUseCase =
      getIt<GetDeviceInfoUseCase>();

  Future<void> loadDeviceInfo() async {
    final entity = await _getDeviceInfoUseCase.execute(const NoParams());
    emit(state.copyWith(deviceInfo: entity));
  }
}
