import 'package:flutter/foundation.dart';

/// Whether ads show anywhere in the app. Nothing in this module reads it, so
/// gate every ad slot and `showAd` call on [shouldShow].
class AdsController extends ChangeNotifier {
  AdsController._();

  static final AdsController instance = AdsController._();

  bool _enabled = true;

  /// Kill switch for every ad that isn't forced (remote config, a debug
  /// toggle, an emergency off).
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }

  /// True while the user holds a "no ads" entitlement (a subscription, a
  /// lifetime unlock, an ad-free window). Add the source here and call
  /// [notifyListeners] from this class when it changes, so every gated slot
  /// updates at once.
  bool get adsRemoved => false;

  /// [forceShow] skips the kill switch and the entitlements, for rewarded ads
  /// that unlock a feature: a subscription must not take those away.
  bool shouldShow({bool forceShow = false}) {
    if (forceShow) return true;
    return _enabled && !adsRemoved;
  }
}
