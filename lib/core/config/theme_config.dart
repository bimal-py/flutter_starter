import 'package:flutter/material.dart';
import 'package:flutter_starter/core/theme/dark_theme.dart';
import 'package:flutter_starter/core/theme/light_theme.dart';

/// Thin entry point. The actual `ThemeData` is built in
/// `core/theme/light_theme.dart` and `core/theme/dark_theme.dart`, which
/// compose component themes from `core/theme/component_themes/`.
class ThemeConfigs {
  ThemeConfigs._();

  static ThemeData lightTheme({required BuildContext context}) =>
      buildLightTheme(context);

  static ThemeData darkTheme({required BuildContext context}) =>
      buildDarkTheme(context);
}
