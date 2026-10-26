# Routing

`lib/core/router/` holds the `Routes` enum, the one `GoRouter` (go_router), a debug navigation logger and `AssetRoutes` for asset paths.
The rule: every screen has a `Routes` entry and a `GoRoute` in `app_router.dart`, and code navigates by name (`context.goNamed(Routes.about.name)`), never by a hand-typed path.

## Where it lives

```
lib/core/router/
├── routes.dart          enum Routes: name + path of every screen
├── app_router.dart      top-level `router` (GoRouter) and `navigatorKey`
├── observers/           AppNavigatorObserver: logs push / pop / replace (debug only)
└── asset_routes.dart    AssetRoutes: constants for files under assets/
lib/common/widgets/error/error_screen.dart   ErrorScreen, the router's errorBuilder
```

The tree today:

```
/                          splash            SplashScreen
/onboarding                onboarding        OnboardingScreen
/login                     login             LoginScreen
/dashboard                 dashboard         DashboardScreen
  /dashboard/settings      settings          SettingsScreen
    /dashboard/settings/theme-playground
                           themePlayground   ThemePlaygroundScreen
  /dashboard/about         about             AboutScreen
  /dashboard/website-view  websiteView       WebsiteViewScreen (extra: the URL)
```

## How to use

```dart
context.goNamed(Routes.dashboard.name); // replaces the stack
context.pushNamed(Routes.about.name); // on top of the current page
context.pushNamed(Routes.websiteView.name, extra: AppUrls.demoSite);
context.pop();
```

Above the navigator (bootstrappers, services) there is no router context: use the top-level `router` (`router.goNamed(Routes.login.name)`), and `navigatorKey.currentContext` to show a dialog.

**Arguments.** One value can go as is in `extra` (the website view takes a `String`). More than one: a `<Screen>Args` class in the module's `argument/` folder ([conventions](../conventions.md)). Example for a `resetPassword` route you add:

```dart
class ResetPasswordArgs extends Equatable {
  const ResetPasswordArgs({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

// Navigate
context.pushNamed(
  Routes.resetPassword.name,
  extra: ResetPasswordArgs(email: email),
);

// app_router.dart
GoRoute(
  name: Routes.resetPassword.name,
  path: Routes.resetPassword.path,
  builder: (context, state) {
    final args = state.extra;
    if (args is! ResetPasswordArgs) return const ErrorScreen();
    return ResetPasswordScreen(email: args.email);
  },
),
```

**Asset paths.** Reference files through `AssetRoutes` (`appLogo`, `appLogoSvg`, `defaultAvatar`, `defaultImage`, `noDataFound`):

```dart
Image.asset(AssetRoutes.appLogo, width: 96.r);
SvgViewer(AssetRoutes.noDataFound, width: 160.r, height: 160.r);
```

## How to change / extend

**Add a route**

1. Add an entry to `Routes`: `notes(name: 'notes', path: '/notes')` for a top-level page, or `path: 'notes'` (no leading `/`) for a child.
2. Register `GoRoute(name: Routes.notes.name, path: Routes.notes.path, builder: (context, state) => const NotesScreen())` in `app_router.dart`: in the top `routes:` list, or in the parent's `routes:`.
3. Import the module's top barrel (`package:flutter_starter/modules/note/note.dart`) in `app_router.dart`.
4. Navigate with `goNamed` / `pushNamed`.

**Nested routes**

1. A child's `path` is relative: `settings` under `/dashboard` is `/dashboard/settings`.
2. `goNamed` to a child builds the whole chain. Going to `themePlayground` stacks Dashboard → Settings → ThemePlayground, so back returns to Settings.
3. `pushNamed` adds only the target on top of whatever is showing.
4. A value that must survive a deep link goes in the path (`path: 'notes/:id'`, read `state.pathParameters['id']`), not in `extra`.

**Add an auth guard**

1. In `lib/app/app_bootstrappers.dart`, give `AuthBootstrapper` an `onChanged: (_, _) => router.refresh()`, so the guard runs again when the session changes.
2. In `app_router.dart`, decide in `redirect` (import `flutter_bloc` for `context.read`):

   ```dart
   redirect: (context, state) {
     FirebaseService.logScreenView(state.fullPath ?? state.path ?? state.name);
     final auth = context.read<AuthBloc>().state;
     if (auth.status.isInitial) return null; // session still loading
     final location = state.matchedLocation;
     final isPublic = {
       Routes.splash.path,
       Routes.onboarding.path,
       Routes.login.path,
     }.contains(location);
     if (!auth.isAuthenticated && !isPublic) return Routes.login.path;
     if (auth.isAuthenticated && location == Routes.login.path) {
       return Routes.dashboard.path;
     }
     return null;
   },
   ```

3. With the guard, `AuthBloc` decides; screens stop navigating on sign-in and sign-out themselves. See the [auth module](../modules/auth.md).

**Change the error page**: `errorBuilder` builds `ErrorScreen(message: state.error?.toString())`; replace the message or the widget there.

**Add an asset**: put the file under `assets/images/...`, list its folder under `flutter: assets:` in `pubspec.yaml`, add a constant to `AssetRoutes`.

## Hidden details

- `router` is a top-level `final`, created the first time `StarterAppView` builds. That is after `FirebaseService.init()`, so `?FirebaseService.analyticsObserver` (a null-aware list element) adds the analytics observer only when Firebase is on.
- With Firebase on, each screen view is logged twice: by `redirect` (the path, `/dashboard/settings`) and by `FirebaseAnalyticsObserver` (the route name, `settings`). Keep one of the two.
- `redirect` runs before every `go` and `push`, on `router.refresh()`, and again after `context.pop()` (go_router 17 restores the page below through the parser). Keep it fast: what it does, like the screen-view log, happens each time. Its `context` sits below `GlobalBlocConfig`, so app-wide blocs can be read there.
- With a guard, a redirected navigation logs the requested path and then the final one. Log after the decision if that matters.
- `extra` is not part of the URL. It is gone after a deep link or a web reload, so check its type (`is!`) instead of casting.
- Route names must be unique in the whole tree. Child paths never start with `/`.
- `ErrorScreen` shows `state.error.toString()` (raw go_router text) under "Something went wrong". Its "Go back" pops, or goes to the splash route when there is nothing to pop.
- `core/` never imports a module, except here: the router has to list the screens.
- `AppNavigatorObserver` logs through `CustomLogger`, which prints in debug builds only.
- `pubspec.yaml` asset folders are not recursive: each sub-folder needs its own line.
