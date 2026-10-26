import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';
import 'package:flutter_starter/modules/user/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// App-wide sign-in state: the session and the signed-in user. Follows what
/// is stored, so a forced logout (refresh token expired) flips it to
/// unauthenticated, and a profile edit shows everywhere.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial()) {
    on<_AuthInitialCheckRequested>(_onInitialCheck);
    on<_AuthSessionChanged>(_onSessionChanged);
    on<_AuthUserChanged>(_onUserChanged);
    on<_AuthLogoutRequested>(_onLogout);
    add(const _AuthInitialCheckRequested());
  }

  final RestoreAuthSessionUseCase _restoreUseCase =
      getIt<RestoreAuthSessionUseCase>();
  final WatchAuthSessionUseCase _watchUseCase =
      getIt<WatchAuthSessionUseCase>();
  final LogoutUseCase _logoutUseCase = getIt<LogoutUseCase>();
  final GetSavedUserUseCase _savedUserUseCase = getIt<GetSavedUserUseCase>();
  final WatchUserUseCase _watchUserUseCase = getIt<WatchUserUseCase>();
  final FetchUserUseCase _fetchUserUseCase = getIt<FetchUserUseCase>();
  StreamSubscription<AuthSessionEntity?>? _subscription;
  StreamSubscription<UserEntity?>? _userSubscription;

  void logout({bool wasStillAuthenticated = true}) =>
      add(_AuthLogoutRequested(wasStillAuthenticated: wasStillAuthenticated));

  Future<void> _onInitialCheck(
    _AuthInitialCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final session = await _restoreUseCase.execute(const NoParams());
    emit(_stateFor(session));
    _subscription ??= _watchUseCase
        .execute(const NoParams())
        .skip(1)
        .listen((s) => add(_AuthSessionChanged(s)));
    _userSubscription ??= _watchUserUseCase
        .execute(const NoParams())
        .skip(1)
        .listen((_) => add(const _AuthUserChanged()));
    // Signed in, but the user was never saved on this phone: read them once.
    if (state.isAuthenticated && state.user == null) unawaited(_loadUser());
  }

  void _onSessionChanged(_AuthSessionChanged event, Emitter<AuthState> emit) =>
      emit(_stateFor(event.session));

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    // Logout clears the saved user after the session: the signed-out state
    // keeps showing them until the screens are gone.
    if (!state.isAuthenticated) return;
    emit(_stateFor(state.session));
  }

  Future<void> _onLogout(
    _AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _logoutUseCase.execute(
        LogoutUseCaseParams(wasStillAuthenticated: event.wasStillAuthenticated),
      );
    } catch (_) {
      // The session watcher flips the state once local data is cleared.
    }
  }

  Future<void> _loadUser() async {
    try {
      await _fetchUserUseCase.execute(const NoParams());
    } catch (_) {
      // Offline: the next sign-in or profile load brings them.
    }
  }

  /// The saved user is read each time, so the state never lags behind what
  /// was just stored.
  AuthState _stateFor(AuthSessionEntity? session) => session == null
      ? (state.status.isInitial
            ? const AuthState.unauthenticated()
            : AuthState.signedOut(state))
      : AuthState.authenticated(
          session,
          user: _savedUserUseCase.execute(const NoParams()),
        );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _userSubscription?.cancel();
    return super.close();
  }
}
