/// Static external URLs used across the app — download links, marketing pages,
/// support contact, legal pages, social links.
///
/// For URLs that vary per environment (API base, auth callbacks), use
/// [ApiEndpoints] instead — those are read from `.env` at runtime.
class AppUrls {
  AppUrls._();

  // Distribution / marketing
  static const String appDownload = 'https://example.com/download';
  static const String website = 'https://example.com';

  // Legal
  static const String privacyPolicy = 'https://example.com/privacy';
  static const String termsOfService = 'https://example.com/terms';

  // Support
  static const String supportEmail = 'support@example.com';

  // Developer contact — shown on the About screen.
  static const String developerEmail = 'you@example.com';
  static const String developerGithub = 'https://github.com/your-handle';
  static const String developerWebsite = 'https://example.com';

  // Demo URL used by the starter's website-view example.
  static const String demoSite = 'https://flutter.dev';
}
