part of 'package_info_cubit.dart';

class PackageInfoState extends Equatable {
  const PackageInfoState({
    this.loadingState = AppLoadingState.initial,
    this.packageInfo,
    this.error,
  });

  final AppLoadingState loadingState;
  final PackageInfoEntity? packageInfo;
  final String? error;

  PackageInfoState copyWith({
    AppLoadingState? loadingState,
    PackageInfoEntity? packageInfo,
    String? error,
    bool clearError = false,
  }) => PackageInfoState(
    loadingState: loadingState ?? this.loadingState,
    packageInfo: packageInfo ?? this.packageInfo,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loadingState, packageInfo, error];
}
