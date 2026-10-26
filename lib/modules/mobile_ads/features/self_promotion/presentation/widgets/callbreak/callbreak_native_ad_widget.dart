import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/constants/constants.dart';

class CallbreakNativeAdWidget extends StatelessWidget {
  const CallbreakNativeAdWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      const SelfPromotionNativeCard(app: SelfPromotionApps.callbreak);
}
