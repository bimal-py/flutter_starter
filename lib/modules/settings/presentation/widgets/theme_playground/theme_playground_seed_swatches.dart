import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/theme_playground/theme_playground.dart';

class ThemePlaygroundSeedSwatches extends StatelessWidget {
  const ThemePlaygroundSeedSwatches({
    super.key,
    required this.active,
    required this.onPick,
  });

  final Color active;
  final ValueChanged<Color> onPick;

  static const List<Color> _swatches = [
    Color(0xFF1B3A6B),
    Color(0xFF4A6FA5),
    Color(0xFF1E88E5),
    Color(0xFF00ACC1),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Color(0xFFD81B60),
    Color(0xFF8E24AA),
    Color(0xFF5E35B1),
    Color(0xFFEF6C00),
    Color(0xFF6D4C41),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: [
          for (final color in _swatches)
            ThemePlaygroundSeedSwatch(
              color: color,
              selected: color.toARGB32() == active.toARGB32(),
              onTap: () => onPick(color),
            ),
          ThemePlaygroundCustomColorButton(active: active, onPick: onPick),
        ],
      ),
    );
  }
}
