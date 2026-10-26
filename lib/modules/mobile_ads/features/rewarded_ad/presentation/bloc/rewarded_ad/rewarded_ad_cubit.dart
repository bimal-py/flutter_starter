import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/mobile_ads/mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'rewarded_ad_state.dart';

class RewardedAdCubit extends Cubit<RewardedAdState> {
  RewardedAdCubit() : super(const RewardedAdState());

  RewardedAd? _rewardedAd;
  Timer? _retryTimer;
  int _retryCount = 0;

  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  void loadAd() {
    _retryTimer?.cancel();
    emit(state.copyWith(status: RewardedStatus.loading));

    RewardedAdHelper.loadRewardedAd(
      onLoaded: (ad) {
        _retryCount = 0;
        _rewardedAd = ad;
        emit(state.copyWith(status: RewardedStatus.loaded));
      },
      onFailed: (error) {
        emit(state.copyWith(status: RewardedStatus.failed, error: error));
        _scheduleRetry();
      },
    );
  }

  void showAd({
    required Function(RewardItem reward) onRewarded,
    VoidCallback? onClosed,
  }) {
    if (_rewardedAd == null) {
      onClosed?.call();
      return;
    }

    emit(state.copyWith(status: RewardedStatus.showing));

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onClosed?.call();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onClosed?.call();
        loadAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) => onRewarded(reward));
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

  bool get isAdReady => _rewardedAd != null;

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    _rewardedAd?.dispose();
    return super.close();
  }
}
