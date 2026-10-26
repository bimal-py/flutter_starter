import 'package:flutter/painting.dart';

/// Fixed colours that must not follow the theme: cameras read dark modules on
/// white most reliably, so the code stays black on white in dark mode too.
class QrColors {
  QrColors._();

  static const Color codeBackground = Color(0xFFFFFFFF);
  static const Color codeForeground = Color(0xFF000000);
}
