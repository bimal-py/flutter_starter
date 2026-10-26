part of 'rewarded_interstitial_ad_cubit.dart';

enum RewardedInterstitialAdStatus { initial, loading, loaded, failed, showing }

class RewardedInterstitialAdState extends Equatable {
  const RewardedInterstitialAdState({
    this.status = RewardedInterstitialAdStatus.initial,
    this.error,
  });

  final RewardedInterstitialAdStatus status;
  final String? error;

  RewardedInterstitialAdState copyWith({
    RewardedInterstitialAdStatus? status,
    String? error,
  }) {
    return RewardedInterstitialAdState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
