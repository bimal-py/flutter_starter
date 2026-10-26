import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'native_template_ad_state.dart';

class NativeTemplateAdCubit extends Cubit<NativeTemplateAdState> {
  NativeTemplateAdCubit() : super(const NativeTemplateAdState());

  Timer? _retryTimer;
  int _retryCount = 0;
  TemplateType _lastTemplateType = TemplateType.medium;

  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  void loadAd({TemplateType templateType = TemplateType.medium}) {
    _retryTimer?.cancel();
    _lastTemplateType = templateType;

    emit(state.copyWith(appLoadingState: AppLoadingState.loading));

    final nativeAd = NativeAd(
      adUnitId: NativeAdHelper.adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _retryCount = 0;
          emit(
            state.copyWith(
              appLoadingState: AppLoadingState.success,
              nativeAd: ad as NativeAd,
            ),
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          emit(
            state.copyWith(
              appLoadingState: AppLoadingState.failure,
              error: error.message,
            ),
          );
          _scheduleRetry();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: templateType),
    );

    nativeAd.load();
  }

  void _scheduleRetry() {
    if (_retryCount >= _retryDelays.length) return;
    final delay = _retryDelays[_retryCount++];
    _retryTimer = Timer(delay, () => loadAd(templateType: _lastTemplateType));
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    state.nativeAd?.dispose();
    return super.close();
  }
}
