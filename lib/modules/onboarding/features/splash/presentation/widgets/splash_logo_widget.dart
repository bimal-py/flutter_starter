import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

class SplashLogoWidget extends StatelessWidget {
  const SplashLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetRoutes.appLogo,
      width: 0.5.sw,
      height: 0.5.swClamp(0, 0.5.sh),
    );
  }
}

class SplashProgressWidget extends StatelessWidget {
  const SplashProgressWidget({super.key});

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
        Text('Loading...', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
