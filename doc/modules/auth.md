# Auth

Sign-in state for the whole app: email + password login, email-code sign-up, forgot / reset / change password, Google and Apple sign-in (through a provider you plug in), "Remember me", token refresh and logout. It ships the logic (repositories, use cases, cubits, `AuthBloc`) and a placeholder login screen; you build the screens. Keep it when your app has accounts on a REST backend.

## What it provides

- `AuthBloc` (`presentation/bloc/auth/`): the app-wide state. `AuthState.status` is `initial`, `authenticated` or `unauthenticated`; `state.session` (who signed in, remember me) and `state.user` (the `UserEntity` from the user module). `authBloc.logout()`.
- `AuthBootstrapper` (`bootstrapper/`): calls back on sign-in / sign-out edges (`onAuthenticated`, `onUnauthenticated`, `onChanged`), wired in `lib/app/app_bootstrappers.dart`.
- Feature cubits (`features/`): `LoginCubit` (remembered email, remember me), `RegisterCubit` (terms, send code) and `CompleteRegistrationCubit` (code + password, resend), `ForgotPasswordCubit` and `ResetPasswordCubit`, `ChangePasswordCubit`, `OtpCountdownCubit` (resend timer), `ThirdPartyAuthCubit` (Google / Apple, cancellation as a notice).
- Use cases: `LoginUseCase`, `SendVerificationCodeUseCase`, `RegisterUseCase`, `LoginWithGoogleUseCase`, `LoginWithAppleUseCase`, `RequestPasswordResetUseCase`, `ConfirmPasswordResetUseCase`, `ChangePasswordUseCase`, `LogoutUseCase`, `RestoreAuthSessionUseCase`, `WatchAuthSessionUseCase`, `GetRememberedEmailUseCase`.
- `AuthTokenHandlerImpl`: gives the network layer the access token, refreshes it, logs out when it can't.
- `AuthValidators` (email, password rules, confirm password), `AuthError` copy, `AuthApiRoute` endpoints.
- `ThirdPartyAuthProviderStub`: throws "not set up" until you add a real Google / Apple provider.

## Depends on

- The [user](user.md) module (`UserEntity`, saved user, `users/me/`).
- [Network](../core/network.md) (`RemoteService`), `flutter_secure_storage` (tokens), Hive (`auth_box`).
- Backend endpoints in `utils/constants/auth_api_route.dart` (Django + SimpleJWT style).

## Setup

1. Set `API_BASE_URL` in `.env`.
2. Match `AuthApiRoute` and the payloads in `RemoteAuthRepositoryImpl` to your backend.
3. Build your screens on the feature cubits (see Use). Replace `LoginScreen` (a placeholder).
4. Navigation on auth edges: in `lib/app/app_bootstrappers.dart` give `AuthBootstrapper` an `onUnauthenticated: (_) => router.goNamed(Routes.login.name)`, or `onChanged: (_, _) => router.refresh()` plus a `redirect` in the router.
5. Social login: implement `ThirdPartyAuthProvider` with `google_sign_in` / `sign_in_with_apple` (return the Google ID token; the Apple authorization code, `isFromIos`, the first-time full name, and the redirect URI on Android; throw `ThirdPartyAuthCancelled` when the sheet is closed), register it `@LazySingleton(as: ThirdPartyAuthProvider)`, delete the stub, run `dart run build_runner build`. Fill `GOOGLE_SERVER_CLIENT_ID`, `APPLE_CLIENT_ID`, `APPLE_REDIRECT_URL`.

## Use

```dart
// Login screen
BlocProvider(
  create: (_) => LoginCubit(),
  child: BlocListener<LoginCubit, LoginState>(
    listenWhen: (p, c) => p.loadingState != c.loadingState,
    listener: (context, state) {
      if (state.loadingState.isLoading) return context.showPopupLoading();
      context.hidePopupLoading();
      if (state.loadingState.isFailure) {
        CustomSnackbar.show(type: ToastType.error, message: state.error!);
      }
      // Success needs no navigation here: AuthBloc flips to authenticated.
    },
    child: const LoginView(),
  ),
);

context.read<LoginCubit>().login(email: email, password: password);

// Anywhere
final user = context.select((AuthBloc bloc) => bloc.state.user);
context.read<AuthBloc>().logout();
```

Calls that need the signed-in user pass `isTokenRequired: true` to `RemoteService`; the token is attached automatically.

## Remove

1. Delete `lib/modules/auth/` (and `lib/modules/user/` if nothing else uses it).
2. `lib/app/global_bloc_config.dart`: remove the `AuthBloc` provider.
3. `lib/app/app_bootstrappers.dart`: remove `AuthBootstrapper` (return its child).
4. `lib/app/hive_bootstrap.dart`: remove `openAuthBox` / `clearAuthBox` (and `openAuthUserBox` / `clearAuthUserBox` with the user module).
5. `lib/core/router/`: remove the `login` route and its `LoginScreen` import.
6. `dart run build_runner build`, `flutter analyze`.

The network layer keeps working: requests with `isTokenRequired: true` simply go out without a token.

## Hidden details

- Sign-in order: save tokens → `GET users/me/` → save the user → save the session. The session goes last because saving it is what flips `AuthBloc` to authenticated; if any step fails, everything saved is cleared and the error is rethrown.
- "Remember me" off: the session is dropped at the next app start (`RestoreAuthSessionUseCase`), not at once. The remembered email survives logout so the login form can prefill it.
- Registration creates the account first. If the sign-in after it fails, `RegisterUseCase` returns `false`: show "Account created, please log in" instead of an error.
- Logout never waits for the network: the server call is read first and sent in the background, then local data is cleared. Google sign-out gets at most 2 seconds.
- A forced logout (refresh failed after every retry) goes through the same `LogoutHandler`, with the server call skipped.
- `AuthState.signedOut` keeps the last user while screens close on the way to the login screen, so nothing flashes empty.
- `LoginCubit`, `RegisterCubit` and the others guard against double taps: a call while loading is ignored.
- Change password keeps every device signed in; the current tokens stay valid.
