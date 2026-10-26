import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'banner_ad_state.dart';

class BannerAdCubit extends Cubit<BannerAdState> {
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

  void loadAd({int? width}) async {
    _retryTimer?.cancel();
    _lastWidth = width ?? _lastWidth;

    emit(state.copyWith(loadingState: AppLoadingState.loading));

    final adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      _lastWidth ?? AdSize.banner.width,
    );
    final size = adSize ?? AdSize.banner;

    _bannerAd = BannerAd(
      adUnitId: BannerAdHelper.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _retryCount = 0;
          emit(
            state.copyWith(
              loadingState: AppLoadingState.success,
              bannerAd: ad as BannerAd,
              bannerHeight: size.height.toDouble(),
            ),
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          emit(
            state.copyWith(
              loadingState: AppLoadingState.failure,
              error: error.message,
              bannerHeight: size.height.toDouble(),
            ),
          );
          _scheduleRetry();
        },
      ),
    );

    _bannerAd!.load();
  }

  void reloadAd({int? width}) {
    _retryCount = 0;
    _bannerAd?.dispose();
    _bannerAd = null;
    loadAd(width: width);
  }

  void _scheduleRetry() {
    if (_retryCount >= _retryDelays.length) return;
    final delay = _retryDelays[_retryCount++];
    _retryTimer = Timer(delay, () => loadAd());
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    return super.close();
  }
}
