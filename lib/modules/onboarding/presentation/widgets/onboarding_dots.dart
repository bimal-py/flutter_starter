import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: (active ? 24 : 8).w,
          height: 8.h,
          decoration: BoxDecoration(
            color: active ? colorScheme.primary : colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
