part of 'complete_registration_cubit.dart';

enum CompleteRegistrationAction { register, resend }

class CompleteRegistrationState extends Equatable {
  const CompleteRegistrationState({
    required this.email,
    this.action = CompleteRegistrationAction.register,
    this.loadingState = AppLoadingState.initial,
    this.code,
    this.signedIn = false,
    this.error,
  });

  final String email;

  /// Which request [loadingState] belongs to.
  final CompleteRegistrationAction action;
  final AppLoadingState loadingState;

  /// The latest resend result.
  final VerificationCodeEntity? code;

  /// After register: true when the user is signed in, false when they log in.
  final bool signedIn;
  final String? error;

  bool get isResend => action == CompleteRegistrationAction.resend;

  CompleteRegistrationState copyWith({
    CompleteRegistrationAction? action,
    AppLoadingState? loadingState,
    VerificationCodeEntity? code,
    bool? signedIn,
    String? error,
    bool clearError = false,
  }) => CompleteRegistrationState(
    email: email,
    action: action ?? this.action,
    loadingState: loadingState ?? this.loadingState,
    code: code ?? this.code,
    signedIn: signedIn ?? this.signedIn,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [
    email,
    action,
    loadingState,
    code,
    signedIn,
    error,
  ];
}
