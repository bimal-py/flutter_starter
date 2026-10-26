part of 'auth_bloc.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;
  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
}

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.session, this.user});

  const AuthState.initial() : this();
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  /// Signed out, still carrying [last]'s user, so the screens closing on the
  /// way to the login screen don't go blank. Nothing treats it as signed in;
  /// the next sign-in replaces it.
  AuthState.signedOut(AuthState last)
    : this(
        status: AuthStatus.unauthenticated,
        session: last.session,
        user: last.user,
      );
  const AuthState.authenticated(AuthSessionEntity session, {UserEntity? user})
    : this(status: AuthStatus.authenticated, session: session, user: user);

  final AuthStatus status;
  final AuthSessionEntity? session;

  /// The signed-in person (`users/me/`).
  final UserEntity? user;

  bool get isAuthenticated => status.isAuthenticated && session != null;
  bool get isUnauthenticated => status.isUnauthenticated;

  @override
  List<Object?> get props => [status, session, user];
}
