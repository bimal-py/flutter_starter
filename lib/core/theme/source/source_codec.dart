import 'package:flutter_starter/core/theme/source/source.dart';

/// Rebuilds a [ThemeSource] from its persisted JSON shape. Returns null for
/// a kind that can't be rebuilt (a [FullCustomSource] saves only its kind)
/// and for corrupt input, so the developer source takes over.
ThemeSource? themeSourceFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return switch (json['kind']) {
    'seedOnly' => SeedOnlySource.fromJson(json),
    'seedWithOverrides' => SeedWithOverridesSource.fromJson(json),
    'dynamicDevice' => DynamicDeviceSource.fromJson(json),
    'fromImage' => FromImageSource.fromJson(json),
    _ => null,
  };
}
