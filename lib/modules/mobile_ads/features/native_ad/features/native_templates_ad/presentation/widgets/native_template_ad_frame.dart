import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A loaded native template ad. The template is drawn natively in dp, so the
/// minimum height isn't scaled.
class NativeTemplateAdFrame extends StatelessWidget {
  const NativeTemplateAdFrame({super.key, required this.nativeAd});

  final NativeAd nativeAd;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100),
      child: AdWidget(ad: nativeAd),
    );
  }
}
