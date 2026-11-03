import 'package:flutter/material.dart';
import 'package:flutter_starter/core/scale_size/scale_size.dart';

class ButtonThemes {
  ButtonThemes._();

  static ElevatedButtonThemeData elevated({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required BorderRadius radius,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Not Size.fromHeight: an infinite minimum width throws in a Row.
        // A stretched Column or a SizedBox makes a button full width.
        minimumSize: Size(64.w, 48.h),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static FilledButtonThemeData filled({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required BorderRadius radius,
  }) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        // Not Size.fromHeight: an infinite minimum width throws in a Row.
        // A stretched Column or a SizedBox makes a button full width.
        minimumSize: Size(64.w, 48.h),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static OutlinedButtonThemeData outlined({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required BorderRadius radius,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        // Not Size.fromHeight: an infinite minimum width throws in a Row.
        // A stretched Column or a SizedBox makes a button full width.
        minimumSize: Size(64.w, 48.h),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: textTheme.labelLarge,
        side: BorderSide(color: colorScheme.outline),
      ),
    );
  }

  static TextButtonThemeData text({required TextTheme textTheme}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
    );
  }
}
