import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsThemePlaygroundTile extends StatelessWidget {
  const SettingsThemePlaygroundTile({super.key});

  String _subtitleFor(ThemeState state) {
    if (!state.hasUserOverride) return SettingsStrings.themeDefault;
    return switch (state.userOverride!) {
      SeedOnlySource() => SettingsStrings.themeCustomSeed,
      SeedWithOverridesSource() => SettingsStrings.themeCustomPalette,
      FullCustomSource() => SettingsStrings.themeFullyCustom,
      DynamicDeviceSource() => SettingsStrings.themeDeviceColors,
      FromImageSource() => SettingsStrings.themeFromImage,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) => SettingsTile(
        icon: LucideIcons.palette,
        label: SettingsStrings.customizeTheme,
        subtitle: _subtitleFor(state),
        trailing: Icon(
          LucideIcons.chevronRight,
          size: 18.r,
          color: context.colorScheme.onSurfaceVariant,
        ),
        onTap: () => context.goNamed(Routes.themePlayground.name),
      ),
    );
  }
}
