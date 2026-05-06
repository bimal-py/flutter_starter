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
      child: Column(
        children: [
          SettingsTile(
            icon: LucideIcons.smartphone,
            label: 'Device info',
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () => context.pushNamed(Routes.deviceInfo.name),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: LucideIcons.package,
            label: 'Package info',
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () => context.pushNamed(Routes.packageInfo.name),
          ),
        ],
      ),
    );
  }
}
