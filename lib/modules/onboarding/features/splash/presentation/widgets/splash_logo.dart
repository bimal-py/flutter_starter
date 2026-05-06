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

class SplashProgress extends StatelessWidget {
  const SplashProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 0.4.sw,
          child: LinearProgressIndicator(
            minHeight: 3.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        8.verticalSpace,
        Text(
          'Loading...',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
