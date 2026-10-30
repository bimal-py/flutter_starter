import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/features/features.dart';
import 'package:flutter_starter/modules/auth/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';
import 'package:go_router/go_router.dart';

/// A sample sign-in screen on [LoginCubit]: email, password, Remember me.
/// Restyle it, or replace it with your designer's; the cubit stays.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _onLogin(BuildContext context, LoginState state) {
    if (state.loadingState.isLoading) return context.showPopupLoading();
    context.hidePopupLoading();
    if (state.loadingState.isFailure) {
      CustomSnackbar.show(
        type: ToastType.error,
        message: state.error ?? AppErrorStrings.somethingWentWrong,
      );
    } else if (state.loadingState.isSuccess) {
      context.goNamed(Routes.dashboard.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (a, b) => a.loadingState != b.loadingState,
        listener: _onLogin,
        child: const LoginView(),
      ),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutterWide,
            AppSpacing.xl * 2,
            AppSpacing.gutterWide,
            AppSpacing.xl,
          ),
          children: [
            Text(
              AuthStrings.signInTitle,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            8.verticalSpace,
            Text(
              AuthStrings.signInSubtitle,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            32.verticalSpace,
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}
