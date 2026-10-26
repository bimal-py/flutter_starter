part of 'third_party_auth_cubit.dart';

class ThirdPartyAuthState extends Equatable {
  const ThirdPartyAuthState({
    this.loadingState = AppLoadingState.initial,
    this.error,
    this.notice,
  });

  final AppLoadingState loadingState;
  final String? error;

  /// Shown as an info toast, e.g. "Google sign-in was cancelled."
  final String? notice;

  ThirdPartyAuthState copyWith({
    AppLoadingState? loadingState,
    String? error,
    bool clearError = false,
    String? notice,
    bool clearNotice = false,
  }) => ThirdPartyAuthState(
    loadingState: loadingState ?? this.loadingState,
    error: clearError ? null : (error ?? this.error),
    notice: clearNotice ? null : (notice ?? this.notice),
  );

  @override
  List<Object?> get props => [loadingState, error, notice];
}
