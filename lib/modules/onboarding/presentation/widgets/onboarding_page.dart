import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final brand = Theme.of(context).extension<CustomThemeExtension>()!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 168.r,
                height: 168.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brand.brandAccentMuted,
                ),
              ),
              Container(
                width: 132.r,
                height: 132.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                ),
              ),
              Icon(
                icon,
                size: 56.r,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
          SizedBox(height: 36.h),
          Text(
            title,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            subtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
