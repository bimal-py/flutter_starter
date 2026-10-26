import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/domain.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';

/// House ad shaped like a content grid card (logo, name, tagline, CTA).
/// Tapping opens the app's download page.
class SelfPromotionNativeCard extends StatelessWidget {
  const SelfPromotionNativeCard({super.key, required this.app});

  final SelfPromotionAppEntity app;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = Color(app.colorValue);
    return Material(
      color: Color.alphaBlend(
        color.withValues(alpha: 0.10),
        scheme.surfaceContainerHigh,
      ),
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => SelfPromotionHelper.open(app),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset(
                      app.logoAsset,
                      width: 32.r,
                      height: 32.r,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Icon(Icons.apps, size: 32.r, color: color),
                    ),
                  ),
                  const Spacer(),
                  SelfPromotionAdBadge(color: color),
                ],
              ),
              10.verticalSpace,
              Text(
                app.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              2.verticalSpace,
              Expanded(
                child: Text(
                  app.tagline,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.25,
                  ),
                ),
              ),
              8.verticalSpace,
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  app.cta,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
