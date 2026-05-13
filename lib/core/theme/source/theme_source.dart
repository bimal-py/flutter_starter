import 'package:flutter/material.dart';
import 'package:flutter_starter/core/theme/extension/custom_theme_extension.dart';

/// Brightness modes a [ThemeSource] is willing to render in.
enum SupportedBrightness { light, dark, both }

/// Reference to an image bytes can be resolved from. Persisted as a kind+ref
/// pair so the cubit re-extracts on rehydrate without storing pixel data.
sealed class ImageRef {
  const ImageRef();
  String get kind;
  Map<String, dynamic> toJson();

  static ImageRef? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    return switch (j['kind']) {
      'file' => FileImageRef(j['path'] as String),
      'network' => NetworkImageRef(j['url'] as String),
      'asset' => AssetImageRef(j['name'] as String),
      _ => null,
    };
  }
}

class FileImageRef extends ImageRef {
  const FileImageRef(this.path);
  final String path;
  @override
  String get kind => 'file';
  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'path': path};
}

class NetworkImageRef extends ImageRef {
  const NetworkImageRef(this.url);
  final String url;
  @override
  String get kind => 'network';
  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'url': url};
}

class AssetImageRef extends ImageRef {
  const AssetImageRef(this.name);
  final String name;
  @override
  String get kind => 'asset';
  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'name': name};
}

/// What the developer (or end user via playground) configures. The cubit
/// reduces this to a {light, dark} ThemeData pair via AppThemeBuilder.compose.
sealed class ThemeSource {
  const ThemeSource();

  String get kind;
  SupportedBrightness get supports;
  Map<String, dynamic> toJson();

  bool supportsVariant(Brightness target) => switch (supports) {
        SupportedBrightness.both => true,
        SupportedBrightness.light => target == Brightness.light,
        SupportedBrightness.dark => target == Brightness.dark,
      };
}

// ── 1. Seed-only ─────────────────────────────────────────────────────

class SeedOnlySource extends ThemeSource {
  const SeedOnlySource({required this.seed, this.accent});

  final Color seed;
  final Color? accent;

  @override
  String get kind => 'seedOnly';
  @override
  SupportedBrightness get supports => SupportedBrightness.both;
  @override
  Map<String, dynamic> toJson() => {
        'kind': kind,
        'seed': seed.toARGB32(),
        if (accent != null) 'accent': accent!.toARGB32(),
      };

  static SeedOnlySource fromJson(Map<String, dynamic> j) => SeedOnlySource(
        seed: Color(j['seed'] as int),
        accent: j['accent'] is int ? Color(j['accent'] as int) : null,
      );
}

// ── 2. Seed + per-role overrides ─────────────────────────────────────

class SeedWithOverridesSource extends ThemeSource {
  const SeedWithOverridesSource({
    required this.seed,
    this.accent,
    this.lightSchemeOverrides = const {},
    this.darkSchemeOverrides = const {},
  });

  final Color seed;
  final Color? accent;
  final Map<String, Color> lightSchemeOverrides;
  final Map<String, Color> darkSchemeOverrides;

  @override
  String get kind => 'seedWithOverrides';
  @override
  SupportedBrightness get supports => SupportedBrightness.both;
  @override
  Map<String, dynamic> toJson() => {
        'kind': kind,
        'seed': seed.toARGB32(),
        if (accent != null) 'accent': accent!.toARGB32(),
        'lightSchemeOverrides': _encodeColors(lightSchemeOverrides),
        'darkSchemeOverrides': _encodeColors(darkSchemeOverrides),
      };

  static SeedWithOverridesSource fromJson(Map<String, dynamic> j) =>
      SeedWithOverridesSource(
        seed: Color(j['seed'] as int),
        accent: j['accent'] is int ? Color(j['accent'] as int) : null,
        lightSchemeOverrides: _decodeColors(j['lightSchemeOverrides']),
        darkSchemeOverrides: _decodeColors(j['darkSchemeOverrides']),
      );
}

// ── 3. Full developer-defined ────────────────────────────────────────

class FullCustomSource extends ThemeSource {
  const FullCustomSource({
    this.lightScheme,
    this.darkScheme,
    this.lightExtension,
    this.darkExtension,
    this.textTheme,
    this.fontFamily,
  }) : assert(
          lightScheme != null || darkScheme != null,
          'FullCustomSource needs at least one brightness',
        );

