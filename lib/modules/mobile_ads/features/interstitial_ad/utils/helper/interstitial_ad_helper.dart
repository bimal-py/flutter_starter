import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/utils/utils.dart';

class InterstitialAdHelper {
  InterstitialAdHelper._();

  static String get adUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? EnvHelper.get('DEV_ANDROID_INTERSTITIAL_AD_UNIT_ID')
          : EnvHelper.get('PROD_ANDROID_INTERSTITIAL_AD_UNIT_ID');
    } else if (Platform.isIOS) {
      return kDebugMode
          ? EnvHelper.get('DEV_IOS_INTERSTITIAL_AD_UNIT_ID')
          : EnvHelper.get('PROD_IOS_INTERSTITIAL_AD_UNIT_ID');
    } else {
      throw UnsupportedError(MobileAdsError.unsupportedPlatform);
    }
  }
}
