import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/mobile_ads/features/interstitial_ad/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'interstitial_ad_state.dart';

class InterstitialAdCubit extends SafeCubit<InterstitialAdState> {
  InterstitialAdCubit() : super(const InterstitialAdState());

  InterstitialAd? _interstitialAd;
  Timer? _retryTimer;
  int _retryCount = 0;

  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  bool get isAdReady => _interstitialAd != null;

  /// First load, and "try again": starts the retries over.
  void load() {
    _retryCount = 0;
    _load();
  }

  /// [onAdClosed] runs when the ad closes, or at once when none is loaded.
  void showAd({VoidCallback? onAdClosed}) {
    final ad = _interstitialAd;
    if (ad == null) {
      onAdClosed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onAdClosed?.call();
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        onAdClosed?.call();
        _load();
      },
    );

    ad.show();
  }

  void _load() {
    _retryTimer?.cancel();
    emit(state.copyWith(status: InterstitialAdStatus.loading));

    InterstitialAd.load(
      adUnitId: InterstitialAdHelper.adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // Loaded after close: nothing would ever show or dispose it.
          if (isClosed) {
            ad.dispose();
            return;
          }
          _retryCount = 0;
          _interstitialAd = ad..setImmersiveMode(true);
          emit(state.copyWith(status: InterstitialAdStatus.loaded));
        },
        onAdFailedToLoad: (error) {
          emit(
            state.copyWith(
              status: InterstitialAdStatus.failed,
              error: error.message,
            ),
          );
          _scheduleRetry();
        },
      ),
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
    _interstitialAd?.dispose();
    return super.close();
  }
}
