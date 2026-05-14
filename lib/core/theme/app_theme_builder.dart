import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_starter/core/theme/colors/app_colors.dart';
import 'package:flutter_starter/core/theme/colors/brand_palette.dart';
import 'package:flutter_starter/core/theme/component_themes/component_themes.dart';
import 'package:flutter_starter/core/theme/extension/custom_theme_extension.dart';
import 'package:flutter_starter/core/theme/source/theme_source.dart';
import 'package:flutter_starter/core/theme/typography/app_text_style.dart';
import 'package:flutter_starter/core/theme/typography/localized_fonts.dart';

class ComposedThemes {
  const ComposedThemes({required this.light, required this.dark});
  final ThemeData light;
  final ThemeData dark;
}

/// Builds a [CustomThemeExtension] for an arbitrary [ColorScheme] +
/// brightness pair. Wire one of these into [ThemeCubit] when domain colors
/// (success/info gradients/etc.) need to follow whatever scheme is active —
/// including dynamic device colors, image-seeded schemes, and presets — instead
/// of being frozen at whatever the seed was when the app launched.
typedef ThemeExtensionBuilder = CustomThemeExtension Function(
  ColorScheme scheme,
  Brightness brightness,
);

/// Single composer that turns a [ThemeSource] (plus device schemes from
/// `DynamicColorBuilder` and the active locale) into a {light, dark} pair.
/// MaterialApp wiring lives in `lib/app/app.dart`.
class AppThemeBuilder {
  AppThemeBuilder._();

  static ComposedThemes compose({
    required BuildContext context,
    required ThemeSource source,
    ColorScheme? deviceLightScheme,
    ColorScheme? deviceDarkScheme,
    required LocalizedFonts fonts,
    ThemeExtensionBuilder? extensionBuilder,
  }) {
    final font = fonts.resolve(Localizations.maybeLocaleOf(context));

    switch (source) {
      case SeedOnlySource(:final seed, :final accent):
        final palette = BrandPalette(seed: seed, accent: accent);
        return ComposedThemes(
          light: _buildOne(
            context: context,
            scheme: palette.light,
            extension: _resolveExtension(
              scheme: palette.light,
              brightness: Brightness.light,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.fromPalette(
                palette,
                brightness: Brightness.light,
              ),
            ),
            font: font,
          ),
          dark: _buildOne(
            context: context,
            scheme: palette.dark,
            extension: _resolveExtension(
              scheme: palette.dark,
              brightness: Brightness.dark,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.fromPalette(
                palette,
                brightness: Brightness.dark,
              ),
            ),
            font: font,
          ),
        );

      case SeedWithOverridesSource(
          :final seed,
          :final accent,
          :final lightSchemeOverrides,
          :final darkSchemeOverrides,
        ):
        final palette = BrandPalette(seed: seed, accent: accent);
        final lightScheme =
            _applySchemeOverrides(palette.light, lightSchemeOverrides);
        final darkScheme =
            _applySchemeOverrides(palette.dark, darkSchemeOverrides);
        return ComposedThemes(
          light: _buildOne(
            context: context,
            scheme: lightScheme,
            extension: _resolveExtension(
              scheme: lightScheme,
              brightness: Brightness.light,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.lightDefault(
                lightScheme,
                brandAccent: palette.harmonizedAccent,
              ),
            ),
            font: font,
          ),
          dark: _buildOne(
            context: context,
            scheme: darkScheme,
            extension: _resolveExtension(
              scheme: darkScheme,
              brightness: Brightness.dark,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.darkDefault(
                darkScheme,
                brandAccent: palette.harmonizedAccent,
              ),
            ),
            font: font,
          ),
        );

      case FullCustomSource(
          :final lightScheme,
          :final darkScheme,
          :final lightExtension,
          :final darkExtension,
          :final textTheme,
          :final fontFamily,
        ):
        // Fill missing brightness by mirroring the supplied one.
        final l = lightScheme ?? darkScheme!;
        final d = darkScheme ?? lightScheme!;
        // Developer-supplied extensions on FullCustomSource win — those were
        // chosen deliberately. Otherwise fall back to the builder, then defaults.
        final lExt = lightExtension ??
            _resolveExtension(
              scheme: l,
              brightness: Brightness.light,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.lightDefault(l),
            );
        final dExt = darkExtension ??
            _resolveExtension(
              scheme: d,
              brightness: Brightness.dark,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.darkDefault(d),
            );
        final overrideFont =
            fontFamily != null ? AppFont(family: fontFamily) : font;
        return ComposedThemes(
          light: _buildOne(
            context: context,
            scheme: l,
            extension: lExt,
            font: overrideFont,
            overrideTextTheme: textTheme,
          ),
          dark: _buildOne(
            context: context,
            scheme: d,
            extension: dExt,
            font: overrideFont,
            overrideTextTheme: textTheme,
          ),
        );

      case DynamicDeviceSource(:final fallbackSeed):
        final palette = BrandPalette(seed: fallbackSeed);
        final l = deviceLightScheme ?? palette.light;
        final d = deviceDarkScheme ?? palette.dark;
        return ComposedThemes(
          light: _buildOne(
            context: context,
            scheme: l,
            extension: _resolveExtension(
              scheme: l,
              brightness: Brightness.light,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.lightDefault(l),
            ),
            font: font,
          ),
          dark: _buildOne(
            context: context,
            scheme: d,
            extension: _resolveExtension(
              scheme: d,
              brightness: Brightness.dark,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.darkDefault(d),
            ),
            font: font,
          ),
        );

      case FromImageSource(:final fallbackSeed):
        // Image extraction is async; the cubit replaces this source with a
        // SeedOnlySource once the dominant color is resolved. Until then,
        // render with the fallback seed.
        final palette = BrandPalette(seed: fallbackSeed);
        return ComposedThemes(
          light: _buildOne(
            context: context,
            scheme: palette.light,
            extension: _resolveExtension(
              scheme: palette.light,
              brightness: Brightness.light,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.fromPalette(
                palette,
                brightness: Brightness.light,
              ),
            ),
            font: font,
          ),
          dark: _buildOne(
            context: context,
            scheme: palette.dark,
            extension: _resolveExtension(
              scheme: palette.dark,
              brightness: Brightness.dark,
              builder: extensionBuilder,
              fallback: () => CustomThemeExtension.fromPalette(
                palette,
                brightness: Brightness.dark,
              ),
            ),
            font: font,
          ),
        );
    }
  }

