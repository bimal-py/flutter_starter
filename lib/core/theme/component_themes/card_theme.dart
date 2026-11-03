import 'package:flutter/material.dart';
import 'package:flutter_starter/core/scale_size/scale_size.dart';

class CardThemeBuilder {
  CardThemeBuilder._();

  static CardThemeData build({required ColorScheme colorScheme}) {
    return CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      margin: EdgeInsets.zero,
    );
  }
}
