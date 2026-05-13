import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/app_setting/app_setting.dart';
import 'package:flutter_starter/modules/onboarding/presentation/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    OnboardingPage(
      icon: LucideIcons.rocket,
      title: 'Ship faster',
      subtitle:
          'Skip the boilerplate. Start from a clean architecture instead of a blank Flutter template.',
    ),
    OnboardingPage(
      icon: LucideIcons.layers,
      title: 'Feature-first modules',
      subtitle:
          'Each feature owns its data, domain, and presentation layers — no tangled dependencies.',
    ),
    OnboardingPage(
      icon: LucideIcons.palette,
      title: 'Themeable by default',
      subtitle:
          'Material 3 ColorScheme + a CustomThemeExtension hook for brand colors.',
    ),
  ];

  void _next() {
    if (_index == _pages.length - 1) {
      context.read<AppSettingCubit>().markOnboardingComplete();
      context.goNamed(Routes.dashboard.name);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: TextButton(
                  onPressed: () {
                    context.read<AppSettingCubit>().markOnboardingComplete();
                    context.goNamed(Routes.dashboard.name);
                  },
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            OnboardingDots(count: _pages.length, current: _index),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton.icon(
                  onPressed: _next,
                  icon: Icon(
                    isLast ? LucideIcons.check : LucideIcons.arrowRight,
                    size: 18.r,
                  ),
                  label: Text(isLast ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
