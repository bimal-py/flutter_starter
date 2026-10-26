import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedInterstitialAdHelper {
  RewardedInterstitialAdHelper._();

  static String get adUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode
          ? EnvHelper.get('PROD_ANDROID_REWARDED_INTERSTITIAL_AD_UNIT_ID')
          : EnvHelper.get('DEV_ANDROID_REWARDED_INTERSTITIAL_AD_UNIT_ID');
    } else if (Platform.isIOS) {
      return kReleaseMode
          ? EnvHelper.get('PROD_IOS_REWARDED_INTERSTITIAL_AD_UNIT_ID')
          : EnvHelper.get('DEV_IOS_REWARDED_INTERSTITIAL_AD_UNIT_ID');
    } else {
      throw UnsupportedError(MobileAdsError.unsupportedPlatform);
    }
  }

  static void loadRewardedInterstitialAd({
    required ValueChanged<RewardedInterstitialAd> onLoaded,
    required ValueChanged<String> onFailed,
  }) {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (error) => onFailed(error.message),
      ),
    );
  }
}
