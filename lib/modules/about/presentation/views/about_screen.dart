import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/about/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/about/utils/constants/constants.dart';
import 'package:flutter_starter/modules/package_info/package_info.dart';

/// Reads only app-wide state (the version), so there is nothing to provide.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => const AboutView();
}

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AboutStrings.title)),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const AboutDescription(),
          20.verticalSpace,
          const AboutSectionHeader(label: AboutStrings.developer),
          const AboutDeveloperCard(),
          const AppVersionFooter(),
        ],
      ),
    );
  }
}
