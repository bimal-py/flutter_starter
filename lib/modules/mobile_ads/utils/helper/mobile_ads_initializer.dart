import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Starts the Mobile Ads SDK once. Consent comes first so the SDK starts with
/// the user's choice on record: the UMP form (EU users), then the iOS ATT
/// prompt if UMP didn't show it, then `MobileAds.instance.initialize()`.
///
/// `app_tracking_transparency` is imported only here, so it leaves with the
/// module.
class MobileAdsInitializer {
  MobileAdsInitializer._();

  static final MobileAdsInitializer instance = MobileAdsInitializer._();

  bool _initialized = false;

  /// Call after the first frame: the consent form and the ATT prompt are
  /// dropped while the app isn't active. Errors are swallowed (the app runs
  /// without ads) and leave it uninitialised, so a later call tries again.
  Future<void> init() async {
    if (_initialized) return;
    try {
      await _gatherConsent();
      await _requestTrackingAuthorization();
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (_) {
      // The app works without ads.
    }
  }

  /// Always completes: on an error the consent already on record is kept, so
  /// ads aren't blocked. With an IDFA explainer message published in AdMob,
  /// this step also shows the ATT prompt.
  Future<void> _gatherConsent() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) {
        if (!completer.isCompleted) completer.complete();
      }),
      (FormError _) {
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  /// Asks only while the status is "not determined"; off iOS and below iOS 14
  /// it does nothing. The short pause lets the consent form finish closing,
  /// as the plugin advises for a dialog shown just before.
  Future<void> _requestTrackingAuthorization() async {
    if (!Platform.isIOS) return;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (_) {
      // No ATT: ads stay non-personalised.
    }
  }
}
