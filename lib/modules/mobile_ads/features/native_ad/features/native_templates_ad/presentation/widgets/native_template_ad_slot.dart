import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/mobile_ads/features/native_ad/features/native_templates_ad/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/mobile_ads/features/native_ad/features/native_templates_ad/presentation/widgets/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Loads a native template ad through the [NativeTemplateAdCubit] above it
/// and shows it once loaded; takes no space until then.
class NativeTemplateAdSlot extends StatefulWidget {
  const NativeTemplateAdSlot({
    super.key,
    this.templateType = TemplateType.medium,
  });

  final TemplateType templateType;

  @override
  State<NativeTemplateAdSlot> createState() => _NativeTemplateAdSlotState();
}

class _NativeTemplateAdSlotState extends State<NativeTemplateAdSlot> {
  @override
  void initState() {
    super.initState();
    context.read<NativeTemplateAdCubit>().load(
      templateType: widget.templateType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NativeTemplateAdCubit, NativeTemplateAdState>(
      builder: (context, state) {
        final nativeAd = state.nativeAd;
        if (state.loadingState.isSuccess && nativeAd != null) {
          return NativeTemplateAdFrame(nativeAd: nativeAd);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
