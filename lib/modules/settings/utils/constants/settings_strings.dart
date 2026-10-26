import 'package:flutter_starter/core/core.dart';

class SettingsStrings {
  SettingsStrings._();

  // Settings tab.
  static const String title = 'Settings';
  static const String appCardTagline =
      'Tweak the look. Share, rate, or report.';
  static const String appearance = 'Appearance';
  static const String app = 'App';
  static const String shareAndFeedback = 'Share & feedback';
  static const String about = 'About';

  // Brightness picker.
  static const String themeSystem = 'System';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';

  // Customize theme tile.
  static const String customizeTheme = 'Customize theme';
  static const String themeDefault = "Using app's default";
  static const String themeCustomSeed = 'Custom seed color';
  static const String themeCustomPalette = 'Custom palette';
  static const String themeFullyCustom = 'Fully custom';
  static const String themeDeviceColors = 'Device wallpaper colors';
  static const String themeFromImage = 'Color extracted from image';

  // App tour.
  static const String replayOnboarding = 'Show app tour again';
  static const String replayOnboardingSubtitle = 'Replay the onboarding flow';

  // Share & feedback.
  static const String shareQr = 'Share app QR';
  static const String shareQrSubtitle =
      'Show a QR code others can scan to download';
  static const String rateApp = 'Rate the app';
  static const String reportProblem =
      'Report a problem (${AppConstants.appName})';
  static const String reportEmailSubject =
      'Report from user (${AppConstants.appName})';

  // About.
  static const String aboutApp = 'About app';
  static const String aboutAppSubtitle = 'What this app does and who built it';

  // Theme playground.
  static const String brightnessMode = 'Brightness mode';
  static const String presets = 'Presets';
  static const String source = 'Source';
  static const String preview = 'Preview';
  static const String usingCustomTheme = 'Using your custom theme';
  static const String usingDefaultTheme = "Using the app's default theme";
  static const String reset = 'Reset';
  static const String themeReset = 'Reset to default theme';
  static const String sourceSeed = 'Seed color';
  static const String sourceSeedSubtitle =
      'Pick a color; the app derives everything from it.';
  static const String sourceDevice = 'Dynamic device colors';
  static const String sourceDeviceSubtitle =
      'Use wallpaper colors (Android 12+).';
  static const String sourceImage = 'From image';
  static const String sourceImageSubtitle =
      'Pick a photo and seed from its dominant color.';
  static const String deviceColorsHint =
      'Active when wallpaper colors are available. Falls back to your last seed otherwise.';
  static const String picking = 'Picking…';
  static const String pickImage = 'Pick an image';
  static const String pickDifferentImage = 'Pick a different image';
  static const String imageHint =
      'Dominant color is extracted on a background isolate and applied app-wide.';
  static const String pickCustomColor = 'Pick a custom color';
  static const String apply = 'Apply';

  // Theme preview card.
  static const String previewPrimary = 'Primary';
  static const String previewTonal = 'Tonal';
  static const String previewOutline = 'Outline';
  static const String previewText = 'Text';
  static const String previewFieldLabel = 'Email';
  static const String previewFieldHint = 'you@example.com';
  static const String previewRowTitle = 'A preview row';
  static const String previewRowSubtitle =
      'Body text rendered with current theme';
}
