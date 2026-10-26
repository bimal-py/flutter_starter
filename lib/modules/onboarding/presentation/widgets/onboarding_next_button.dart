import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/onboarding/utils/constants/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Next", or "Get started" on the last page.
class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({
    super.key,
    required this.isLast,
    required this.onPressed,
  });

  final bool isLast;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(
            isLast ? LucideIcons.check : LucideIcons.arrowRight,
            size: 18.r,
          ),
          label: Text(
            isLast ? OnboardingStrings.getStarted : OnboardingStrings.next,
          ),
        ),
      ),
    );
  }
}
