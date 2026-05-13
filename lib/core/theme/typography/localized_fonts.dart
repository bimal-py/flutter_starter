import 'package:flutter/widgets.dart';

@immutable
class AppFont {
  const AppFont({required this.family, this.scale = 1.0});

  /// Font family declared in pubspec.yaml fonts: section, OR null to use the
  /// platform default.
  final String? family;

  /// Multiplier applied to every fontSize in the TextTheme. Use to balance
  /// optically smaller scripts (e.g. Mukta ≈ 1.10 to match Inter).
  final double scale;
}

/// Per-locale font config. The active TextTheme builder reads the current
/// locale, resolves the [AppFont] for that language, and applies `family` +
/// `scale` to every Material text style.
@immutable
class LocalizedFonts {
  const LocalizedFonts({required this.defaultFont, this.byLocale = const {}});

  final AppFont defaultFont;

  /// Keyed by ISO 639-1 language code (`'ne'`, `'hi'`, `'ar'`, `'bn'`).
  final Map<String, AppFont> byLocale;

  AppFont resolve(Locale? locale) {
    final code = locale?.languageCode;
    if (code == null) return defaultFont;
    return byLocale[code] ?? defaultFont;
  }

  /// Pre-populated with sensible defaults — Inter as base + non-Latin pairings.
  /// Drop or extend in your app. Font files for non-default families must be
  /// declared in pubspec.yaml AND placed under assets/fonts/.
  factory LocalizedFonts.defaults() => const LocalizedFonts(
        defaultFont: AppFont(family: 'Inter', scale: 1.0),
        byLocale: {
          // Devanagari (Nepali, Hindi) reads ~10% smaller than Inter optically.
          'ne': AppFont(family: 'Mukta', scale: 1.10),
          'hi': AppFont(family: 'Mukta', scale: 1.10),
          'bn': AppFont(family: 'NotoSansBengali', scale: 1.08),
          'ar': AppFont(family: 'NotoSansArabic', scale: 1.05),
        },
      );
}
