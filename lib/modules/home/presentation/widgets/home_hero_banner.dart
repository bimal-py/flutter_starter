import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 22.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: colorScheme.primary,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.sparkles,
              size: 24.r,
              color: colorScheme.tertiary,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: colorScheme.onPrimary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to ${AppConstants.appName}',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Production-ready Flutter scaffold. Replace the demo tiles with your own features.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
