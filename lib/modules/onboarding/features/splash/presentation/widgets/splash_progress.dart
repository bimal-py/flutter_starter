import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/onboarding/features/splash/utils/constants/constants.dart';

/// Thin indeterminate bar with a label, at the bottom of the splash.
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
        Text(SplashStrings.loading, style: context.textTheme.labelMedium),
      ],
    );
  }
}
