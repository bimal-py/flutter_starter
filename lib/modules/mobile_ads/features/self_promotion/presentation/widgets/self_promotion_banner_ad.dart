import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/domain.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';

/// [SelfPromotionBanner] for a random app, for when an AdMob banner isn't
/// available.
class SelfPromotionBannerAd extends StatefulWidget {
  const SelfPromotionBannerAd({super.key, this.height = 64});

  final double height;

  @override
  State<SelfPromotionBannerAd> createState() => _SelfPromotionBannerAdState();
}

class _SelfPromotionBannerAdState extends State<SelfPromotionBannerAd> {
  // Picked once, so a rebuild doesn't swap the app.
  late final SelfPromotionAppEntity _app = SelfPromotionHelper.randomApp();

  @override
  Widget build(BuildContext context) =>
      SelfPromotionBanner(app: _app, height: widget.height);
}
