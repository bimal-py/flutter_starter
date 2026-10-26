import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsAboutGroupWidget extends StatelessWidget {
  const SettingsAboutGroupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SettingsTileWidget(
        icon: LucideIcons.info,
        label: 'About app',
        subtitle: 'What this app does and who built it',
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => context.pushNamed(Routes.about.name),
      ),
    );
  }
}
