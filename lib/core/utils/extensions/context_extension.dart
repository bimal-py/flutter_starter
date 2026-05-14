import 'package:flutter/material.dart';
import 'package:flutter_starter/core/theme/extension/custom_theme_extension.dart';

extension BuildContextExtension on BuildContext {
  ScaffoldState get scaffold => Scaffold.of(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Domain colors that Material's [ColorScheme] doesn't ship (success /
  /// warning / info). For anything else, prefer [colorScheme].
  CustomThemeExtension get customTheme =>
      Theme.of(this).extension<CustomThemeExtension>()!;

  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}
