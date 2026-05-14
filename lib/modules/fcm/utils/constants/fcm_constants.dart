/// Constants used across the FCM module. Keep keys / defaults here so any
/// rename is one file's work.
class FcmConstants {
  FcmConstants._();

  /// Topics subscribed automatically on app launch. Override by passing
  /// `defaultTopics: …` to `FcmService.instance.initialize(...)`; pass an
  /// empty list to opt out of all auto-subscriptions.
  static const List<String> defaultTopics = ['app_update', 'promotions'];
}