  final ColorScheme? lightScheme;
  final ColorScheme? darkScheme;
  final CustomThemeExtension? lightExtension;
  final CustomThemeExtension? darkExtension;
  final TextTheme? textTheme;
  final String? fontFamily;

  static FullCustomSourceBuilder builder() => FullCustomSourceBuilder();

  @override
  String get kind => 'fullCustom';

  @override
  SupportedBrightness get supports {
    if (lightScheme != null && darkScheme != null) {
      return SupportedBrightness.both;
    }
    if (lightScheme != null) return SupportedBrightness.light;
    return SupportedBrightness.dark;
  }

  /// FullCustom is not round-trippable through JSON in v1 — schemes contain
  /// 30+ colors and TextTheme is even harder. We persist only enough to
  /// recognize it on rehydrate; on cold start the cubit falls back to the
  /// developer's wired source if userOverride was FullCustom.
  @override
  Map<String, dynamic> toJson() => {'kind': kind};
}

class FullCustomSourceBuilder {
  ColorScheme? _light;
  ColorScheme? _dark;
  CustomThemeExtension? _lightExt;
  CustomThemeExtension? _darkExt;
  TextTheme? _textTheme;
  String? _fontFamily;

  FullCustomSourceBuilder withLight({
    required ColorScheme scheme,
    CustomThemeExtension? extension,
  }) {
    _light = scheme;
    _lightExt = extension;
    return this;
  }

  FullCustomSourceBuilder withDark({
    required ColorScheme scheme,
    CustomThemeExtension? extension,
  }) {
    _dark = scheme;
    _darkExt = extension;
    return this;
  }

  FullCustomSourceBuilder withTextTheme(TextTheme tt) {
    _textTheme = tt;
    return this;
  }

  FullCustomSourceBuilder withFontFamily(String family) {
    _fontFamily = family;
    return this;
  }

  FullCustomSource build() => FullCustomSource(
        lightScheme: _light,
        darkScheme: _dark,
        lightExtension: _lightExt,
        darkExtension: _darkExt,
        textTheme: _textTheme,
        fontFamily: _fontFamily,
      );
}

// ── 4. Dynamic device colors ─────────────────────────────────────────

class DynamicDeviceSource extends ThemeSource {
  const DynamicDeviceSource({required this.fallbackSeed});
  final Color fallbackSeed;

  @override
  String get kind => 'dynamicDevice';
  @override
  SupportedBrightness get supports => SupportedBrightness.both;
  @override
  Map<String, dynamic> toJson() => {
        'kind': kind,
        'fallbackSeed': fallbackSeed.toARGB32(),
      };

  static DynamicDeviceSource fromJson(Map<String, dynamic> j) =>
      DynamicDeviceSource(fallbackSeed: Color(j['fallbackSeed'] as int));
}

// ── 5. Image-derived seed ────────────────────────────────────────────

class FromImageSource extends ThemeSource {
  const FromImageSource({required this.imageRef, required this.fallbackSeed});
  final ImageRef imageRef;
  final Color fallbackSeed;

  @override
  String get kind => 'fromImage';
  @override
  SupportedBrightness get supports => SupportedBrightness.both;
  @override
  Map<String, dynamic> toJson() => {
        'kind': kind,
        'imageRef': imageRef.toJson(),
        'fallbackSeed': fallbackSeed.toARGB32(),
      };

  static FromImageSource? fromJson(Map<String, dynamic> j) {
    final ref = ImageRef.fromJson(j['imageRef'] as Map<String, dynamic>?);
    if (ref == null) return null;
    return FromImageSource(
      imageRef: ref,
      fallbackSeed: Color(j['fallbackSeed'] as int),
    );
  }
}

// ── helpers ──────────────────────────────────────────────────────────

Map<String, int> _encodeColors(Map<String, Color> m) =>
    m.map((k, v) => MapEntry(k, v.toARGB32()));

Map<String, Color> _decodeColors(dynamic m) {
  if (m is! Map) return const {};
  return m.map((k, v) => MapEntry(k.toString(), Color(v as int)));
}
