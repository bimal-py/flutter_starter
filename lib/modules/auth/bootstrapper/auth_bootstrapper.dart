import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/auth/domain/entity/auth_user.dart';
import 'package:flutter_starter/modules/auth/presentation/bloc/auth/auth_bloc.dart';

/// Listens for authenticated ↔ unauthenticated edges so route navigation
/// stays in app code (the bloc remains UI-free). Wrap any subtree below the
/// [AuthBloc] provider:
///
/// ```dart
/// AuthBootstrapper(
///   onUnauthenticated: (_)        => router.goNamed(Routes.login.name),
///   onAuthenticated:   (_, user)  => router.goNamed(Routes.dashboard.name),
///   child: child,
/// )
/// ```
class AuthBootstrapper extends StatelessWidget {
  const AuthBootstrapper({
    super.key,
    required this.child,
    this.onUnauthenticated,
    this.onAuthenticated,
  });

  final Widget child;

  /// Fires on `authenticated → unauthenticated` edges (logout / revocation).
  /// Does NOT fire on cold-start "no session".
  final void Function(BuildContext context)? onUnauthenticated;

  /// Fires on `unauthenticated → authenticated` edges. Does NOT fire on
  /// cold-start with a hydrated session — handle that via your router's
  /// initial-location logic.
  final void Function(BuildContext context, AuthUser user)? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.status.isAuthenticated && curr.status.isUnauthenticated ||
          prev.status.isUnauthenticated && curr.status.isAuthenticated,
      listener: (context, state) {
        if (state.status.isUnauthenticated) {
          onUnauthenticated?.call(context);
        } else if (state.status.isAuthenticated && state.user != null) {
          onAuthenticated?.call(context, state.user!);
        }
      },
      child: child,
    );
  }
}
