/// Static external URLs used across the app — download links, marketing pages,
/// support contact, legal pages, social links.
///
/// For URLs that vary per environment (API base, auth callbacks), use
/// [ApiEndpoints] instead — those are read from `.env` at runtime.
class AppUrls {
  AppUrls._();

  // Distribution / marketing
  static const String appDownload = 'https://example.com/download';
  static const String website = 'https://bimalkhatri.com.np';

  // Legal
  static const String privacyPolicy =
      'https://bimalkhatri.com.np/callbreak-score-tracker/privacy-policy';
  static const String termsOfService =
      'https://bimalkhatri.com.np/callbreak-score-tracker/terms-and-conditions';

  // Support
  static const String supportEmail = 'support@example.com';

  // Developer contact — shown on the About screen.
  static const String developerEmail = 'you@example.com';
  static const String developerGithub = 'https://github.com/bimal-py';
  static const String developerWebsite = 'https://bimalkhatri.com.np';

  // Demo URL used by the starter's website-view example.
  static const String demoSite = 'https://bimalkhatri.com.np';
}
