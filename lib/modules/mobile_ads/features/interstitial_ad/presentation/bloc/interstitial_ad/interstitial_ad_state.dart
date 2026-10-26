part of 'interstitial_ad_cubit.dart';

enum InterstitialAdStatus { initial, loading, loaded, showing, failed }

class InterstitialAdState extends Equatable {
  const InterstitialAdState({
    this.status = InterstitialAdStatus.initial,
    this.error,
  });

  final InterstitialAdStatus status;
  final String? error;

  InterstitialAdState copyWith({InterstitialAdStatus? status, String? error}) {
    return InterstitialAdState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
