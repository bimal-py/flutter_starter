import 'package:flutter/material.dart';

/// Domain-specific colors that Material 3's [ColorScheme] doesn't ship.
///
/// Keep this file lean. Only add a field for a semantic color whose meaning
/// genuinely isn't already modelled by `ColorScheme` (which covers primary /
/// secondary / tertiary / error / surface variants and their `on*`/`container`
/// roles). Everything brand-accent-like should come from
/// `colorScheme.tertiary` + `colorScheme.tertiaryContainer`; everything
/// surface-like from the `surface*` family.
///
/// Access via [BuildContext.customTheme]:
///
/// ```dart
/// Icon(Icons.check, color: context.customTheme.success);
/// ```
@immutable
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  const CustomThemeExtension({
    required this.success,
    required this.warning,
    required this.info,
  });

  /// Status colors. Material 3 only ships `error`; these fill in the rest.
  final Color success;
  final Color warning;
  final Color info;

  factory CustomThemeExtension.lightDefault() => const CustomThemeExtension(
        success: Color(0xFF1B873B),
        warning: Color(0xFFE5A100),
        info: Color(0xFF1769FF),
      );

  factory CustomThemeExtension.darkDefault() => const CustomThemeExtension(
        success: Color(0xFF4ED27A),
        warning: Color(0xFFFFC74A),
        info: Color(0xFF7AA7FF),
      );

  @override
  CustomThemeExtension copyWith({
    Color? success,
    Color? warning,
    Color? info,
  }) => CustomThemeExtension(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.info,
      );

  @override
  CustomThemeExtension lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return CustomThemeExtension(
      success: lerpColor(success, other.success),
      warning: lerpColor(warning, other.warning),
      info: lerpColor(info, other.info),
    );
  }
}
