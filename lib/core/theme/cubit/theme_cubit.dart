import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_starter/core/theme/colors/app_colors.dart';
import 'package:flutter_starter/core/theme/source/source.dart';
import 'package:flutter_starter/core/theme/variant/theme_variant.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

part 'theme_state.dart';

/// Holds the active [ThemeVariant], the developer's wired [ThemeSource], and
/// an optional user override that the playground writes. [ThemeState.effectiveSource]
/// resolves to userOverride when set, falling back to developerSource.
class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit({ThemeSource? developerSource})
      : super(ThemeState(
          developerSource: developerSource ?? _defaultDeveloperSource,
        ));

  static const ThemeSource _defaultDeveloperSource = SeedOnlySource(
    seed: AppColors.seed,
    accent: AppColors.accent,
  );

  // ── Variant ────────────────────────────────────────────────────────

  void setVariant(ThemeVariant v) => emit(state.copyWith(variant: v));

  void toggle() {
    final next = switch (state.variant.id) {
      'light' => ThemeVariant.dark,
      'dark' => ThemeVariant.system,
      _ => ThemeVariant.light,
    };
    setVariant(next);
  }

  // ── User override (playground writes these) ────────────────────────

  void setUserSource(ThemeSource s) => emit(state.copyWith(userOverride: s));

  void setUserSeed(Color seed, {Color? accent}) =>
      setUserSource(SeedOnlySource(seed: seed, accent: accent));

  Future<void> applyUserImage(
    ImageRef ref, {
    required Color fallbackSeed,
  }) async {
    // Emit placeholder source so the UI starts re-themeing immediately.
    emit(state.copyWith(
      userOverride: FromImageSource(imageRef: ref, fallbackSeed: fallbackSeed),
    ));
    final seed = await _extractDominantColor(ref);
    if (seed != null) {
      emit(state.copyWith(userOverride: SeedOnlySource(seed: seed)));
    }
  }

  void applyUserDynamicDevice({required Color fallbackSeed}) =>
      setUserSource(DynamicDeviceSource(fallbackSeed: fallbackSeed));

  void clearUserOverride() => emit(state.clearUserOverride());

  /// Alias of [setUserSource] used by the playground screen for clarity.
  void applyCustomSource(ThemeSource s) => setUserSource(s);

  // ── Developer source (tests, hot reload) ───────────────────────────

  void setDeveloperSource(ThemeSource s) =>
      emit(state.copyWith(developerSource: s));

  // ── Image dominant-color extraction ────────────────────────────────

  Future<Color?> _extractDominantColor(ImageRef ref) async {
    try {
      final bytes = await _loadImageBytes(ref);
      if (bytes == null) return null;
      final encoded = await decodeImageFromList(bytes);
      final byteData =
          await encoded.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return null;
      // Sample 1 in every 16 pixels (4x4 grid) to keep extraction snappy on
      // large images. Quantizer wants ARGB ints.
      final pixels = <int>[];
      final raw = byteData.buffer.asUint8List();
      for (var i = 0; i + 3 < raw.length; i += 16 * 4) {
        final r = raw[i];
        final g = raw[i + 1];
        final b = raw[i + 2];
        final a = raw[i + 3];
        if (a < 128) continue;
        pixels.add((a << 24) | (r << 16) | (g << 8) | b);
      }
      if (pixels.isEmpty) return null;
      final quantized = await QuantizerCelebi().quantize(pixels, 16);
      final ranked = Score.score(quantized.colorToCount);
      if (ranked.isEmpty) return null;
      return Color(ranked.first);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _loadImageBytes(ImageRef ref) async {
    switch (ref) {
      case FileImageRef(:final path):
        final file = File(path);
        if (!file.existsSync()) return null;
        return file.readAsBytes();
      case AssetImageRef(:final name):
        final data = await rootBundle.load(name);
        return data.buffer.asUint8List();
      case NetworkImageRef():
        // Network image extraction requires an HTTP client; deferred. Caller's
        // fallbackSeed will be used until a user-driven re-extraction lands.
        return null;
    }
  }

  // ── Persistence ────────────────────────────────────────────────────

  @override
  ThemeState fromJson(Map<String, dynamic> json) => ThemeState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ThemeState state) => state.toJson();
}
