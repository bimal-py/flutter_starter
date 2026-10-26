import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

class ThemePlaygroundSeedSwatch extends StatelessWidget {
  const ThemePlaygroundSeedSwatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? context.colorScheme.onSurface
                : Colors.transparent,
            width: selected ? 3 : 0,
          ),
        ),
        // Sits on a raw swatch color, not a scheme role, so it stays white.
        child: selected
            ? Icon(Icons.check, color: Colors.white, size: 20.r)
            : null,
      ),
    );
  }
}
