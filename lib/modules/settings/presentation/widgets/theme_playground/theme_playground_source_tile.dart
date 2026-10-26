import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

class ThemePlaygroundSourceTile extends StatelessWidget {
  const ThemePlaygroundSourceTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? scheme.primary : scheme.onSurfaceVariant,
      ),
      title: Text(label),
      subtitle: Text(subtitle, style: context.textTheme.bodySmall),
    );
  }
}
