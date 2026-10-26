import 'package:flutter/widgets.dart';

@immutable
class AppFont {
  const AppFont({
    required this.family,
    this.scale = 1.0,
    this.fallback = const [],
  });

  /// Font family declared in pubspec.yaml fonts: section, OR null to use the
  /// platform default.
  final String? family;

  /// Multiplier applied to every fontSize in the TextTheme. Use to balance
  /// optically smaller scripts (Devanagari ≈ 1.10 next to Inter).
  final double scale;

  /// Families tried, in order, for characters [family] lacks: a Nepali
  /// product name in an English screen. Each must be bundled too.
  final List<String> fallback;
}

/// Per-locale font config. [AppThemeBuilder.compose] resolves the [AppFont]
/// for the app's locale and applies `family`, `scale` and `fallback` to every
/// Material text style.
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

  /// The two families bundled in pubspec.yaml: Inter, and NotoSansDevanagari
  /// for Nepali and Hindi. Another language needs its font under
  /// assets/fonts/, declared in pubspec.yaml, and an entry here.
  factory LocalizedFonts.defaults() => const LocalizedFonts(
    defaultFont: AppFont(family: 'Inter', fallback: ['NotoSansDevanagari']),
    byLocale: {
      // Devanagari reads ~10% smaller than Inter optically.
      'ne': AppFont(
        family: 'NotoSansDevanagari',
        scale: 1.10,
        fallback: ['Inter'],
      ),
      'hi': AppFont(
        family: 'NotoSansDevanagari',
        scale: 1.10,
        fallback: ['Inter'],
      ),
    },
  );
}
