import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/package_info/package_info.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';

/// The dashboard's Settings tab. Every cubit it reads is app-wide, so there
/// is nothing to provide here.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsView();
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(SettingsStrings.title),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          const SettingsAppCard(),
          20.verticalSpace,
          const SettingsSectionHeader(label: SettingsStrings.appearance),
          const SettingsThemePicker(),
          8.verticalSpace,
          const SettingsThemePlaygroundTile(),
          20.verticalSpace,
          const SettingsSectionHeader(label: SettingsStrings.app),
          const SettingsReplayOnboardingTile(),
          20.verticalSpace,
          const SettingsSectionHeader(label: SettingsStrings.shareAndFeedback),
          const SettingsShareFeedbackGroup(),
          20.verticalSpace,
          const SettingsSectionHeader(label: SettingsStrings.about),
          const SettingsAboutGroup(),
          const AppVersionFooter(),
        ],
      ),
    );
  }
}
