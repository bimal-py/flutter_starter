part of 'reset_password_cubit.dart';

enum ResetPasswordAction { reset, resend }

class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    required this.email,
    this.action = ResetPasswordAction.reset,
    this.loadingState = AppLoadingState.initial,
    this.code,
    this.error,
  });

  final String email;

  /// Which request [loadingState] belongs to.
  final ResetPasswordAction action;
  final AppLoadingState loadingState;

  /// The latest resend result.
  final VerificationCodeEntity? code;
  final String? error;

  bool get isResend => action == ResetPasswordAction.resend;

  ResetPasswordState copyWith({
    ResetPasswordAction? action,
    AppLoadingState? loadingState,
    VerificationCodeEntity? code,
    String? error,
    bool clearError = false,
  }) => ResetPasswordState(
    email: email,
    action: action ?? this.action,
    loadingState: loadingState ?? this.loadingState,
    code: code ?? this.code,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [email, action, loadingState, code, error];
}
