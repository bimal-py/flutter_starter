import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/domain.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';

/// [SelfPromotionNativeCard] for a random app, for when an AdMob native ad
/// isn't available.
class SelfPromotionNativeAd extends StatefulWidget {
  const SelfPromotionNativeAd({super.key});

  @override
  State<SelfPromotionNativeAd> createState() => _SelfPromotionNativeAdState();
}

class _SelfPromotionNativeAdState extends State<SelfPromotionNativeAd> {
  // Picked once, so a rebuild doesn't swap the app.
  late final SelfPromotionAppEntity _app = SelfPromotionHelper.randomApp();

  @override
  Widget build(BuildContext context) => SelfPromotionNativeCard(app: _app);
}
