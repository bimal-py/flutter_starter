# Dashboard

The app shell after the splash: a bottom navigation bar over the tabs, Home and Settings in the starter. Keep it for a tabbed app. Remove it if your app opens on a single screen.

## What it provides

- `DashboardScreen` (route `Routes.dashboard`, `/dashboard`): provides `BottomNavigationCubit`, then `DashboardView`.
- `DashboardView`: a `Scaffold` with `DashboardBody` and `DashboardNavBar`, and the back-button rule (see Hidden details).
- `DashboardBody`: the tab screens in a `LazyIndexedStack` (`lib/common/widgets/lazy_indexed_stack.dart`).
- `DashboardNavBar`: a Material `NavigationBar`, themed in `lib/core/theme/component_themes/navigation_bar_theme.dart`, with a hairline top border.
- `BottomNavigationCubit` (a `SafeCubit`): the selected tab, `state.currentIndex`, changed with `changePage(index)`.
- `DashboardStrings`: the tab labels and the exit toast.

## Depends on

- The home module (`HomeScreen`, tab 0) and the settings module (`SettingsScreen`, tab 1).
- `LazyIndexedStack` and `SafeCubit` from `lib/common/`; `CustomSnackbar` from `lib/core/`.
- The router: `settings`, `about` and `website-view` are child routes of `Routes.dashboard` in `lib/core/router/app_router.dart`.
- Packages: flutter_bloc, equatable, lucide_icons_flutter.

## Setup

Nothing to set up.

## Use

Add a tab: its screen in `DashboardBody`, a destination at the same position in `DashboardNavBar`, and its label in `DashboardStrings`. Import the tab's module through its top barrel.

```dart
// utils/constants/dashboard_strings.dart
static const String notes = 'Notes';

// presentation/widgets/dashboard_body.dart
children: const [HomeScreen(), NotesScreen(), SettingsScreen()],

// presentation/widgets/dashboard_nav_bar.dart, inside destinations
NavigationDestination(
  icon: Icon(LucideIcons.notebookPen),
  label: DashboardStrings.notes,
),
```

The tab's screen provides its own blocs and starts loading in `create` (`BlocProvider(create: (_) => NotesCubit()..load(), ...)`). That runs on the first visit only. A tab that needs an app bar brings its own `Scaffold`, like `SettingsScreen`. A bare scroll view, like `HomeScreen`, sits in the dashboard's `Scaffold`.

Switch tabs from inside a tab:

```dart
context.read<BottomNavigationCubit>().changePage(1);
```

To open a screen over the dashboard and keep the tabs, register it as a child route of `Routes.dashboard` (like `about`) and `context.pushNamed(...)` it.

## Remove

Keep the `Routes.dashboard` route and point it at your own first screen: the splash, onboarding and the child routes (`settings`, `about`, `website-view`) all hang on it.

1. Delete `lib/modules/dashboard/`.
2. `lib/core/router/app_router.dart`: remove `import 'package:flutter_starter/modules/dashboard/dashboard.dart';`. In the `Routes.dashboard` route, replace `builder: (context, state) => const DashboardScreen()` with your screen, for example `const Scaffold(body: SafeArea(child: HomeScreen()))` plus `import 'package:flutter_starter/modules/home/home.dart';`.
3. Settings was a tab. Open it from your screen with `context.pushNamed(Routes.settings.name)`; it is already a child route.
4. To rename the route as well, change `dashboard(...)` in `lib/core/router/routes.dart` and its callers (`grep -rn "Routes.dashboard" lib`: the router, `splash_screen.dart` and `onboarding_screen.dart`).
5. `dart run build_runner build` (nothing in this module is in DI, so the config stays the same) and `flutter analyze`.

## Hidden details

- Tabs live in a `LazyIndexedStack`. A tab is built on its first visit and then stays mounted, so its blocs, loaded data and scroll position survive tab switches, and coming back never reloads it. Refresh with pull-to-refresh, not on tab switch.
- A hidden tab isn't painted, can't be tapped and can't take focus, but it keeps running: streams, timers and animations go on.
- Android back: on another tab it returns to the first tab. On the first tab it shows "Press back again to exit"; a second press within two seconds closes the app with `SystemNavigator.pop()`. iOS has no back button, so this is Android only.
- `BottomNavigationCubit` lives in `DashboardScreen`, so the tab index survives routes pushed over the dashboard. `goNamed` to a route outside it (the onboarding replay) disposes it, and the next dashboard starts on the first tab.
- A screen pushed over the dashboard is its own page, not below `DashboardScreen`: it can't `context.read<BottomNavigationCubit>()`.
- Settings → Theme playground uses `goNamed` on a nested route (`/dashboard/settings/theme-playground`). Back from the playground shows a separate Settings page first, then the dashboard.
- `NavigationBar` needs at least two destinations. With one tab left, remove the dashboard instead.
