import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/domain/entity/auth_user.dart';
import 'package:flutter_starter/modules/auth/domain/use_case/use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Auth state machine. Hydrates from persisted user on construction (no UI
/// flash on cold start when there's actually a session) and subscribes to
/// [WatchAuthUserUseCase] so server-side revocation / interceptor 401 /
/// "Sign out everywhere" propagates back to the UI.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial()) {
    on<_AuthInitialCheckRequested>(_onInitialCheck);
    on<_AuthUserChanged>(_onUserChanged);
    on<_AuthLoginRequested>(_onLogin);
    on<_AuthRegisterEmailRequested>(_onRegisterEmail);
    on<_AuthRegisterUserRequested>(_onRegisterUser);
    on<_AuthLoginWithGoogleRequested>(_onLoginWithGoogle);
    on<_AuthLoginWithAppleRequested>(_onLoginWithApple);
    on<_AuthForgetPasswordRequested>(_onForgetPassword);
    on<_AuthResetPasswordRequested>(_onResetPassword);
    on<_AuthLogoutRequested>(_onLogout);

    add(const _AuthInitialCheckRequested());
    _subscription = _watchAuthUserUseCase
        .execute(const NoParams())
        .listen((user) => add(_AuthUserChanged(user)));
  }

  final LoginWithEmailPasswordUseCase _loginUseCase =
      getIt<LoginWithEmailPasswordUseCase>();
  final LoginWithGoogleUseCase _loginWithGoogleUseCase =
      getIt<LoginWithGoogleUseCase>();
  final LoginWithAppleUseCase _loginWithAppleUseCase =
      getIt<LoginWithAppleUseCase>();
  final RegisterEmailUseCase _registerEmailUseCase =
      getIt<RegisterEmailUseCase>();
  final RegisterUserUseCase _registerUserUseCase = getIt<RegisterUserUseCase>();
  final ForgetPasswordUseCase _forgetPasswordUseCase =
      getIt<ForgetPasswordUseCase>();
  final ResetPasswordUseCase _resetPasswordUseCase =
      getIt<ResetPasswordUseCase>();
  final LogoutUseCase _logoutUseCase = getIt<LogoutUseCase>();
  final GetLoggedInUserUseCase _getLoggedInUserUseCase =
      getIt<GetLoggedInUserUseCase>();
  final WatchAuthUserUseCase _watchAuthUserUseCase =
      getIt<WatchAuthUserUseCase>();

  StreamSubscription<AuthUser?>? _subscription;

  void login({required String email, required String password}) =>
      add(_AuthLoginRequested(email: email, password: password));

  void registerEmail(String email) => add(_AuthRegisterEmailRequested(email));

  void registerUser({
    required String email,
    required String password,
    required String fullName,
    String code = '',
    String? phoneNumber,
  }) => add(_AuthRegisterUserRequested(
    email: email,
    password: password,
    fullName: fullName,
    code: code,
    phoneNumber: phoneNumber,
  ));

  void loginWithGoogle() => add(const _AuthLoginWithGoogleRequested());
  void loginWithApple() => add(const _AuthLoginWithAppleRequested());

  void forgetPassword(String email) =>
      add(_AuthForgetPasswordRequested(email));

  void resetPassword({
    required String oldPassword,
    required String newPassword,
  }) => add(_AuthResetPasswordRequested(
    oldPassword: oldPassword,
    newPassword: newPassword,
  ));

  void logout({bool wasStillAuthenticated = true}) =>
      add(_AuthLogoutRequested(wasStillAuthenticated: wasStillAuthenticated));

  Future<void> _onInitialCheck(
    _AuthInitialCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _getLoggedInUserUseCase.execute(const NoParams());
    emit(user != null
        ? AuthState.authenticated(user)
        : const AuthState.unauthenticated());
  }

  Future<void> _onUserChanged(
    _AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async => emit(
    event.user != null
        ? AuthState.authenticated(event.user!)
        : const AuthState.unauthenticated(),
  );

  Future<void> _onLogin(_AuthLoginRequested e, Emitter<AuthState> emit) =>
      _runAuth(emit, () => _loginUseCase.execute(
            LoginWithEmailPasswordParams(email: e.email, password: e.password),
          ));

  Future<void> _onRegisterEmail(
    _AuthRegisterEmailRequested e,
    Emitter<AuthState> emit,
  ) => _runNoAuth(emit, () => _registerEmailUseCase.execute(e.email));

  Future<void> _onRegisterUser(
    _AuthRegisterUserRequested e,
    Emitter<AuthState> emit,
  ) => _runAuth(emit, () => _registerUserUseCase.execute(
        RegisterUserParams(
          email: e.email,
          password: e.password,
          fullName: e.fullName,
          code: e.code,
          phoneNumber: e.phoneNumber,
        ),
      ));

  Future<void> _onLoginWithGoogle(
    _AuthLoginWithGoogleRequested e,
    Emitter<AuthState> emit,
  ) => _runAuth(emit, () => _loginWithGoogleUseCase.execute(const NoParams()));

  Future<void> _onLoginWithApple(
    _AuthLoginWithAppleRequested e,
    Emitter<AuthState> emit,
  ) => _runAuth(emit, () => _loginWithAppleUseCase.execute(const NoParams()));

  Future<void> _onForgetPassword(
    _AuthForgetPasswordRequested e,
    Emitter<AuthState> emit,
  ) => _runNoAuth(emit, () => _forgetPasswordUseCase.execute(e.email));

  Future<void> _onResetPassword(
    _AuthResetPasswordRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.busy, error: null));
    try {
      await _resetPasswordUseCase.execute(
        ResetPasswordParams(
          oldPassword: e.oldPassword,
          newPassword: e.newPassword,
        ),
      );
      emit(state.copyWith(status: state.user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated));
    } catch (error) {
      emit(state.copyWith(error: AppErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onLogout(
    _AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _logoutUseCase.execute(
        LogoutParams(wasStillAuthenticated: event.wasStillAuthenticated),
      );
    } catch (_) {
      // watchUser still flips us to unauthenticated — the repo clears local
      // state before any server hop can fail.
    }
  }

  /// For actions that authenticate on success — let [WatchAuthUserUseCase]
  /// emit the authenticated state so we don't flicker through an intermediate
  /// unauthenticated emit before the user arrives.
  Future<void> _runAuth(
    Emitter<AuthState> emit,
    FutureOr<void> Function() action,
  ) async {
    emit(state.copyWith(status: AuthStatus.busy, error: null));
    try {
      await action();
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: AppErrorHandler.getErrorMessage(error),
      ));
    }
  }

  /// For actions with no auth side effect (email verification, password reset
  /// link, …) — settle back to unauthenticated either way.
  Future<void> _runNoAuth(
    Emitter<AuthState> emit,
    FutureOr<void> Function() action,
  ) async {
    emit(state.copyWith(status: AuthStatus.busy, error: null));
    try {
      await action();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: AppErrorHandler.getErrorMessage(error),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
