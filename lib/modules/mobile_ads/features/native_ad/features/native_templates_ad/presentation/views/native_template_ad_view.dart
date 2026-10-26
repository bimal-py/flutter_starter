import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/mobile_ads/mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeTemplateAdView extends StatefulWidget {
  final TemplateType templateType;

  const NativeTemplateAdView({
    super.key,
    this.templateType = TemplateType.medium,
  });

  @override
  State<NativeTemplateAdView> createState() => _NativeTemplateAdViewState();
}

class _NativeTemplateAdViewState extends State<NativeTemplateAdView> {
  @override
  void initState() {
    super.initState();
    context.read<NativeTemplateAdCubit>().loadAd(
      templateType: widget.templateType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NativeTemplateAdCubit, NativeTemplateAdState>(
      builder: (context, state) {
        if (state.appLoadingState == AppLoadingState.success &&
            state.nativeAd != null) {
          return NativeTemplateAdWidget(nativeAd: state.nativeAd!);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
