import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/features/banner_ad/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'banner_ad_state.dart';

class BannerAdCubit extends SafeCubit<BannerAdState> {
  BannerAdCubit() : super(const BannerAdState());

  BannerAd? _bannerAd;
  Timer? _retryTimer;
  int _retryCount = 0;
  int? _lastWidth;

  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  /// Loads a large anchored adaptive banner for [width] (the last width
  /// otherwise, then 320). Calling it again drops the current banner and
  /// starts the retries over.
  void load({int? width}) {
    _retryCount = 0;
    _bannerAd?.dispose();
    _bannerAd = null;
    unawaited(_load(width: width));
  }

  Future<void> _load({int? width}) async {
    _retryTimer?.cancel();
    _lastWidth = width ?? _lastWidth;

    emit(state.copyWith(loadingState: AppLoadingState.loading));

    final adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      _lastWidth ?? AdSize.banner.width,
    );
    if (isClosed) return;
    final size = adSize ?? AdSize.banner;

    _bannerAd = BannerAd(
      adUnitId: BannerAdHelper.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _retryCount = 0;
          emit(
            state.copyWith(
              loadingState: AppLoadingState.success,
              bannerAd: ad as BannerAd,
            ),
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          emit(
            state.copyWith(
              loadingState: AppLoadingState.failure,
              error: error.message,
            ),
          );
          _scheduleRetry();
        },
      ),
    );

    _bannerAd!.load();
  }

  void _scheduleRetry() {
    if (isClosed || _retryCount >= _retryDelays.length) return;
    final delay = _retryDelays[_retryCount++];
    _retryTimer = Timer(delay, _load);
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    return super.close();
  }
}
