import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/domain.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';

/// House ad shaped like a banner (logo, name and tagline, CTA) for banner
/// slots. Tapping opens the app's download page.
class SelfPromotionBanner extends StatelessWidget {
  const SelfPromotionBanner({super.key, required this.app, this.height = 64});

  final SelfPromotionAppEntity app;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = Color(app.colorValue);
    return Material(
      color: Color.alphaBlend(
        color.withValues(alpha: 0.10),
        scheme.surfaceContainerHigh,
      ),
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => SelfPromotionHelper.open(app),
        child: Container(
          height: height.r,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  app.logoAsset,
                  width: 40.r,
                  height: 40.r,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.apps, size: 40.r, color: color),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            app.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        6.horizontalSpace,
                        SelfPromotionAdBadge(color: color),
                      ],
                    ),
                    Text(
                      app.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              10.horizontalSpace,
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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
