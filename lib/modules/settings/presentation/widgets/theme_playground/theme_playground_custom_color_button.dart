import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/theme_playground/theme_playground.dart';

class ThemePlaygroundCustomColorButton extends StatelessWidget {
  const ThemePlaygroundCustomColorButton({
    super.key,
    required this.active,
    required this.onPick,
  });

  final Color active;
  final ValueChanged<Color> onPick;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showDialog<Color>(
      context: context,
      builder: (_) => ThemePlaygroundColorDialog(initialColor: active),
    );
    if (result != null) onPick(result);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outline),
        ),
        child: Icon(Icons.add, color: scheme.onSurface, size: 20.r),
      ),
    );
  }
}
