import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/entity/entity.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/presentation/widgets/widgets.dart';

/// House ad in a horizontal banner shape (logo · name/tagline · CTA), for the
/// banner slots. Tapping opens the promoted app's store page.
class SelfPromotionBanner extends StatelessWidget {
  const SelfPromotionBanner({super.key, required this.app, this.height = 64});

  final SelfPromotionApp app;
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
        onTap: () => openSelfPromotion(app),
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
              SizedBox(width: 12.w),
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
                        SizedBox(width: 6.w),
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
              SizedBox(width: 10.w),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  app.cta,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.r,
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
