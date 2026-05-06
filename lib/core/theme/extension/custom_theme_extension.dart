import 'package:flutter/material.dart';
import 'package:flutter_starter/core/theme/colors/brand_palette.dart';

/// Holds **domain-specific** colors that are not expressible in Material's
/// [ColorScheme]. Add fields here only when a new visual concept appears
/// (e.g. `shimmerBaseColor`, `successSurface`, `brandAccentMuted`).
///
/// Primary theming flows through [ColorScheme]. Reach for this extension via:
///
/// ```dart
/// final brand = Theme.of(context).extension<CustomThemeExtension>()!;
/// ```
@immutable
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  const CustomThemeExtension({
    required this.brandAccent,
    required this.brandAccentMuted,
  });

  /// Brand accent color, harmonized to the seed via [BrandPalette]. Use for
  /// highlights, premium chips, hero halos.
  final Color brandAccent;

  /// Translucent variant of [brandAccent] — for halos and subtle fills.
  final Color brandAccentMuted;

  /// Builds the extension from a [BrandPalette]. The accent is harmonized
  /// to the seed automatically; falls back to the scheme's tertiary when no
  /// accent was supplied to the palette.
  factory CustomThemeExtension.fromPalette(
    BrandPalette palette, {
    required Brightness brightness,
  }) {
    final scheme = brightness == Brightness.dark ? palette.dark : palette.light;
    final accent = palette.harmonizedAccent ?? scheme.tertiary;
    return CustomThemeExtension(
      brandAccent: accent,
      brandAccentMuted: accent.withValues(alpha: 0.16),
    );
  }

  @override
  CustomThemeExtension copyWith({
    Color? brandAccent,
    Color? brandAccentMuted,
  }) {
    return CustomThemeExtension(
      brandAccent: brandAccent ?? this.brandAccent,
      brandAccentMuted: brandAccentMuted ?? this.brandAccentMuted,
    );
  }

  @override
  CustomThemeExtension lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) return this;
    return CustomThemeExtension(
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      brandAccentMuted:
          Color.lerp(brandAccentMuted, other.brandAccentMuted, t)!,
    );
  }
}
