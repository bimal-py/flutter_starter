import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';

part 'login_state.dart';

class LoginCubit extends SafeCubit<LoginState> {
  LoginCubit() : super(_initialState());

  /// "Remember me" starts ticked; the last remembered email is filled in.
  static LoginState _initialState() {
    final email = getIt<GetRememberedEmailUseCase>().execute(const NoParams());
    return LoginState(remember: true, rememberedEmail: email);
  }

  final LoginUseCase _loginUseCase = getIt<LoginUseCase>();

  void setRemember(bool remember) => emit(state.copyWith(remember: remember));

  Future<void> login({required String email, required String password}) async {
    if (state.loadingState.isLoading) return;
    emit(
      state.copyWith(loadingState: AppLoadingState.loading, clearError: true),
    );
    try {
      await _loginUseCase.execute(
        LoginUseCaseParams(
          email: email,
          password: password,
          remember: state.remember,
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
