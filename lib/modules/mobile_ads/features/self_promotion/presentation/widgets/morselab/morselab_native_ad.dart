import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';

class MorselabNativeAd extends StatelessWidget {
  const MorselabNativeAd({super.key});

  @override
  Widget build(BuildContext context) =>
      const SelfPromotionNativeCard(app: SelfPromotionApps.morselab);
}
