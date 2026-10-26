import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/onboarding/utils/constants/constants.dart';

class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: TextButton(
          onPressed: onPressed,
          child: const Text(OnboardingStrings.skip),
        ),
      ),
    );
  }
}
