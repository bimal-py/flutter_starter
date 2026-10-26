import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';

part 'reset_password_state.dart';

/// Reset step 2: set the new password with the code, or resend the code.
class ResetPasswordCubit extends SafeCubit<ResetPasswordState> {
  ResetPasswordCubit({required String email})
    : super(ResetPasswordState(email: email));

  final ConfirmPasswordResetUseCase _confirmUseCase =
      getIt<ConfirmPasswordResetUseCase>();
  final RequestPasswordResetUseCase _requestUseCase =
      getIt<RequestPasswordResetUseCase>();

  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) => _run(ResetPasswordAction.reset, () async {
    await _confirmUseCase.execute(
      ConfirmPasswordResetUseCaseParams(
        email: state.email,
        code: code,
        newPassword: newPassword,
      ),
    );
    return null;
  });

  Future<void> resendCode() => _run(
    ResetPasswordAction.resend,
    () => _requestUseCase.execute(
      RequestPasswordResetUseCaseParams(email: state.email),
    ),
  );

  Future<void> _run(
    ResetPasswordAction action,
    Future<VerificationCodeEntity?> Function() request,
  ) async {
    if (state.loadingState.isLoading) return;
    emit(
      state.copyWith(
        action: action,
        loadingState: AppLoadingState.loading,
        clearError: true,
      ),
    );
    try {
      final code = await request();
      emit(state.copyWith(loadingState: AppLoadingState.success, code: code));
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
