part of 'forgot_password_cubit.dart';

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.loadingState = AppLoadingState.initial,
    this.email,
    this.code,
    this.error,
  });

  final AppLoadingState loadingState;

  /// Where the code went, as sent to the server.
  final String? email;
  final VerificationCodeEntity? code;
  final String? error;

  ForgotPasswordState copyWith({
    AppLoadingState? loadingState,
    String? email,
    VerificationCodeEntity? code,
    String? error,
    bool clearError = false,
  }) => ForgotPasswordState(
    loadingState: loadingState ?? this.loadingState,
    email: email ?? this.email,
    code: code ?? this.code,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loadingState, email, code, error];
}
