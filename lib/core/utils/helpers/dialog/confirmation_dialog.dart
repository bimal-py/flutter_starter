import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_starter/core/utils/helpers/dialog/dialog_type.dart';

/// A Material [AlertDialog] with a typed accent icon, centered copy, and
/// a confirm/cancel pair that resolves to `Future<bool>` via `Navigator.pop`.
///
/// Prefer [DialogUtils.showConfirmationDialog] over instantiating directly.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    this.showCancelButton = true,
    this.dialogType = DialogType.info,
  });

  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final bool showCancelButton;
  final DialogType dialogType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = dialogType.accentColor(context);

    return AlertDialog(
      icon: Icon(dialogType.icon, size: 40.r, color: accent),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      // Single Row as the only action so the buttons can use Expanded
      // (OverflowBar — AlertDialog's default actions layout — doesn't honor
      // Expanded children and falls back to vertical stacking).
      actions: [
        Row(
          children: [
            if (showCancelButton) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelText ?? 'Cancel'),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: dialogType == DialogType.danger
                    ? FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      )
                    : null,
                child: Text(confirmText),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
