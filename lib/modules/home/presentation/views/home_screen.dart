import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/home/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/home/utils/constants/constants.dart';
import 'package:flutter_starter/modules/qr/qr.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The dashboard's first tab. It has no Scaffold: the dashboard provides one.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const HomeView();
}

/// A welcome banner over a grid of demo tiles.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
            child: HomeSectionLabel(text: HomeStrings.demosLabel),
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
                icon: LucideIcons.info,
                label: HomeStrings.about,
                onTap: (c) => c.pushNamed(Routes.about.name),
              ),
              HomeFeatureCard(
                icon: LucideIcons.globe,
                label: HomeStrings.openWebsite,
                onTap: (c) => c.pushNamed(
                  Routes.websiteView.name,
                  extra: AppUrls.demoSite,
                ),
              ),
              HomeFeatureCard(
                icon: LucideIcons.qrCode,
                label: HomeStrings.shareViaQr,
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
