import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shown when a [CachedNetworkImageWrapper] image fails to load.
class CachedNetworkImageErrorBox extends StatelessWidget {
  const CachedNetworkImageErrorBox({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: context.colorScheme.surfaceContainerHighest,
      child: Icon(
        LucideIcons.imageOff,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
