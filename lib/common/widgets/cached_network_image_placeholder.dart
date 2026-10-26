import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shimmer while a [CachedNetworkImageWrapper] image downloads.
class CachedNetworkImagePlaceholder extends StatelessWidget {
  const CachedNetworkImagePlaceholder({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Bone(width: width, height: height),
    );
  }
}
