import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/entity/entity.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/constants/constants.dart';

SelfPromotionApp _randomApp() {
  final all = SelfPromotionApps.all;
  return all[Random().nextInt(all.length)];
}

/// A house ad that picks a random promoted app once (stable for its lifetime)
/// and renders it as a grid card. Use as a fallback when an AdMob native ad
/// isn't available.
class SelfPromotionNativeAd extends StatefulWidget {
  const SelfPromotionNativeAd({super.key});

  @override
  State<SelfPromotionNativeAd> createState() => _SelfPromotionNativeAdState();
}

class _SelfPromotionNativeAdState extends State<SelfPromotionNativeAd> {
  late final SelfPromotionApp _app = _randomApp();

  @override
  Widget build(BuildContext context) => SelfPromotionNativeCard(app: _app);
}

/// House ad in banner shape, random app picked once. Use as a fallback when an
/// AdMob banner isn't available.
class SelfPromotionBannerAd extends StatefulWidget {
  const SelfPromotionBannerAd({super.key, this.height = 64});

  final double height;

  @override
  State<SelfPromotionBannerAd> createState() => _SelfPromotionBannerAdState();
}

class _SelfPromotionBannerAdState extends State<SelfPromotionBannerAd> {
  late final SelfPromotionApp _app = _randomApp();

  @override
  Widget build(BuildContext context) =>
      SelfPromotionBanner(app: _app, height: widget.height);
}
