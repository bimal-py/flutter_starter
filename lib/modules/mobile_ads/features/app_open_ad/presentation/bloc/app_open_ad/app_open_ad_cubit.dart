import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/mobile_ads/features/app_open_ad/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'app_open_ad_state.dart';

class AppOpenAdCubit extends SafeCubit<AppOpenAdState> {
  AppOpenAdCubit() : super(const AppOpenAdState());

  AppOpenAd? _appOpenAd;
  DateTime? _loadedAt;
  StreamSubscription<AppState>? _subscription;

  bool get isAdReady =>
      _appOpenAd != null &&
      state.status == AppOpenAdStatus.loaded &&
      !_isExpired;

  bool get _isExpired {
    final loadedAt = _loadedAt;
    if (loadedAt == null) return true;
    return DateTime.now()
        .subtract(AppOpenAdConstants.maxCacheDuration)
        .isAfter(loadedAt);
  }

  void load() {
    emit(state.copyWith(status: AppOpenAdStatus.loading));
    AppOpenAd.load(
      adUnitId: AppOpenAdHelper.adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          // Loaded after close: nothing would ever show or dispose it.
          if (isClosed) {
            ad.dispose();
            return;
          }
          _appOpenAd?.dispose();
          _appOpenAd = ad;
          _loadedAt = DateTime.now();
          emit(state.copyWith(status: AppOpenAdStatus.loaded));
        },
        onAdFailedToLoad: (error) {
          emit(
            state.copyWith(
              status: AppOpenAdStatus.failed,
              error: error.message,
            ),
          );
        },
      ),
    );
  }

  /// Shows the cached ad, or starts loading one when there is none or it
  /// has expired.
  void showAd() {
    final ad = _appOpenAd;
    if (ad == null || !isAdReady) {
      load();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        emit(state.copyWith(status: AppOpenAdStatus.showing));
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _clearAd();
        emit(state.copyWith(status: AppOpenAdStatus.initial));
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _clearAd();
        emit(
          state.copyWith(status: AppOpenAdStatus.failed, error: error.message),
        );
        load();
      },
    );
    ad.show();
  }

  /// Shows the ad each time the app comes back to the foreground.
  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    _subscription = AppStateEventNotifier.appStateStream.listen((appState) {
      if (appState == AppState.foreground) showAd();
    });
  }

  void _clearAd() {
    _appOpenAd = null;
    _loadedAt = null;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _appOpenAd?.dispose();
    return super.close();
  }
}
