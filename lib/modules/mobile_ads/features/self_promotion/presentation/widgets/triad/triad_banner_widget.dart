import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/constants/constants.dart';

class TriadBannerWidget extends StatelessWidget {
  const TriadBannerWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      const SelfPromotionBanner(app: SelfPromotionApps.triad);
}
