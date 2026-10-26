import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdHelper {
  RewardedAdHelper._();

  static String get adUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? EnvHelper.get('DEV_ANDROID_REWARDED_AD_UNIT_ID')
          : EnvHelper.get('PROD_ANDROID_REWARDED_AD_UNIT_ID');
    } else if (Platform.isIOS) {
      return kDebugMode
          ? EnvHelper.get('DEV_IOS_REWARDED_AD_UNIT_ID')
          : EnvHelper.get('PROD_IOS_REWARDED_AD_UNIT_ID');
    } else {
      throw UnsupportedError(MobileAdsError.unsupportedPlatform);
    }
  }

  static void loadRewardedAd({
    required ValueChanged<RewardedAd> onLoaded,
    required ValueChanged<String> onFailed,
  }) {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (error) => onFailed(error.message),
      ),
    );
  }
}
