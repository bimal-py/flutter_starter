# Home

The dashboard's first tab: a welcome banner over a grid of demo tiles (About, Open website, Share via QR). It is a placeholder. Keep the module and replace its content with your app's home, or swap the whole tab for your own screen.

## What it provides

- `HomeScreen`, then `HomeView`: a `CustomScrollView` with `HomeHeroBanner`, a `HomeSectionLabel` and a two-column grid of `HomeFeatureCard`s.
- `HomeFeatureCard`: an icon, a label and "Open". `onTap` receives the card's own `BuildContext`.
- `HomeStrings`: all the copy. The welcome title uses `AppConstants.appName`.

## Depends on

- The dashboard module, which shows it as tab 0 (`DashboardBody`). It has no route of its own.
- The demo tiles: `Routes.about` (about module), `Routes.websiteView` with `AppUrls.demoSite` (website_view module), and `QrPopup` (qr module) with `AppUrls.appDownload`.
- Packages: go_router, lucide_icons_flutter.

## Setup

Nothing to set up.

## Use

Add a tile to the grid in `HomeView` (`presentation/views/home_screen.dart`), with its label in `utils/constants/home_strings.dart`:

```dart
HomeFeatureCard(
  icon: LucideIcons.stickyNote,
  label: HomeStrings.notes,
  onTap: (context) => context.pushNamed(Routes.notes.name), // your route
),
```

For a home that loads data, provide its cubit in `HomeScreen` and keep the UI in `HomeView`. The dashboard builds the tab once, so `load()` runs once per dashboard:

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeFeedCubit()..load(),
      child: const HomeView(),
    );
  }
}
```

## Remove

There is no home route, so `app_router.dart` and `routes.dart` don't change.

1. Delete `lib/modules/home/`.
2. `lib/modules/dashboard/presentation/widgets/dashboard_body.dart`: remove `import 'package:flutter_starter/modules/home/home.dart';` and replace `HomeScreen()` with your first tab's screen.
3. `lib/modules/dashboard/presentation/widgets/dashboard_nav_bar.dart`: change the first destination's icon, and `DashboardStrings.home` in `lib/modules/dashboard/utils/constants/dashboard_strings.dart`, to match. Keep at least two tabs; with only Settings left, remove the dashboard too (see [dashboard → Remove](dashboard.md#remove)).
4. Optional: Home is the only way into the website-view demo. If you don't need it, delete `lib/modules/website_view/`, its import and `Routes.websiteView` route in `app_router.dart`, `websiteView(...)` in `routes.dart` (it is the last entry: end `about(...)` with `;`), and `AppUrls.demoSite`. About stays reachable from Settings, and the QR popup from Settings → Share & feedback.
5. `dart run build_runner build` (nothing in this module is in DI, so the config stays the same) and `flutter analyze`.

## Hidden details

- No `Scaffold`: `HomeScreen` sits in the dashboard's `Scaffold` and `SafeArea`. Shown anywhere else, wrap it in a `Scaffold`.
- As tab 0 it is built with the dashboard and then kept alive while the user switches tabs, so its scroll position (and any loaded data) survives.
- The tiles push child routes of the dashboard (`/dashboard/about`, `/dashboard/website-view`), so back returns to Home with the tabs as they were.
- The website view takes its URL through `extra`. The route falls back to an empty string when `extra` isn't a `String`.
- `onTap` gets the card's context rather than the screen's; the QR tile opens its dialog from it.
