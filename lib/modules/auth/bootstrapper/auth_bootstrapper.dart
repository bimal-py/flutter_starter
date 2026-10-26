import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/auth/presentation/presentation.dart';

/// Reacts to sign-in / sign-out edges anywhere in the app (including a
/// forced logout when the session can't be refreshed). Keeps navigation in
/// app code; the bloc stays UI-free.
class AuthBootstrapper extends StatelessWidget {
  const AuthBootstrapper({
    super.key,
    required this.child,
    this.onUnauthenticated,
    this.onAuthenticated,
    this.onChanged,
  });

  final Widget child;
  final void Function(BuildContext context)? onUnauthenticated;
  final void Function(BuildContext context, AuthState state)? onAuthenticated;

  /// Any status change, including the first check at app start.
  final void Function(BuildContext context, AuthState state)? onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        onChanged?.call(context, state);
        if (state.status.isUnauthenticated) {
          onUnauthenticated?.call(context);
        } else if (state.isAuthenticated) {
          onAuthenticated?.call(context, state);
        }
      },
      child: child,
    );
  }
}
