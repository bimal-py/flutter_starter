part of 'qr_save_cubit.dart';

class QrSaveState extends Equatable {
  const QrSaveState({this.loadingState = AppLoadingState.initial, this.error});

  final AppLoadingState loadingState;
  final String? error;

  QrSaveState copyWith({
    AppLoadingState? loadingState,
    String? error,
    bool clearError = false,
  }) => QrSaveState(
    loadingState: loadingState ?? this.loadingState,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loadingState, error];
}
