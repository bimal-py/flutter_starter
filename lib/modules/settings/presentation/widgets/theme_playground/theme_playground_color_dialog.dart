import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';

/// Pops the picked color on Apply, null on Cancel.
class ThemePlaygroundColorDialog extends StatefulWidget {
  const ThemePlaygroundColorDialog({super.key, required this.initialColor});

  final Color initialColor;

  @override
  State<ThemePlaygroundColorDialog> createState() =>
      _ThemePlaygroundColorDialogState();
}

class _ThemePlaygroundColorDialogState
    extends State<ThemePlaygroundColorDialog> {
  late Color _picked = widget.initialColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(SettingsStrings.pickCustomColor),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: widget.initialColor,
          onColorChanged: (color) => _picked = color,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(CommonStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_picked),
          child: const Text(SettingsStrings.apply),
        ),
      ],
    );
  }
}