  /// Routes extension construction through the developer's [builder] when
  /// supplied; otherwise builds the source-specific default. Centralising this
  /// is what lets a developer-customised extension follow *any* scheme — seed,
  /// preset, dynamic, image-derived — instead of being frozen at app start.
  static CustomThemeExtension _resolveExtension({
    required ColorScheme scheme,
    required Brightness brightness,
    required CustomThemeExtension Function() fallback,
    ThemeExtensionBuilder? builder,
  }) {
    if (builder != null) return builder(scheme, brightness);
    return fallback();
  }

  /// Defaults used when no source has been wired yet.
  static ComposedThemes defaults(BuildContext context) => compose(
        context: context,
        source: const SeedOnlySource(
          seed: AppColors.seed,
          accent: AppColors.accent,
        ),
        fonts: LocalizedFonts.defaults(),
      );

  static ThemeData _buildOne({
    required BuildContext context,
    required ColorScheme scheme,
    required CustomThemeExtension extension,
    required AppFont font,
    TextTheme? overrideTextTheme,
  }) {
    final base = ResponsiveThemeData.create(
      context: context,
      useMaterial3: true,
      colorScheme: scheme,
    );
    final textTheme = overrideTextTheme != null
        ? AppTextStyle.applyTo(overrideTextTheme, font: font)
        : AppTextStyle.applyTo(base.textTheme, font: font);
    final radius = BorderRadius.circular(12.r);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      iconTheme: IconThemeData(size: 20.r, color: scheme.onSurface),
      appBarTheme: AppBarThemeBuilder.build(
        colorScheme: scheme,
        textTheme: textTheme,
      ),
      elevatedButtonTheme: ButtonThemes.elevated(
        colorScheme: scheme,
        textTheme: textTheme,
        radius: radius,
      ),
      filledButtonTheme: ButtonThemes.filled(
        colorScheme: scheme,
        textTheme: textTheme,
        radius: radius,
      ),
      outlinedButtonTheme: ButtonThemes.outlined(
        colorScheme: scheme,
        textTheme: textTheme,
        radius: radius,
      ),
      textButtonTheme: ButtonThemes.text(textTheme: textTheme),
      inputDecorationTheme: InputDecorationThemeBuilder.build(
        colorScheme: scheme,
        textTheme: textTheme,
        radius: radius,
      ),
      cardTheme: CardThemeBuilder.build(colorScheme: scheme),
      dividerTheme: DividerThemeBuilder.build(colorScheme: scheme),
      navigationBarTheme: NavigationBarThemeBuilder.build(
        colorScheme: scheme,
        textTheme: textTheme,
      ),
      snackBarTheme: SnackBarThemeBuilder.build(
        colorScheme: scheme,
        textTheme: textTheme,
        radius: radius,
      ),
      extensions: [extension],
    );
  }

  static ColorScheme _applySchemeOverrides(
    ColorScheme base,
    Map<String, Color> overrides,
  ) {
    if (overrides.isEmpty) return base;
    return base.copyWith(
      primary: overrides['primary'],
      onPrimary: overrides['onPrimary'],
      primaryContainer: overrides['primaryContainer'],
      onPrimaryContainer: overrides['onPrimaryContainer'],
      secondary: overrides['secondary'],
      onSecondary: overrides['onSecondary'],
      secondaryContainer: overrides['secondaryContainer'],
      onSecondaryContainer: overrides['onSecondaryContainer'],
      tertiary: overrides['tertiary'],
      onTertiary: overrides['onTertiary'],
      tertiaryContainer: overrides['tertiaryContainer'],
      onTertiaryContainer: overrides['onTertiaryContainer'],
      error: overrides['error'],
      onError: overrides['onError'],
      errorContainer: overrides['errorContainer'],
      onErrorContainer: overrides['onErrorContainer'],
      surface: overrides['surface'],
      onSurface: overrides['onSurface'],
      surfaceContainer: overrides['surfaceContainer'],
      surfaceContainerLow: overrides['surfaceContainerLow'],
      surfaceContainerLowest: overrides['surfaceContainerLowest'],
      surfaceContainerHigh: overrides['surfaceContainerHigh'],
      surfaceContainerHighest: overrides['surfaceContainerHighest'],
      onSurfaceVariant: overrides['onSurfaceVariant'],
      outline: overrides['outline'],
      outlineVariant: overrides['outlineVariant'],
      shadow: overrides['shadow'],
      scrim: overrides['scrim'],
      inverseSurface: overrides['inverseSurface'],
      onInverseSurface: overrides['onInverseSurface'],
      inversePrimary: overrides['inversePrimary'],
      surfaceTint: overrides['surfaceTint'],
    );
  }
}
