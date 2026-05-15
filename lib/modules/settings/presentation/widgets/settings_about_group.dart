import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/settings_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsAboutGroup extends StatelessWidget {
  const SettingsAboutGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SettingsTile(
        icon: LucideIcons.info,
        label: 'About app',
        subtitle: 'What this app does and who built it',
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => context.pushNamed(Routes.about.name),
      ),
    );
  }
}
