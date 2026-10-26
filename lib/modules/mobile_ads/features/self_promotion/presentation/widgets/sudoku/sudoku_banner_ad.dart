import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';

class SudokuBannerAd extends StatelessWidget {
  const SudokuBannerAd({super.key});

  @override
  Widget build(BuildContext context) =>
      const SelfPromotionBanner(app: SelfPromotionApps.sudoku);
}
