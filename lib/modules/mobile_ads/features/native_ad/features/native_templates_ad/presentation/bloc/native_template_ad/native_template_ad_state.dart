part of 'native_template_ad_cubit.dart';

class NativeTemplateAdState extends Equatable {
  const NativeTemplateAdState({
    this.loadingState = AppLoadingState.initial,
    this.nativeAd,
    this.error,
  });

  final AppLoadingState loadingState;
  final NativeAd? nativeAd;
  final String? error;

  NativeTemplateAdState copyWith({
    AppLoadingState? loadingState,
    NativeAd? nativeAd,
    String? error,
  }) {
    return NativeTemplateAdState(
      loadingState: loadingState ?? this.loadingState,
      nativeAd: nativeAd ?? this.nativeAd,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loadingState, nativeAd, error];
}
