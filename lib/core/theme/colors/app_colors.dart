import 'package:flutter/material.dart';

/// Brand colors for this app. Replace these with your own.
///
/// `seed` drives the entire Material 3 [ColorScheme] (via [BrandPalette] in
/// `theme_config.dart`). `accent` is harmonized to the seed and surfaced
/// through [CustomThemeExtension] for places where Material's `ColorScheme`
/// roles aren't enough.
class AppColors {
  AppColors._();

  /// Primary brand color → seeds the Material 3 tonal palette.
  static const Color seed = Color(0xFF1B3A6B);

  /// Secondary brand color (warm gold). Harmonized to [seed] before use, so
  /// the two read as belonging to the same family.
  static const Color accent = Color(0xFFC8A96B);
}
