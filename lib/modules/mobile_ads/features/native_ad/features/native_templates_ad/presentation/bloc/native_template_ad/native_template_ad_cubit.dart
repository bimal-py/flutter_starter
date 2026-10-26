import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/features/native_ad/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'native_template_ad_state.dart';

class NativeTemplateAdCubit extends SafeCubit<NativeTemplateAdState> {
  NativeTemplateAdCubit() : super(const NativeTemplateAdState());

  Timer? _retryTimer;
  int _retryCount = 0;
  TemplateType _templateType = TemplateType.medium;

  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  /// First load, and "try again": starts the retries over. Retries reuse
  /// [templateType].
  void load({TemplateType templateType = TemplateType.medium}) {
    _retryCount = 0;
    _templateType = templateType;
    _load();
  }

  void _load() {
    _retryTimer?.cancel();
    emit(state.copyWith(loadingState: AppLoadingState.loading));

    NativeAd(
      adUnitId: NativeAdHelper.adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          // Loaded after close: nothing would ever show or dispose it.
          if (isClosed) {
            ad.dispose();
            return;
          }
          _retryCount = 0;
          emit(
            state.copyWith(
              loadingState: AppLoadingState.success,
              nativeAd: ad as NativeAd,
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
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: _templateType),
    ).load();
  }

  void _scheduleRetry() {
    if (isClosed || _retryCount >= _retryDelays.length) return;
    final delay = _retryDelays[_retryCount++];
    _retryTimer = Timer(delay, _load);
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    state.nativeAd?.dispose();
    return super.close();
  }
}
