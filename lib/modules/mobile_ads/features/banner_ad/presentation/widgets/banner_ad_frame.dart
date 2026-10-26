import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A loaded banner at its own size. Ad sizes are dp from the SDK, so they
/// aren't scaled.
class BannerAdFrame extends StatelessWidget {
  const BannerAdFrame({super.key, required this.bannerAd});

  final BannerAd bannerAd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}
