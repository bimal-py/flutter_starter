import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';

part 'register_state.dart';

/// Sign-up step 1: accept the terms and email a code.
class RegisterCubit extends SafeCubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

  final SendVerificationCodeUseCase _sendCodeUseCase =
      getIt<SendVerificationCodeUseCase>();

  void setAcceptedTerms(bool accepted) =>
      emit(state.copyWith(acceptedTerms: accepted));

  Future<void> sendCode(String email) async {
    if (!state.acceptedTerms || state.loadingState.isLoading) return;
    emit(
      state.copyWith(loadingState: AppLoadingState.loading, clearError: true),
    );
    try {
      final code = await _sendCodeUseCase.execute(
        SendVerificationCodeUseCaseParams(email: email),
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
