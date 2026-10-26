import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/dashboard/utils/constants/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Destinations in the same order as the tabs in `DashboardBody`.
class DashboardNavBar extends StatelessWidget {
  const DashboardNavBar({
    super.key,
    required this.index,
    required this.onSelect,
  });

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onSelect,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            selectedIcon: Icon(LucideIcons.house),
            label: DashboardStrings.home,
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(LucideIcons.settings),
            label: DashboardStrings.settings,
          ),
        ],
      ),
    );
  }
}
