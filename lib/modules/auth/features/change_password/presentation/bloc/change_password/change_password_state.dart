part of 'change_password_cubit.dart';

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.loadingState = AppLoadingState.initial,
    this.error,
  });

  final AppLoadingState loadingState;
  final String? error;

  ChangePasswordState copyWith({
    AppLoadingState? loadingState,
    String? error,
    bool clearError = false,
  }) => ChangePasswordState(
    loadingState: loadingState ?? this.loadingState,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loadingState, error];
}
