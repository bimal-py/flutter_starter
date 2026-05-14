import 'package:flutter/material.dart';
import 'package:flutter_starter/core/theme/source/theme_source.dart';

/// A named, brand-style starting point for theming (Christmas, Ocean, …).
/// Wrapping a [ThemeSource] keeps the rest of the system unchanged — the
/// playground just calls `cubit.setUserSource(preset.source)` and the
/// existing pipeline does the work. Light/Dark still toggles on top.
@immutable
class ThemePreset {
  const ThemePreset({
    required this.id,
    required this.label,
    required this.source,
    required this.swatch,
  });

  final String id;
  final String label;

  /// The actual source applied when the preset is picked.
  final ThemeSource source;

  /// The single color shown in the picker grid. Usually matches the seed,
  /// but kept separate so a [FullCustomSource] preset can still surface a chip.
  final Color swatch;
}

/// Static registry of available presets. The default list ships a handful of
/// recognisable seasonal/brand looks; apps swap it for their own collection
/// by calling [ThemePresets.register] from `main()` before building MaterialApp.
class ThemePresets {
  ThemePresets._();

  static List<ThemePreset> _presets = const [
    ThemePreset(
      id: 'christmas',
      label: 'Christmas',
      swatch: Color(0xFFC8102E),
      source: SeedOnlySource(seed: Color(0xFFC8102E), accent: Color(0xFF0F8A3D)),
    ),
    ThemePreset(
      id: 'ocean',
      label: 'Ocean',
      swatch: Color(0xFF006BA6),
      source: SeedOnlySource(seed: Color(0xFF006BA6), accent: Color(0xFF26C6DA)),
    ),
    ThemePreset(
      id: 'sunset',
      label: 'Sunset',
      swatch: Color(0xFFEF6C00),
      source: SeedOnlySource(seed: Color(0xFFEF6C00), accent: Color(0xFFD81B60)),
    ),
    ThemePreset(
      id: 'forest',
      label: 'Forest',
      swatch: Color(0xFF2E7D32),
      source: SeedOnlySource(seed: Color(0xFF2E7D32), accent: Color(0xFF8D6E63)),
    ),
    ThemePreset(
      id: 'lavender',
      label: 'Lavender',
      swatch: Color(0xFF7E57C2),
      source: SeedOnlySource(seed: Color(0xFF7E57C2), accent: Color(0xFFEC407A)),
    ),
    ThemePreset(
      id: 'midnight',
      label: 'Midnight',
      swatch: Color(0xFF1B3A6B),
      source: SeedOnlySource(seed: Color(0xFF1B3A6B), accent: Color(0xFFC8A96B)),
    ),
  ];

  static List<ThemePreset> get all => List.unmodifiable(_presets);

  static ThemePreset? byId(String id) {
    for (final p in _presets) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Replace the preset list. Call before MaterialApp builds so the playground
  /// surfaces your branded set instead of the defaults.
  static void register(List<ThemePreset> presets) {
    _presets = List.of(presets);
  }
}
