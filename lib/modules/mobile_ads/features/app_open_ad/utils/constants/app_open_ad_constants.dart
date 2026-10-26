class AppOpenAdConstants {
  AppOpenAdConstants._();

  /// Google times out a loaded app-open ad after 4 hours, so an older one is
  /// reloaded instead of shown.
  static const Duration maxCacheDuration = Duration(hours: 4);
}
