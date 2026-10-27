# Routing

`lib/core/router/` holds the `Routes` enum, the one `GoRouter` (go_router), a debug navigation logger and `AssetRoutes` for asset paths.
The rule: every screen you navigate to has a `Routes` entry and a `GoRoute` in `app_router.dart`, and code navigates by name (`context.goNamed(Routes.about.name)`), never by a hand-typed path. Dashboard tabs such as `HomeScreen` are not routes; the dashboard builds them.

## Where it lives

```
lib/core/router/
├── router.dart          barrel
├── routes.dart          enum Routes: name + path of every route
├── app_router.dart      top-level `router` (GoRouter) and `navigatorKey`
├── observers/           AppNavigatorObserver: logs push, pop, remove, replace and back gestures (debug only)
└── asset_routes.dart    AssetRoutes: constants for files under assets/
lib/common/widgets/error/error_screen.dart   ErrorScreen, shown by the router's errorBuilder
```

The tree today (path, `Routes` entry, screen):

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

Each entry's `name` field is the entry in kebab-case, so `Routes.themePlayground.name` is `theme-playground` (the field hides Dart's own `Enum.name`). Logs and analytics show that name.

## How to use

```dart
context.goNamed(Routes.dashboard.name); // replaces the stack
context.pushNamed(Routes.about.name); // on top of the current page
context.pushNamed(Routes.websiteView.name, extra: AppUrls.demoSite);
context.pop();
```

Above the navigator (bootstrappers, services) there is no router context: use the top-level `router` (`router.goNamed(Routes.login.name)`), and `navigatorKey.currentContext` to show a dialog.

**Arguments.** One value can go as is in `extra` (the website view takes a `String`). More than one: a `<Subject><Screen>Args` class in the module's `argument/` folder ([names](../conventions.md#names), [module layout](../project_structure.md#a-module)). Example for a `resetPassword` route you add, which needs the email and the seconds left on the emailed code (for the resend countdown):

```dart
class ResetPasswordArgs extends Equatable {
  const ResetPasswordArgs({required this.email, required this.expiresIn});

  final String email;
  final int expiresIn;

  @override
  List<Object?> get props => [email, expiresIn];
}

// Navigate
context.pushNamed(
  Routes.resetPassword.name,
  extra: ResetPasswordArgs(email: email, expiresIn: expiresIn),
);

// app_router.dart
GoRoute(
  name: Routes.resetPassword.name,
  path: Routes.resetPassword.path,
  builder: (context, state) {
    final args = state.extra;
    if (args is! ResetPasswordArgs) return const ErrorScreen();
    return ResetPasswordScreen(email: args.email, expiresIn: args.expiresIn);
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
2. `goNamed` to a child builds the whole chain. Going to `themePlayground` stacks Dashboard → Settings → ThemePlayground, so back returns to the Settings page (`/dashboard/settings`), not to the dashboard's Settings tab.
3. `pushNamed` adds only the target on top of whatever is showing.
4. A value that must survive a deep link goes in the path (`path: 'notes/:id'`, read `state.pathParameters['id']`), not in `extra`.

**Add an auth guard**

1. In `lib/app/app_bootstrappers.dart`, give `AuthBootstrapper` an `onChanged: (_, _) => router.refresh()` (import `core/core.dart` for `router`), so the guard runs again when the session changes.
2. In `app_router.dart`, decide in `redirect` (import `flutter_bloc` for `context.read`):

   ```dart
   redirect: (context, state) {
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

3. With the guard, `AuthBloc`'s state decides where the user lands; screens and `AuthBootstrapper` don't call `goNamed` on sign-in or sign-out. See the [auth module](../modules/auth.md).

**Change the error page**: `errorBuilder` logs go_router's error and builds `ErrorScreen(message: AppErrorStrings.pageNotFound)`; replace the message or the widget there.

**Add an asset**: put the file under `assets/images/...`, list its folder under `flutter: assets:` in `pubspec.yaml`, add a constant to `AssetRoutes`. An asset only one module uses keeps its constant in that module, so it goes with the module: the house-ad logos in `assets/images/ads/` are `SelfPromotionAssets` in mobile_ads.

## Hidden details

- `router` is a top-level `final`, created the first time `StarterAppView` builds. That is after `FirebaseService.init()`, so `?FirebaseService.analyticsObserver` (a null-aware list element) adds the analytics observer only when Firebase is on.
- With Firebase on, `FirebaseAnalyticsObserver` logs a screen view, by route name (`settings`, not `/dashboard/settings`), for each page the root navigator adds and for the page a pop uncovers; dialogs and sheets are skipped. A `go` that stacks new pages logs each of them: "Customize theme" (`goNamed(Routes.themePlayground.name)` from `/dashboard`) logs `settings` and `theme-playground`. Calling `FirebaseService.logScreenView` for a routed screen counts it twice. A nested navigator needs an observer of its own.
- The router has no `redirect` until you add a guard. A `redirect` runs before every `go` and `push`, on `router.refresh()`, and again after `context.pop()` (go_router 17 restores the page below through the parser), so keep it fast. Its `context` sits below `GlobalBlocConfig`, so app-wide blocs can be read there.
- `extra` is not part of the URL. It is gone after a deep link or a web reload, so check its type (`is!`) instead of casting.
- Route names must be unique in the whole tree (go_router asserts it). A leading `/` does not make a child top-level: go_router 17 reads `'/notes'` under `/dashboard` as `/dashboard/notes`. The starter writes child paths without one.
- `ErrorScreen` shows "This page doesn't exist." under "Something went wrong"; the raw go_router text goes to the log (`CustomLogger`, debug builds only). Its "Go back" pops, or goes to the splash route when there is nothing to pop.
- `core/` never imports a module, except here (the router has to list the screens) and in the generated `lib/core/di/injection.config.dart`.
- `AppNavigatorObserver` logs through `CustomLogger`, which prints in debug builds only.
- `pubspec.yaml` asset folders are not recursive: each sub-folder needs its own line.
