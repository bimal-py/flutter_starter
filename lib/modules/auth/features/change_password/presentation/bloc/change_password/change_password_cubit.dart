import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';

part 'change_password_state.dart';

/// Signed-in password change; this device stays logged in.
class ChangePasswordCubit extends SafeCubit<ChangePasswordState> {
  ChangePasswordCubit() : super(const ChangePasswordState());

  final ChangePasswordUseCase _changePasswordUseCase =
      getIt<ChangePasswordUseCase>();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.loadingState.isLoading) return;
    emit(
      state.copyWith(loadingState: AppLoadingState.loading, clearError: true),
    );
    final problem = currentPassword.isEmpty
        ? AuthError.currentPasswordRequired
        : AuthValidators.password(newPassword);
    if (problem != null) {
      emit(
        state.copyWith(loadingState: AppLoadingState.failure, error: problem),
      );
      return;
    }
    try {
      await _changePasswordUseCase.execute(
        ChangePasswordUseCaseParams(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
      emit(state.copyWith(loadingState: AppLoadingState.success));
    } catch (error) {
      emit(
        state.copyWith(
          loadingState: AppLoadingState.failure,
          error: AppErrorHandler.getErrorMessage(error),
        ),
      );
    }
  }
}
