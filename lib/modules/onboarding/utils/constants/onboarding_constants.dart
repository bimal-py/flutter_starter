import 'package:flutter/widgets.dart';
import 'package:flutter_starter/modules/onboarding/utils/constants/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingConstants {
  OnboardingConstants._();

  static const Duration pageTransition = Duration(milliseconds: 280);

  /// The carousel, in order. The last page's button reads "Get started".
  static const List<({IconData icon, String title, String subtitle})> pages = [
    (
      icon: LucideIcons.rocket,
      title: OnboardingStrings.shipFasterTitle,
      subtitle: OnboardingStrings.shipFasterSubtitle,
    ),
    (
      icon: LucideIcons.layers,
      title: OnboardingStrings.modulesTitle,
      subtitle: OnboardingStrings.modulesSubtitle,
    ),
    (
      icon: LucideIcons.palette,
      title: OnboardingStrings.themeTitle,
      subtitle: OnboardingStrings.themeSubtitle,
    ),
  ];
}
