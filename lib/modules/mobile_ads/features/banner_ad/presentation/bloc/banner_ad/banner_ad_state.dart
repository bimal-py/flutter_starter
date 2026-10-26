part of 'banner_ad_cubit.dart';

class BannerAdState extends Equatable {
  const BannerAdState({
    this.loadingState = AppLoadingState.initial,
    this.bannerAd,
    this.error,
  });

  final AppLoadingState loadingState;
  final BannerAd? bannerAd;
  final String? error;

  BannerAdState copyWith({
    AppLoadingState? loadingState,
    BannerAd? bannerAd,
    String? error,
  }) {
    return BannerAdState(
      loadingState: loadingState ?? this.loadingState,
      bannerAd: bannerAd ?? this.bannerAd,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loadingState, bannerAd, error];
}
