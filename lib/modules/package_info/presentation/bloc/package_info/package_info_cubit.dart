import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/package_info/domain/domain.dart';

part 'package_info_state.dart';

class PackageInfoCubit extends SafeCubit<PackageInfoState> {
  PackageInfoCubit() : super(const PackageInfoState());

  final GetPackageInfoUseCase _getPackageInfoUseCase =
      getIt<GetPackageInfoUseCase>();

  Future<void> load() async {
    emit(
      state.copyWith(loadingState: AppLoadingState.loading, clearError: true),
    );
    try {
      final entity = await _getPackageInfoUseCase.execute(const NoParams());
      emit(
        state.copyWith(
          loadingState: AppLoadingState.success,
          packageInfo: entity,
        ),
      );
    } catch (error) {
      // Diagnostics only (version footer, feedback email): a failure never
      // blocks the app.
      emit(
        state.copyWith(
          loadingState: AppLoadingState.failure,
          error: AppErrorHandler.getErrorMessage(error),
        ),
      );
    }
  }
}
