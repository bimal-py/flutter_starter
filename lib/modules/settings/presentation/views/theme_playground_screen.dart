import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';

/// Lets the user restyle the app. Every choice is written to the app-wide
/// [ThemeCubit], so there is nothing to provide here.
class ThemePlaygroundScreen extends StatelessWidget {
  const ThemePlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context) => const ThemePlaygroundView();
}

class ThemePlaygroundView extends StatelessWidget {
  const ThemePlaygroundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(SettingsStrings.customizeTheme),
        centerTitle: false,
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) => ListView(
          padding: AppSpacing.page,
          children: [
            ThemePlaygroundStatusBanner(hasOverride: state.hasUserOverride),
            16.verticalSpace,
            const SettingsSectionHeader(label: SettingsStrings.brightnessMode),
            const SettingsThemePicker(),
            20.verticalSpace,
            const SettingsSectionHeader(label: SettingsStrings.presets),
            ThemePlaygroundPresetPicker(active: state.effectiveSource),
            20.verticalSpace,
            const SettingsSectionHeader(label: SettingsStrings.source),
            ThemePlaygroundSourcePicker(initialSource: state.effectiveSource),
            20.verticalSpace,
            const SettingsSectionHeader(label: SettingsStrings.preview),
            const ThemePlaygroundPreview(),
          ],
        ),
      ),
    );
  }
}
