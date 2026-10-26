import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/common/widgets/widgets.dart';

class CachedNetworkImageWrapper extends StatelessWidget {
  const CachedNetworkImageWrapper({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) =>
          CachedNetworkImagePlaceholder(width: width, height: height),
      errorWidget: (_, _, _) =>
          CachedNetworkImageErrorBox(width: width, height: height),
    );
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
