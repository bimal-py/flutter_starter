import 'package:flutter/material.dart';
import 'package:flutter_starter/core/utils/extensions/context_extension.dart';

/// Visual tone of a [ConfirmationDialog]. Drives the leading icon and the
/// confirm button's accent color.
enum DialogType { info, success, warning, danger, question }

extension DialogTypeX on DialogType {
  IconData get icon => switch (this) {
    DialogType.info => Icons.info_outline,
    DialogType.success => Icons.check_circle_outline,
    DialogType.warning => Icons.warning_amber_outlined,
    DialogType.danger => Icons.error_outline,
    DialogType.question => Icons.help_outline,
  };

  Color accentColor(BuildContext context) => switch (this) {
        DialogType.info => context.customTheme.info,
        DialogType.success => context.customTheme.success,
        DialogType.warning => context.customTheme.warning,
        DialogType.danger => context.colorScheme.error,
        DialogType.question => context.colorScheme.primary,
      };
}
