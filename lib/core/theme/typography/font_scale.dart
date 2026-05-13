import 'package:flutter_starter/core/theme/typography/localized_fonts.dart';

/// Deprecated. Use [LocalizedFonts] — the theme now bakes per-locale family
/// and scale into the `TextTheme` automatically, so call sites that read
/// `AppTextScale.of` no longer need to.
@Deprecated('Use LocalizedFonts. AppTextScale will be removed in v2.')
class AppTextScale {
  AppTextScale._();

  static double of(String? languageCode) {
    if (languageCode == null) return 1.0;
    return LocalizedFonts.defaults().byLocale[languageCode]?.scale ?? 1.0;
  }
}
