import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/app_setting/app_setting.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/settings_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsReplayOnboardingTile extends StatelessWidget {
  const SettingsReplayOnboardingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: LucideIcons.bookOpen,
      label: 'Show app tour again',
      subtitle: 'Replay the onboarding flow',
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18.r,
        color: context.colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        context.read<AppSettingCubit>().requestOnboardingReplay();
        context.goNamed(Routes.onboarding.name);
      },
    );
  }
}
