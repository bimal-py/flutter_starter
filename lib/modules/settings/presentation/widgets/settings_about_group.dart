import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsAboutGroup extends StatelessWidget {
  const SettingsAboutGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SettingsTile(
        icon: LucideIcons.info,
        label: SettingsStrings.aboutApp,
        subtitle: SettingsStrings.aboutAppSubtitle,
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => context.pushNamed(Routes.about.name),
      ),
    );
  }
}
