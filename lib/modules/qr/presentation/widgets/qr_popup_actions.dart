import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/qr/utils/constants/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Save" (to the gallery) and "Share", side by side.
class QrPopupActions extends StatelessWidget {
  const QrPopupActions({
    super.key,
    required this.onSave,
    required this.onShare,
  });

  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSave,
            icon: const Icon(LucideIcons.download),
            label: const Text(QrStrings.save),
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(LucideIcons.share2),
            label: const Text(QrStrings.share),
          ),
        ),
      ],
    );
  }
}
