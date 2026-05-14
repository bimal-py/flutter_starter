part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class _AuthInitialCheckRequested extends AuthEvent {
  const _AuthInitialCheckRequested();
}

class _AuthUserChanged extends AuthEvent {
  const _AuthUserChanged(this.user);
  final AuthUser? user;
}

class _AuthLoginRequested extends AuthEvent {
  const _AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;
}

class _AuthRegisterEmailRequested extends AuthEvent {
  const _AuthRegisterEmailRequested(this.email);
  final String email;
}

class _AuthRegisterUserRequested extends AuthEvent {
  const _AuthRegisterUserRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.code,
    required this.phoneNumber,
  });
  final String email;
  final String password;
  final String fullName;
  final String code;
  final String? phoneNumber;
}

class _AuthLoginWithGoogleRequested extends AuthEvent {
  const _AuthLoginWithGoogleRequested();
}

class _AuthLoginWithAppleRequested extends AuthEvent {
  const _AuthLoginWithAppleRequested();
}

class _AuthForgetPasswordRequested extends AuthEvent {
  const _AuthForgetPasswordRequested(this.email);
  final String email;
}

class _AuthResetPasswordRequested extends AuthEvent {
  const _AuthResetPasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });
  final String oldPassword;
  final String newPassword;
}

class _AuthLogoutRequested extends AuthEvent {
  const _AuthLogoutRequested({required this.wasStillAuthenticated});
  final bool wasStillAuthenticated;
}
