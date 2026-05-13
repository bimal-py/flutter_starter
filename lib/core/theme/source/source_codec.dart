import 'package:flutter_starter/core/theme/colors/app_colors.dart';
import 'package:flutter_starter/core/theme/source/theme_source.dart';

/// Rebuilds a [ThemeSource] from its persisted JSON shape. Defaults to a
/// seed-only source on unknown/corrupt input so the app still themes.
ThemeSource themeSourceFromJson(Map<String, dynamic>? json) {
  if (json == null) return _defaultSource;
  return switch (json['kind']) {
    'seedOnly' => SeedOnlySource.fromJson(json),
    'seedWithOverrides' => SeedWithOverridesSource.fromJson(json),
    'dynamicDevice' => DynamicDeviceSource.fromJson(json),
    'fromImage' => FromImageSource.fromJson(json) ?? _defaultSource,
    // FullCustom isn't round-trippable in v1 — caller's developerSource takes over.
    _ => _defaultSource,
  };
}

const ThemeSource _defaultSource =
    SeedOnlySource(seed: AppColors.seed, accent: AppColors.accent);
