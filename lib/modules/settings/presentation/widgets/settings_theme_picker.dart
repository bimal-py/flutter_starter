import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';

class SettingsThemePicker extends StatelessWidget {
  const SettingsThemePicker({super.key});

  ThemeVariant _variantFor(ThemeMode mode) => switch (mode) {
    ThemeMode.light => ThemeVariant.light,
    ThemeMode.dark => ThemeVariant.dark,
    ThemeMode.system => ThemeVariant.system,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final activeMode = state.variant.toThemeMode();
        return Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              for (final mode in ThemeMode.values)
                Expanded(
                  child: SettingsThemeOption(
                    mode: mode,
                    selected: activeMode == mode,
                    onTap: () => context.read<ThemeCubit>().setVariant(
                      _variantFor(mode),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
