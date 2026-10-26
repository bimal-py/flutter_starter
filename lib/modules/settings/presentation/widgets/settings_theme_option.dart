import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsThemeOption extends StatelessWidget {
  const SettingsThemeOption({
    super.key,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final (label, icon) = switch (mode) {
      ThemeMode.system => (SettingsStrings.themeSystem, LucideIcons.monitor),
      ThemeMode.light => (SettingsStrings.themeLight, LucideIcons.sun),
      ThemeMode.dark => (SettingsStrings.themeDark, LucideIcons.moon),
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18.r,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            4.verticalSpace,
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
