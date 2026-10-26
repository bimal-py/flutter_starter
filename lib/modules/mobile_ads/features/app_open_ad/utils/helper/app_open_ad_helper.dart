import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/utils/utils.dart';

class AppOpenAdHelper {
  AppOpenAdHelper._();

  static String get adUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode
          ? EnvHelper.get('PROD_ANDROID_APP_OPEN_AD_UNIT_ID')
          : EnvHelper.get('DEV_ANDROID_APP_OPEN_AD_UNIT_ID');
    } else if (Platform.isIOS) {
      return kReleaseMode
          ? EnvHelper.get('PROD_IOS_APP_OPEN_AD_UNIT_ID')
          : EnvHelper.get('DEV_IOS_APP_OPEN_AD_UNIT_ID');
    } else {
      throw UnsupportedError(MobileAdsError.unsupportedPlatform);
    }
  }
}
