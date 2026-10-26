import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';

part 'third_party_auth_state.dart';

/// Google / Apple sign-in for the login and register screens.
class ThirdPartyAuthCubit extends SafeCubit<ThirdPartyAuthState> {
  ThirdPartyAuthCubit() : super(const ThirdPartyAuthState());

  final LoginWithGoogleUseCase _googleUseCase = getIt<LoginWithGoogleUseCase>();
  final LoginWithAppleUseCase _appleUseCase = getIt<LoginWithAppleUseCase>();

  Future<void> loginWithGoogle(SocialLoginUseCaseParams params) =>
      _run(() => _googleUseCase.execute(params));

  Future<void> loginWithApple(SocialLoginUseCaseParams params) =>
      _run(() => _appleUseCase.execute(params));

  Future<void> _run(Future<void> Function() action) async {
    if (state.loadingState.isLoading) return;
    emit(
      state.copyWith(
        loadingState: AppLoadingState.loading,
        clearError: true,
        clearNotice: true,
      ),
    );
    try {
      await action();
      emit(state.copyWith(loadingState: AppLoadingState.success));
    } on ThirdPartyAuthCancelled catch (cancelled) {
      emit(
        state.copyWith(
          loadingState: AppLoadingState.initial,
          notice: cancelled.message,
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
