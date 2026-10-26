import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/constants/constants.dart';

class MorselabNativeAdWidget extends StatelessWidget {
  const MorselabNativeAdWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      const SelfPromotionNativeCard(app: SelfPromotionApps.morselab);
}
