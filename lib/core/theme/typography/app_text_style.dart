import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_starter/core/theme/typography/localized_fonts.dart';

/// Applies responsive font sizes / weights / line heights **on top of** an
/// existing Material 3 [TextTheme] and optionally swaps in [AppFont]'s family
/// + per-locale scale. Preserves Material's baked-in colors.
class AppTextStyle {
  AppTextStyle._();

  static TextTheme applyTo(TextTheme base, {AppFont? font}) {
    final family = font?.family;
    final scale = font?.scale ?? 1.0;
    double s(double size) => size * scale;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: family,
        fontSize: s(36).spClamp(s(28), s(40)),
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: family,
        fontSize: s(30).spClamp(s(24), s(34)),
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: family,
        fontSize: s(24).spClamp(s(20), s(28)),
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: family,
        fontSize: s(22).spClamp(s(20), s(26)),
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: family,
        fontSize: s(20).spClamp(s(18), s(22)),
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: family,
        fontSize: s(18).spClamp(s(16), s(20)),
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: family,
        fontSize: s(18).spClamp(s(16), s(20)),
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: family,
        fontSize: s(16).spClamp(s(14), s(18)),
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: family,
        fontSize: s(14).spClamp(s(12), s(16)),
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: family,
        fontSize: s(16).spClamp(s(14), s(18)),
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: family,
        fontSize: s(14).spClamp(s(12), s(16)),
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: family,
        fontSize: s(12).spClamp(s(11), s(14)),
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: family,
        fontSize: s(14).spClamp(s(12), s(16)),
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: family,
        fontSize: s(12).spClamp(s(11), s(14)),
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: family,
        fontSize: s(11).spClamp(s(10), s(13)),
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}
