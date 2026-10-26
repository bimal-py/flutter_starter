import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetRoutes.appLogo,
      width: 0.5.sw,
      height: 0.5.swClamp(0, 0.5.sh),
    );
  }
}
