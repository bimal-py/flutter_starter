import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/device_info/domain/domain.dart';

part 'device_info_state.dart';

class DeviceInfoCubit extends SafeCubit<DeviceInfoState> {
  DeviceInfoCubit() : super(const DeviceInfoState());

  final GetDeviceInfoUseCase _getDeviceInfoUseCase =
      getIt<GetDeviceInfoUseCase>();

  Future<void> load() async {
    emit(
      state.copyWith(loadingState: AppLoadingState.loading, clearError: true),
    );
    try {
      final entity = await _getDeviceInfoUseCase.execute(const NoParams());
      emit(
        state.copyWith(
          loadingState: AppLoadingState.success,
          deviceInfo: entity,
        ),
      );
    } catch (error) {
      // Diagnostics only (feedback email): a failure never blocks the app.
      emit(
        state.copyWith(
          loadingState: AppLoadingState.failure,
          error: AppErrorHandler.getErrorMessage(error),
        ),
      );
    }
  }
}
