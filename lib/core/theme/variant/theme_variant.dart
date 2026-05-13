import 'package:flutter/material.dart';

/// User-visible "mode" the theme renders in. Extensible — `ThemeVariant.custom`
/// lets apps declare additional variants (e.g. AMOLED, high-contrast) without
/// rebuilding the cubit. V1 UI exposes only light/dark/system.
sealed class ThemeVariant {
  const ThemeVariant();

  /// Stable string for persistence. Built-ins use 'light'/'dark'/'system';
  /// custom variants use `custom:<name>`.
  String get id;

  /// Maps to Flutter's [ThemeMode] when MaterialApp needs one. Custom variants
  /// pick a brightness via their declared [brightnessOrSystem].
  ThemeMode toThemeMode();

  static const ThemeVariant light = _Light();
  static const ThemeVariant dark = _Dark();
  static const ThemeVariant system = _System();

  /// Open-ended escape hatch. The string [name] round-trips through
  /// persistence; map it to a ColorScheme adjustment at the source layer.
  const factory ThemeVariant.custom(String name, {Brightness brightness}) =
      _Custom;

  static ThemeVariant fromId(String? id) {
    if (id == null) return system;
    if (id == 'light') return light;
    if (id == 'dark') return dark;
    if (id == 'system') return system;
    if (id.startsWith('custom:')) {
      return _Custom(id.substring('custom:'.length));
    }
    return system;
  }
}

class _Light extends ThemeVariant {
  const _Light();
  @override
  String get id => 'light';
  @override
  ThemeMode toThemeMode() => ThemeMode.light;
}

class _Dark extends ThemeVariant {
  const _Dark();
  @override
  String get id => 'dark';
  @override
  ThemeMode toThemeMode() => ThemeMode.dark;
}

class _System extends ThemeVariant {
  const _System();
  @override
  String get id => 'system';
  @override
  ThemeMode toThemeMode() => ThemeMode.system;
}

class _Custom extends ThemeVariant {
  const _Custom(this.name, {this.brightness = Brightness.light});
  final String name;
  final Brightness brightness;
  @override
  String get id => 'custom:$name';
  @override
  ThemeMode toThemeMode() =>
      brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
}
