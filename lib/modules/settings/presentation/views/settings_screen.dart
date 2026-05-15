import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/package_info/package_info.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: const [
          SettingsAppCard(),
          SizedBox(height: 20),
          SettingsSectionHeader(label: 'Appearance'),
          SettingsThemePicker(),
          SizedBox(height: 8),
          SettingsThemePlaygroundTile(),
          SizedBox(height: 20),
          SettingsSectionHeader(label: 'App'),
          SettingsReplayOnboardingTile(),
          SizedBox(height: 20),
          SettingsSectionHeader(label: 'Share & feedback'),
          SettingsShareFeedbackGroup(),
          SizedBox(height: 20),
          SettingsSectionHeader(label: 'About'),
          SettingsAboutGroup(),
          AppVersionFooter(),
        ],
      ),
    );
  }
}
