import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/app_setting/app_setting.dart';
import 'package:flutter_starter/modules/onboarding/features/splash/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/onboarding/features/splash/presentation/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

/// Splash: its bloc and the redirect once the delay is over, then
/// [SplashView].
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Onboarding until it is finished (or replayed from Settings), otherwise
  /// the dashboard.
  void _onState(BuildContext context, SplashState state) {
    if (!state.status.isSuccess) return;
    final showOnboarding = context
        .read<AppSettingCubit>()
        .state
        .showOnboardingAtAppOpen;
    context.goNamed(
      showOnboarding ? Routes.onboarding.name : Routes.dashboard.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashBloc()..add(const SplashStarted()),
      child: BlocListener<SplashBloc, SplashState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onState,
        child: const SplashView(),
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const SplashLogo(),
              const Spacer(),
              const SplashProgress(),
              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
