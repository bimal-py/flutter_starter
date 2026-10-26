import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/mobile_ads/features/banner_ad/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/mobile_ads/features/banner_ad/presentation/widgets/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Drop-in banner with its own [BannerAdCubit]. Until the banner loads it
/// keeps a standard banner's height (50 dp) free.
class BannerAdSlot extends StatelessWidget {
  const BannerAdSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BannerAdCubit()..load(),
      child: BlocBuilder<BannerAdCubit, BannerAdState>(
        builder: (context, state) {
          final bannerAd = state.bannerAd;
          if (state.loadingState.isSuccess && bannerAd != null) {
            return BannerAdFrame(bannerAd: bannerAd);
          }
          return SizedBox(height: AdSize.banner.height.toDouble());
        },
      ),
    );
  }
}
