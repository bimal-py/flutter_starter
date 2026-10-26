part of 'device_info_cubit.dart';

class DeviceInfoState extends Equatable {
  const DeviceInfoState({
    this.loadingState = AppLoadingState.initial,
    this.deviceInfo,
    this.error,
  });

  final AppLoadingState loadingState;
  final DeviceInfoEntity? deviceInfo;
  final String? error;

  DeviceInfoState copyWith({
    AppLoadingState? loadingState,
    DeviceInfoEntity? deviceInfo,
    String? error,
    bool clearError = false,
  }) => DeviceInfoState(
    loadingState: loadingState ?? this.loadingState,
    deviceInfo: deviceInfo ?? this.deviceInfo,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loadingState, deviceInfo, error];
}
