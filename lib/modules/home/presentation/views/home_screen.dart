import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/home/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/qr/qr.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          sliver: const SliverToBoxAdapter(child: HomeHeroBanner()),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          sliver: const SliverToBoxAdapter(
            child: HomeSectionLabel(text: 'Try the demos'),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildListDelegate([
              HomeFeatureCard(
                icon: LucideIcons.smartphone,
                label: 'Device info',
                onTap: (c) => c.pushNamed(Routes.deviceInfo.name),
              ),
              HomeFeatureCard(
                icon: LucideIcons.package,
                label: 'Package info',
                onTap: (c) => c.pushNamed(Routes.packageInfo.name),
              ),
              HomeFeatureCard(
                icon: LucideIcons.globe,
                label: 'Open website',
                onTap: (c) => c.pushNamed(
                  Routes.websiteView.name,
                  extra: AppUrls.demoSite,
                ),
              ),
              HomeFeatureCard(
                icon: LucideIcons.qrCode,
                label: 'Share via QR',
                onTap: (c) => QrPopup.show(
                  c,
                  qrData: AppUrls.appDownload,
                  fileName: AppConstants.appAndroidPackageId,
                ),
              ),
            ]),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 24.h)),
      ],
    );
  }
}
