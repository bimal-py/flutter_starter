part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class _AuthInitialCheckRequested extends AuthEvent {
  const _AuthInitialCheckRequested();
}

class _AuthSessionChanged extends AuthEvent {
  const _AuthSessionChanged(this.session);

  final AuthSessionEntity? session;
}

/// The saved user changed.
class _AuthUserChanged extends AuthEvent {
  const _AuthUserChanged();
}

class _AuthLogoutRequested extends AuthEvent {
  const _AuthLogoutRequested({required this.wasStillAuthenticated});

  final bool wasStillAuthenticated;
}
