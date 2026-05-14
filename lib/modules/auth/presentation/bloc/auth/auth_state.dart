part of 'auth_bloc.dart';

enum AuthStatus { initial, busy, authenticated, unauthenticated }

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;
  bool get isBusy => this == AuthStatus.busy;
  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  const AuthState.initial() : this();
  const AuthState.unauthenticated({String? error})
    : this(status: AuthStatus.unauthenticated, error: error);
  const AuthState.authenticated(AuthUser user)
    : this(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  bool get isAuthenticated => status.isAuthenticated && user != null;
  bool get isUnauthenticated => status.isUnauthenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
  }) => AuthState(
    status: status ?? this.status,
    // unauthenticated → drop the user. Other transitions keep whatever was
    // there so a stale snapshot doesn't disappear mid-flow.
    user: status == AuthStatus.unauthenticated ? null : (user ?? this.user),
    error: error,
  );

  @override
  List<Object?> get props => [status, user, error];
}
