import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_starter/modules/mobile_ads/mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'app_open_ad_state.dart';

class AppOpenAdCubit extends Cubit<AppOpenAdState> {
  AppOpenAdCubit() : super(const AppOpenAdState());

  StreamSubscription<AppState>? _subscription;

  void loadAd() {
    emit(state.copyWith(adStatus: AppOpenAdStatus.loading));
    AppOpenAd.load(
      adUnitId: AppOpenAdHelper.adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          state.appOpenAd?.dispose();
          emit(
            state.copyWith(
              adStatus: AppOpenAdStatus.loaded,
              appOpenAd: ad,
              appOpenAdLoadTime: DateTime.now(),
            ),
          );
          // Uncomment to show ad on first launch:
          // if (state.isFirstLaunch) {
          //   emit(state.copyWith(isFirstLaunch: false));
          //   Future.delayed(ConstantData.firstLaunchDelay, showAd);
          // }
        },
        onAdFailedToLoad: (error) {
          emit(
            state.copyWith(
              adStatus: AppOpenAdStatus.failed,
              error: error.toString(),
            ),
          );
        },
      ),
    );
  }

  bool isAdAvailable() {
    return state.appOpenAd != null &&
        state.adStatus == AppOpenAdStatus.loaded &&
        !isAdExpired();
  }

  bool isAdExpired() {
    if (state.appOpenAdLoadTime == null) return true;
    return DateTime.now()
        .subtract(ConstantData.maxCacheDuration)
        .isAfter(state.appOpenAdLoadTime!);
  }

  void showAd() {
    if (!isAdAvailable()) {
      loadAd();
      return;
    }
    if (state.adStatus == AppOpenAdStatus.showing) return;

    final ad = state.appOpenAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        emit(state.copyWith(adStatus: AppOpenAdStatus.showing));
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        emit(
          state.copyWith(
            adStatus: AppOpenAdStatus.initial,
            appOpenAd: null,
            appOpenAdLoadTime: null,
          ),
        );
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        emit(
          state.copyWith(
            adStatus: AppOpenAdStatus.failed,
            error: error.toString(),
            appOpenAd: null,
            appOpenAdLoadTime: null,
          ),
        );
        loadAd();
      },
    );
    ad.show();
  }

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    _subscription = AppStateEventNotifier.appStateStream.listen(
      _onAppStateChanged,
    );
  }

  void _onAppStateChanged(AppState appState) {
    if (appState == AppState.foreground) showAd();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    state.appOpenAd?.dispose();
    return super.close();
  }
}
