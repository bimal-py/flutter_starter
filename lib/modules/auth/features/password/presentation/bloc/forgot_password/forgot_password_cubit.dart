import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';

part 'forgot_password_state.dart';

/// Reset step 1: email a code.
class ForgotPasswordCubit extends SafeCubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(const ForgotPasswordState());

  final RequestPasswordResetUseCase _requestUseCase =
      getIt<RequestPasswordResetUseCase>();

  Future<void> requestCode(String email) async {
    if (state.loadingState.isLoading) return;
    emit(
      state.copyWith(loadingState: AppLoadingState.loading, clearError: true),
    );
    try {
      final code = await _requestUseCase.execute(
        RequestPasswordResetUseCaseParams(email: email),
      );
      emit(
        state.copyWith(
          loadingState: AppLoadingState.success,
          email: email.trim().toLowerCase(),
          code: code,
        ),
      );
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
