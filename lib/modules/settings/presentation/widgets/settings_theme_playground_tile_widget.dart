import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsThemePlaygroundTileWidget extends StatelessWidget {
  const SettingsThemePlaygroundTileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) => SettingsTileWidget(
        icon: LucideIcons.palette,
        label: 'Customize theme',
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

  String _subtitleFor(ThemeState state) {
    if (!state.hasUserOverride) return "Using app's default";
    final source = state.userOverride!;
    return switch (source) {
      SeedOnlySource() => 'Custom seed color',
      SeedWithOverridesSource() => 'Custom palette',
      FullCustomSource() => 'Fully custom',
      DynamicDeviceSource() => 'Device wallpaper colors',
      FromImageSource() => 'Color extracted from image',
    };
  }
}
