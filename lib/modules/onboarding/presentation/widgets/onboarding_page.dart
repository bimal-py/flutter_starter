import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

/// One carousel page: layered circle badge, title and supporting copy.
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
                  color: colorScheme.tertiaryContainer,
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
              Icon(icon, size: 56.r, color: colorScheme.onPrimaryContainer),
            ],
          ),
          36.verticalSpace,
          Text(
            title,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          12.verticalSpace,
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
