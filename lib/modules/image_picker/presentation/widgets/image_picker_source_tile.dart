import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

/// One source row (camera or gallery) of the image picker sheet.
class ImagePickerSourceTile extends StatelessWidget {
  const ImagePickerSourceTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: context.colorScheme.primaryContainer,
        child: Icon(icon, color: context.colorScheme.onPrimaryContainer),
      ),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
