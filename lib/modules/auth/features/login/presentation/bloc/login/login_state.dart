part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.remember = true,
    this.rememberedEmail,
    this.loadingState = AppLoadingState.initial,
    this.error,
  });

  final bool remember;

  /// Email from the last login with "Remember me" on, to prefill the form.
  final String? rememberedEmail;
  final AppLoadingState loadingState;
  final String? error;

  LoginState copyWith({
    bool? remember,
    AppLoadingState? loadingState,
    String? error,
    bool clearError = false,
  }) => LoginState(
    remember: remember ?? this.remember,
    rememberedEmail: rememberedEmail,
    loadingState: loadingState ?? this.loadingState,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [remember, rememberedEmail, loadingState, error];
}
