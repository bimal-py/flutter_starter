import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/mobile_ads/features/rewarded_interstitial_ad/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'rewarded_interstitial_ad_state.dart';

class RewardedInterstitialAdCubit
    extends SafeCubit<RewardedInterstitialAdState> {
  RewardedInterstitialAdCubit() : super(const RewardedInterstitialAdState());

  RewardedInterstitialAd? _rewardedInterstitialAd;
  Timer? _retryTimer;
  int _retryCount = 0;

  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  bool get isAdReady => _rewardedInterstitialAd != null;

  /// First load, and "try again": starts the retries over.
  void load() {
    _retryCount = 0;
    _load();
  }

  /// [onRewarded] runs when the user earns the reward; [onClosed] when the
  /// ad closes, or at once when none is loaded.
  void showAd({
    required ValueChanged<RewardItem> onRewarded,
    VoidCallback? onClosed,
  }) {
    final ad = _rewardedInterstitialAd;
    if (ad == null) {
      onClosed?.call();
      return;
    }

    emit(state.copyWith(status: RewardedInterstitialAdStatus.showing));

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        onClosed?.call();
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        onClosed?.call();
        _load();
      },
    );

    ad.show(onUserEarnedReward: (_, reward) => onRewarded(reward));
  }

  void _load() {
    _retryTimer?.cancel();
    emit(state.copyWith(status: RewardedInterstitialAdStatus.loading));

    RewardedInterstitialAdHelper.loadRewardedInterstitialAd(
      onLoaded: (ad) {
        // Loaded after close: nothing would ever show or dispose it.
        if (isClosed) {
          ad.dispose();
          return;
        }
        _retryCount = 0;
        _rewardedInterstitialAd = ad;
        emit(state.copyWith(status: RewardedInterstitialAdStatus.loaded));
      },
      onFailed: (error) {
        emit(
          state.copyWith(
            status: RewardedInterstitialAdStatus.failed,
            error: error,
          ),
        );
        _scheduleRetry();
      },
    );
  }

  void _scheduleRetry() {
    if (isClosed || _retryCount >= _retryDelays.length) return;
    final delay = _retryDelays[_retryCount++];
    _retryTimer = Timer(delay, _load);
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    _rewardedInterstitialAd?.dispose();
    return super.close();
  }
}
