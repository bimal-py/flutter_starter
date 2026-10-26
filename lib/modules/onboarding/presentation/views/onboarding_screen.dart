import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/app_setting/app_setting.dart';
import 'package:flutter_starter/modules/onboarding/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/onboarding/utils/constants/constants.dart';
import 'package:go_router/go_router.dart';

/// No bloc of its own: whether onboarding is done lives in the app-wide
/// [AppSettingCubit].
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => const OnboardingView();
}

/// The carousel. Skip and "Get started" both mark onboarding done and open
/// the dashboard.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == OnboardingConstants.pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    context.read<AppSettingCubit>().markOnboardingComplete();
    context.goNamed(Routes.dashboard.name);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: OnboardingConstants.pageTransition,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OnboardingSkipButton(onPressed: _finish),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: OnboardingConstants.pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final page = OnboardingConstants.pages[i];
                  return OnboardingPage(
                    icon: page.icon,
                    title: page.title,
                    subtitle: page.subtitle,
                  );
                },
              ),
            ),
            OnboardingDots(
              count: OnboardingConstants.pages.length,
              current: _index,
            ),
            OnboardingNextButton(isLast: _isLast, onPressed: _next),
          ],
        ),
      ),
    );
  }
}
