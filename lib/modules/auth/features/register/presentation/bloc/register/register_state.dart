part of 'register_cubit.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.acceptedTerms = false,
    this.loadingState = AppLoadingState.initial,
    this.email,
    this.code,
    this.error,
  });

  final bool acceptedTerms;
  final AppLoadingState loadingState;

  /// Where the code went, as sent to the server.
  final String? email;
  final VerificationCodeEntity? code;
  final String? error;

  RegisterState copyWith({
    bool? acceptedTerms,
    AppLoadingState? loadingState,
    String? email,
    VerificationCodeEntity? code,
    String? error,
    bool clearError = false,
  }) => RegisterState(
    acceptedTerms: acceptedTerms ?? this.acceptedTerms,
    loadingState: loadingState ?? this.loadingState,
    email: email ?? this.email,
    code: code ?? this.code,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [acceptedTerms, loadingState, email, code, error];
}
