import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';

part 'complete_registration_state.dart';

/// Sign-up step 2: create the account with the code, or resend the code.
class CompleteRegistrationCubit extends SafeCubit<CompleteRegistrationState> {
  CompleteRegistrationCubit({required String email})
    : super(CompleteRegistrationState(email: email));

  final RegisterUseCase _registerUseCase = getIt<RegisterUseCase>();
  final SendVerificationCodeUseCase _sendCodeUseCase =
      getIt<SendVerificationCodeUseCase>();

  bool _signedIn = false;

  Future<void> register({required String code, required String password}) =>
      _run(CompleteRegistrationAction.register, () async {
        _signedIn = await _registerUseCase.execute(
          RegisterUseCaseParams(
            email: state.email,
            code: code,
            password: password,
          ),
        );
        return null;
      });

  Future<void> resendCode() => _run(
    CompleteRegistrationAction.resend,
    () => _sendCodeUseCase.execute(
      SendVerificationCodeUseCaseParams(email: state.email),
    ),
  );

  Future<void> _run(
    CompleteRegistrationAction action,
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
      emit(
        state.copyWith(
          loadingState: AppLoadingState.success,
          code: code,
          signedIn: _signedIn,
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
