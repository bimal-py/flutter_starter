import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_starter/core/theme/colors/app_colors.dart';
import 'package:flutter_starter/core/theme/colors/brand_palette.dart';
import 'package:flutter_starter/core/theme/component_themes/component_themes.dart';
import 'package:flutter_starter/core/theme/extension/custom_theme_extension.dart';
import 'package:flutter_starter/core/theme/typography/app_text_style.dart';

ThemeData buildLightTheme(BuildContext context) {
  final palette = BrandPalette(seed: AppColors.seed, accent: AppColors.accent);
  return _buildTheme(
    context: context,
    colorScheme: palette.light,
    extension: CustomThemeExtension.fromPalette(
      palette,
      brightness: Brightness.light,
    ),
  );
}

ThemeData buildDarkTheme(BuildContext context) {
  final palette = BrandPalette(seed: AppColors.seed, accent: AppColors.accent);
  return _buildTheme(
    context: context,
    colorScheme: palette.dark,
    extension: CustomThemeExtension.fromPalette(
      palette,
      brightness: Brightness.dark,
    ),
  );
}

ThemeData _buildTheme({
  required BuildContext context,
  required ColorScheme colorScheme,
  required CustomThemeExtension extension,
}) {
  // Build a base ThemeData WITHOUT a custom textTheme. This lets Material 3
  // bake the proper colorScheme-aware colors into the typography.
  // We then layer our font sizes on top, preserving those colors.
  final base = ResponsiveThemeData.create(
    context: context,
    useMaterial3: true,
    colorScheme: colorScheme,
  );
  final textTheme = AppTextStyle.applyTo(base.textTheme);
  final radius = BorderRadius.circular(12.r);

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    iconTheme: IconThemeData(size: 20.r, color: colorScheme.onSurface),
    appBarTheme: AppBarThemeBuilder.build(
      colorScheme: colorScheme,
      textTheme: textTheme,
    ),
    elevatedButtonTheme: ButtonThemes.elevated(
      colorScheme: colorScheme,
      textTheme: textTheme,
      radius: radius,
    ),
    filledButtonTheme: ButtonThemes.filled(
      colorScheme: colorScheme,
      textTheme: textTheme,
      radius: radius,
    ),
    outlinedButtonTheme: ButtonThemes.outlined(
      colorScheme: colorScheme,
      textTheme: textTheme,
      radius: radius,
    ),
    textButtonTheme: ButtonThemes.text(textTheme: textTheme),
    inputDecorationTheme: InputDecorationThemeBuilder.build(
      colorScheme: colorScheme,
      textTheme: textTheme,
      radius: radius,
    ),
    cardTheme: CardThemeBuilder.build(colorScheme: colorScheme),
    dividerTheme: DividerThemeBuilder.build(colorScheme: colorScheme),
    navigationBarTheme: NavigationBarThemeBuilder.build(
      colorScheme: colorScheme,
      textTheme: textTheme,
    ),
    snackBarTheme: SnackBarThemeBuilder.build(
      colorScheme: colorScheme,
      textTheme: textTheme,
      radius: radius,
    ),
    extensions: [extension],
  );
}
