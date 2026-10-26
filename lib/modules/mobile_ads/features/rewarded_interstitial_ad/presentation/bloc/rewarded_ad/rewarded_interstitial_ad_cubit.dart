import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/mobile_ads/mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'rewarded_interstitial_ad_state.dart';

class RewardedInterstitialAdCubit extends Cubit<RewardedInterstitialAdState> {
  RewardedInterstitialAdCubit() : super(const RewardedInterstitialAdState());

  RewardedInterstitialAd? _rewardedInterstitialAd;
  Timer? _retryTimer;
  int _retryCount = 0;

  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  void loadAd() {
    _retryTimer?.cancel();
    emit(state.copyWith(status: RewardedInterstitialAdStatus.loading));

    RewardedInterstitialAdHelper.loadRewardedInterstitialAd(
      onLoaded: (ad) {
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

  void showAd({
    required Function(RewardItem reward) onRewarded,
    VoidCallback? onClosed,
  }) {
    if (_rewardedInterstitialAd == null) {
      onClosed?.call();
      return;
    }

    emit(state.copyWith(status: RewardedInterstitialAdStatus.showing));

    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _rewardedInterstitialAd = null;
            onClosed?.call();
            loadAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _rewardedInterstitialAd = null;
            onClosed?.call();
            loadAd();
          },
        );

    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) => onRewarded(reward),
    );
  }

  void retryLoad() {
    _retryCount = 0;
    loadAd();
  }

  void _scheduleRetry() {
    if (_retryCount >= _retryDelays.length) return;
    final delay = _retryDelays[_retryCount++];
    _retryTimer = Timer(delay, loadAd);
  }

  bool get isAdReady => _rewardedInterstitialAd != null;

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    _rewardedInterstitialAd?.dispose();
    return super.close();
  }
}
