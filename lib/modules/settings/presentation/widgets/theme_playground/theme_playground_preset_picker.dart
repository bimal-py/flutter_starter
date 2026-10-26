import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/theme_playground/theme_playground.dart';

class ThemePlaygroundPresetPicker extends StatelessWidget {
  const ThemePlaygroundPresetPicker({super.key, required this.active});

  final ThemeSource active;

  // Matched by seed only, so any seed source with a preset's color selects it.
  bool _isActive(ThemePreset preset) {
    final a = active;
    final s = preset.source;
    if (a is SeedOnlySource && s is SeedOnlySource) {
      return a.seed.toARGB32() == s.seed.toARGB32();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final preset in ThemePresets.all)
          ThemePlaygroundPresetChip(
            preset: preset,
            selected: _isActive(preset),
            onTap: () =>
                context.read<ThemeCubit>().applyCustomSource(preset.source),
          ),
      ],
    );
  }
}
