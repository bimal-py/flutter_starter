import 'package:flutter/material.dart';
import 'package:flutter_starter/core/theme/colors/brand_palette.dart';

/// Domain-specific colors not expressible via Material's [ColorScheme]. Fields
/// are split per-brightness so dark mode can supply different values. Reach
/// the extension with `Theme.of(context).extension<CustomThemeExtension>()!`.
@immutable
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  const CustomThemeExtension({
    // Status — Material 3 only ships error; the rest are app-domain.
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    // Brand accent
    required this.brandAccent,
    required this.brandAccentMuted,
    // Shimmer / loading
    required this.shimmerBase,
    required this.shimmerHighlight,
    // Inputs (distinct from card surfaces in many designs)
    required this.inputBackground,
    required this.inputBackgroundSubtle,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.inputBorderError,
    // Dialog / overlay
    required this.dialogBackground,
    required this.scrimSoft,
    // Borders beyond outline / outlineVariant
    required this.borderSubtle,
    required this.borderStrong,
    // Text nuance
    required this.textPlaceholder,
    required this.textDisabled,
    required this.textLink,
    // Interactive overlays
    required this.hoverOverlay,
    required this.pressedOverlay,
    required this.focusOverlay,
    required this.disabledSurface,
    // Ratings
    required this.ratingActive,
    required this.ratingInactive,
    // Gradient stops
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.bannerGradientStart,
    required this.bannerGradientEnd,
  });

  // ── Status ───────────────────────────────────────────────────────
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  // ── Brand ────────────────────────────────────────────────────────
  final Color brandAccent;
  final Color brandAccentMuted;

  // ── Shimmer ──────────────────────────────────────────────────────
  final Color shimmerBase;
  final Color shimmerHighlight;

  // ── Inputs ───────────────────────────────────────────────────────
  final Color inputBackground;
  final Color inputBackgroundSubtle;
  final Color inputBorder;
  final Color inputBorderFocused;
  final Color inputBorderError;

  // ── Dialog ───────────────────────────────────────────────────────
  final Color dialogBackground;
  final Color scrimSoft;

  // ── Borders ──────────────────────────────────────────────────────
  final Color borderSubtle;
  final Color borderStrong;

  // ── Text nuance ──────────────────────────────────────────────────
  final Color textPlaceholder;
  final Color textDisabled;
  final Color textLink;

  // ── Interactive overlays ─────────────────────────────────────────
  final Color hoverOverlay;
  final Color pressedOverlay;
  final Color focusOverlay;
  final Color disabledSurface;

  // ── Ratings ──────────────────────────────────────────────────────
  final Color ratingActive;
  final Color ratingInactive;

  // ── Gradient stops ───────────────────────────────────────────────
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color bannerGradientStart;
  final Color bannerGradientEnd;

  /// Sensible defaults derived from the supplied [scheme] so seed-only mode
  /// works without any per-field configuration. Status colors are picked from
  /// commonly-used fixed hues (harmonized to the scheme would be a future
  /// refinement); the rest derive from scheme surfaces and onSurface.
  factory CustomThemeExtension.lightDefault(
    ColorScheme scheme, {
    Color? brandAccent,
  }) {
    final accent = brandAccent ?? scheme.tertiary;
    return CustomThemeExtension(
      success: const Color(0xFF1B873B),
      onSuccess: Colors.white,
      successContainer: const Color(0xFFD3F5DE),
      onSuccessContainer: const Color(0xFF003910),
      warning: const Color(0xFFE5A100),
      onWarning: Colors.black,
      warningContainer: const Color(0xFFFFEDC2),
      onWarningContainer: const Color(0xFF3D2A00),
      info: const Color(0xFF1769FF),
      onInfo: Colors.white,
      infoContainer: const Color(0xFFD7E5FF),
      onInfoContainer: const Color(0xFF002C71),
      brandAccent: accent,
      brandAccentMuted: accent.withValues(alpha: 0.16),
      shimmerBase: scheme.surfaceContainerHighest,
      shimmerHighlight: scheme.surfaceContainerLow,
      inputBackground: scheme.surfaceContainerLow,
      inputBackgroundSubtle: scheme.surfaceContainer,
      inputBorder: scheme.outlineVariant,
      inputBorderFocused: scheme.primary,
      inputBorderError: scheme.error,
      dialogBackground: scheme.surfaceContainerHigh,
      scrimSoft: scheme.scrim.withValues(alpha: 0.25),
      borderSubtle: scheme.outlineVariant,
      borderStrong: scheme.outline,
      textPlaceholder: scheme.onSurfaceVariant.withValues(alpha: 0.55),
      textDisabled: scheme.onSurface.withValues(alpha: 0.38),
      textLink: scheme.primary,
      hoverOverlay: scheme.onSurface.withValues(alpha: 0.08),
      pressedOverlay: scheme.onSurface.withValues(alpha: 0.12),
      focusOverlay: scheme.primary.withValues(alpha: 0.12),
      disabledSurface: scheme.onSurface.withValues(alpha: 0.12),
      ratingActive: const Color(0xFFFEA500),
      ratingInactive: scheme.outlineVariant,
      heroGradientStart: scheme.primaryContainer,
      heroGradientEnd: scheme.tertiaryContainer,
      bannerGradientStart: scheme.secondaryContainer,
      bannerGradientEnd: scheme.surfaceContainer,
    );
  }

  factory CustomThemeExtension.darkDefault(
    ColorScheme scheme, {
    Color? brandAccent,
  }) {
    final accent = brandAccent ?? scheme.tertiary;
    return CustomThemeExtension(
      success: const Color(0xFF4ED27A),
      onSuccess: const Color(0xFF003910),
      successContainer: const Color(0xFF005321),
      onSuccessContainer: const Color(0xFFD3F5DE),
      warning: const Color(0xFFFFC74A),
      onWarning: const Color(0xFF3D2A00),
      warningContainer: const Color(0xFF5C3F00),
      onWarningContainer: const Color(0xFFFFEDC2),
      info: const Color(0xFF7AA7FF),
      onInfo: const Color(0xFF002C71),
      infoContainer: const Color(0xFF0046A0),
      onInfoContainer: const Color(0xFFD7E5FF),
      brandAccent: accent,
      brandAccentMuted: accent.withValues(alpha: 0.22),
      shimmerBase: scheme.surfaceContainerHigh,
      shimmerHighlight: scheme.surfaceContainerHighest,
      inputBackground: scheme.surfaceContainerLow,
      inputBackgroundSubtle: scheme.surfaceContainer,
      inputBorder: scheme.outlineVariant,
      inputBorderFocused: scheme.primary,
      inputBorderError: scheme.error,
      dialogBackground: scheme.surfaceContainerHigh,
      scrimSoft: scheme.scrim.withValues(alpha: 0.4),
      borderSubtle: scheme.outlineVariant,
      borderStrong: scheme.outline,
      textPlaceholder: scheme.onSurfaceVariant.withValues(alpha: 0.55),
      textDisabled: scheme.onSurface.withValues(alpha: 0.38),
      textLink: scheme.primary,
      hoverOverlay: scheme.onSurface.withValues(alpha: 0.08),
      pressedOverlay: scheme.onSurface.withValues(alpha: 0.12),
      focusOverlay: scheme.primary.withValues(alpha: 0.16),
      disabledSurface: scheme.onSurface.withValues(alpha: 0.12),
      ratingActive: const Color(0xFFFEA500),
      ratingInactive: scheme.outlineVariant,
      heroGradientStart: scheme.primaryContainer,
      heroGradientEnd: scheme.tertiaryContainer,
      bannerGradientStart: scheme.secondaryContainer,
      bannerGradientEnd: scheme.surfaceContainer,
    );
  }

  /// Builds a default extension from a [BrandPalette] for the given brightness,
  /// using the palette's harmonized accent as the brand accent.
  factory CustomThemeExtension.fromPalette(
    BrandPalette palette, {
    required Brightness brightness,
  }) {
    final scheme = brightness == Brightness.dark ? palette.dark : palette.light;
    final accent = palette.harmonizedAccent ?? scheme.tertiary;
    return brightness == Brightness.dark
        ? CustomThemeExtension.darkDefault(scheme, brandAccent: accent)
        : CustomThemeExtension.lightDefault(scheme, brandAccent: accent);
  }

  @override
  CustomThemeExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? brandAccent,
    Color? brandAccentMuted,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? inputBackground,
    Color? inputBackgroundSubtle,
    Color? inputBorder,
    Color? inputBorderFocused,
    Color? inputBorderError,
    Color? dialogBackground,
    Color? scrimSoft,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textPlaceholder,
    Color? textDisabled,
    Color? textLink,
    Color? hoverOverlay,
    Color? pressedOverlay,
    Color? focusOverlay,
    Color? disabledSurface,
    Color? ratingActive,
    Color? ratingInactive,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? bannerGradientStart,
    Color? bannerGradientEnd,
  }) =>
      CustomThemeExtension(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        successContainer: successContainer ?? this.successContainer,
        onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
        warning: warning ?? this.warning,
        onWarning: onWarning ?? this.onWarning,
        warningContainer: warningContainer ?? this.warningContainer,
        onWarningContainer: onWarningContainer ?? this.onWarningContainer,
        info: info ?? this.info,
        onInfo: onInfo ?? this.onInfo,
        infoContainer: infoContainer ?? this.infoContainer,
        onInfoContainer: onInfoContainer ?? this.onInfoContainer,
        brandAccent: brandAccent ?? this.brandAccent,
        brandAccentMuted: brandAccentMuted ?? this.brandAccentMuted,
        shimmerBase: shimmerBase ?? this.shimmerBase,
        shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
        inputBackground: inputBackground ?? this.inputBackground,
        inputBackgroundSubtle:
            inputBackgroundSubtle ?? this.inputBackgroundSubtle,
        inputBorder: inputBorder ?? this.inputBorder,
        inputBorderFocused: inputBorderFocused ?? this.inputBorderFocused,
        inputBorderError: inputBorderError ?? this.inputBorderError,
        dialogBackground: dialogBackground ?? this.dialogBackground,
        scrimSoft: scrimSoft ?? this.scrimSoft,
        borderSubtle: borderSubtle ?? this.borderSubtle,
        borderStrong: borderStrong ?? this.borderStrong,
        textPlaceholder: textPlaceholder ?? this.textPlaceholder,
        textDisabled: textDisabled ?? this.textDisabled,
        textLink: textLink ?? this.textLink,
        hoverOverlay: hoverOverlay ?? this.hoverOverlay,
        pressedOverlay: pressedOverlay ?? this.pressedOverlay,
        focusOverlay: focusOverlay ?? this.focusOverlay,
        disabledSurface: disabledSurface ?? this.disabledSurface,
        ratingActive: ratingActive ?? this.ratingActive,
        ratingInactive: ratingInactive ?? this.ratingInactive,
        heroGradientStart: heroGradientStart ?? this.heroGradientStart,
        heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
        bannerGradientStart: bannerGradientStart ?? this.bannerGradientStart,
        bannerGradientEnd: bannerGradientEnd ?? this.bannerGradientEnd,
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
      onSuccess: lerpColor(onSuccess, other.onSuccess),
      successContainer: lerpColor(successContainer, other.successContainer),
      onSuccessContainer: lerpColor(onSuccessContainer, other.onSuccessContainer),
      warning: lerpColor(warning, other.warning),
      onWarning: lerpColor(onWarning, other.onWarning),
      warningContainer: lerpColor(warningContainer, other.warningContainer),
      onWarningContainer: lerpColor(onWarningContainer, other.onWarningContainer),
      info: lerpColor(info, other.info),
      onInfo: lerpColor(onInfo, other.onInfo),
      infoContainer: lerpColor(infoContainer, other.infoContainer),
      onInfoContainer: lerpColor(onInfoContainer, other.onInfoContainer),
      brandAccent: lerpColor(brandAccent, other.brandAccent),
      brandAccentMuted: lerpColor(brandAccentMuted, other.brandAccentMuted),
      shimmerBase: lerpColor(shimmerBase, other.shimmerBase),
      shimmerHighlight: lerpColor(shimmerHighlight, other.shimmerHighlight),
      inputBackground: lerpColor(inputBackground, other.inputBackground),
      inputBackgroundSubtle:
          lerpColor(inputBackgroundSubtle, other.inputBackgroundSubtle),
      inputBorder: lerpColor(inputBorder, other.inputBorder),
      inputBorderFocused: lerpColor(inputBorderFocused, other.inputBorderFocused),
      inputBorderError: lerpColor(inputBorderError, other.inputBorderError),
      dialogBackground: lerpColor(dialogBackground, other.dialogBackground),
      scrimSoft: lerpColor(scrimSoft, other.scrimSoft),
      borderSubtle: lerpColor(borderSubtle, other.borderSubtle),
      borderStrong: lerpColor(borderStrong, other.borderStrong),
      textPlaceholder: lerpColor(textPlaceholder, other.textPlaceholder),
      textDisabled: lerpColor(textDisabled, other.textDisabled),
      textLink: lerpColor(textLink, other.textLink),
      hoverOverlay: lerpColor(hoverOverlay, other.hoverOverlay),
      pressedOverlay: lerpColor(pressedOverlay, other.pressedOverlay),
      focusOverlay: lerpColor(focusOverlay, other.focusOverlay),
      disabledSurface: lerpColor(disabledSurface, other.disabledSurface),
      ratingActive: lerpColor(ratingActive, other.ratingActive),
      ratingInactive: lerpColor(ratingInactive, other.ratingInactive),
      heroGradientStart: lerpColor(heroGradientStart, other.heroGradientStart),
      heroGradientEnd: lerpColor(heroGradientEnd, other.heroGradientEnd),
      bannerGradientStart: lerpColor(bannerGradientStart, other.bannerGradientStart),
      bannerGradientEnd: lerpColor(bannerGradientEnd, other.bannerGradientEnd),
    );
  }
}
