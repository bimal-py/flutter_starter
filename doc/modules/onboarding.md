# Onboarding

The first screens of the app: a splash, then a short swipeable intro on the first launch. The splash waits two seconds, then opens onboarding until the user finishes or skips it, and the dashboard after that. Keep it if your app should introduce itself. Keep only the splash (`features/splash/`) if it shouldn't.

## What it provides

- `SplashScreen` (`features/splash/`, route `Routes.splash`, `/`): the app logo and a progress bar while `SplashBloc` waits `AppConstants.splashDuration`, then the first route.
- `OnboardingScreen` (route `Routes.onboarding`, `/onboarding`): a carousel with Skip, page dots and Next / Get started.
- `OnboardingConstants.pages`: the pages as data (icon, title, subtitle). `OnboardingConstants.pageTransition`: the Next animation.
- `OnboardingStrings` and `SplashStrings`: all the copy.
- Widgets: `OnboardingPage`, `OnboardingDots`, `OnboardingSkipButton`, `OnboardingNextButton`, `SplashLogo`, `SplashProgress`.

## Depends on

- The app_setting module: `AppSettingCubit` (a `HydratedCubit`, provided in `lib/app/global_bloc_config.dart`) stores whether onboarding is done.
- `Routes.dashboard`: where both screens go next.
- `AppConstants.splashDuration` (`lib/core/utils/constants/app_constants.dart`) and `AssetRoutes.appLogo` (`assets/images/logos/app_logo.png`).
- Packages: flutter_bloc, equatable, hydrated_bloc (through app_setting), go_router, lucide_icons_flutter, flutter_scale_kit (through `core.dart`).

## Setup

Nothing to set up. To make it yours, replace `assets/images/logos/app_logo.png` and the pages (see Use).

## Use

Add a page: one record in `utils/constants/onboarding_constants.dart`, its copy in `utils/constants/onboarding_strings.dart`. Pages show in list order; the dots follow the list, and the last page's button reads "Get started".

```dart
// onboarding_strings.dart
static const String offlineTitle = 'Works offline';
static const String offlineSubtitle = 'Your notes stay on your phone.';

// onboarding_constants.dart, inside OnboardingConstants.pages
(
  icon: LucideIcons.wifiOff,
  title: OnboardingStrings.offlineTitle,
  subtitle: OnboardingStrings.offlineSubtitle,
),
```

The splash picks the first route in `SplashScreen._onState` (`features/splash/presentation/views/splash_screen.dart`), once `SplashBloc` reports success:

```dart
final showOnboarding = context
    .read<AppSettingCubit>()
    .state
    .showOnboardingAtAppOpen;
context.goNamed(
  showOnboarding ? Routes.onboarding.name : Routes.dashboard.name,
);
```

Change this method to add a rule (for example: signed out → `Routes.login`). Change the wait in `AppConstants.splashDuration`.

Show onboarding again from anywhere (Settings → "Show app tour again" does this):

```dart
context.read<AppSettingCubit>().requestOnboardingReplay();
context.goNamed(Routes.onboarding.name);
```

## Remove

The whole module (splash and onboarding):

1. Delete `lib/modules/onboarding/`.
2. `lib/core/router/app_router.dart`: remove `import 'package:flutter_starter/modules/onboarding/onboarding.dart';` and the `Routes.splash` and `Routes.onboarding` `GoRoute`s, and set `initialLocation: Routes.dashboard.path`.
3. `lib/core/router/routes.dart`: remove `splash(name: 'splash', path: '/')` and `onboarding(name: 'onboarding', path: '/onboarding')`.
4. `lib/common/widgets/error/error_screen.dart`: change `context.go(Routes.splash.path)` to `context.go(Routes.dashboard.path)`.
5. `lib/modules/app_upgrade/bootstrapper/app_upgrade_bootstrapper.dart`: in `_isOnSplash`, replace `return matches.last.matchedLocation == Routes.splash.path;` with `return false;`.
6. Settings: delete `lib/modules/settings/presentation/widgets/settings_replay_onboarding_tile.dart` and its export in `widgets.dart`. In `settings_screen.dart`, remove `SettingsReplayOnboardingTile()` with the "App" section header and spacing above it (the tile is the only thing in that section).
7. Optional: nothing reads `AppSettingCubit` any more. Delete `lib/modules/app_setting/` and its `BlocProvider<AppSettingCubit>` and import in `lib/app/global_bloc_config.dart`.
8. `dart run build_runner build`, so `lib/core/di/injection.config.dart` keeps no import from the deleted folder. Then `flutter analyze`.

Only the carousel (keep the splash):

1. Delete `lib/modules/onboarding/presentation/` and `lib/modules/onboarding/utils/`, and their exports in `lib/modules/onboarding/onboarding.dart`.
2. In `SplashScreen._onState`, always `context.goNamed(Routes.dashboard.name)`, and drop the now unused `app_setting` import.
3. Remove the `Routes.onboarding` `GoRoute` in `app_router.dart` and `onboarding(...)` in `routes.dart`.
4. Steps 6 and 7 above, then `flutter analyze`.

Find any other caller with `grep -rn "Routes.onboarding\|Routes.splash\|AppSettingCubit" lib`.

## Hidden details

- "Done" is one flag, `showOnboardingAtAppOpen` in `AppSettingCubit`. It defaults to `true`, so a fresh install shows onboarding. hydrated_bloc saves it in the app documents directory: it survives restarts, and clearing the app's data resets it. Android Auto Backup is on (no `allowBackup` in the manifest), so a reinstall may restore it.
- Skip and Get started both call `markOnboardingComplete()` and then open the dashboard. Closing the app mid-carousel leaves the flag `true`, so the next launch shows onboarding again.
- A replay sets the flag back to `true` before opening onboarding, so a replay left halfway also comes back on the next launch.
- hydrated_bloc keys the saved state by the cubit's runtime type name. Obfuscation or web minification can change that name between builds, and onboarding then shows once more. Override `storagePrefix` in `AppSettingCubit` with a fixed string if you ship such builds.
- Both screens leave with `goNamed`, which replaces the stack: back never returns to the splash or to onboarding.
- The splash wait is a fixed delay. It doesn't wait for anything else; start-up work belongs in `main.dart` or a global bloc (`AuthBloc` restores the session meanwhile, because it is created with `lazy: false`).
- `AppUpgradeBootstrapper` holds the update dialog until the app has left the splash route.
- `ErrorScreen`'s "Go back" falls back to the splash when there is nothing to pop, which runs the first-route decision again.
- The native launch screen (`android/app/src/main/res/drawable/launch_background.xml`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`) shows until Flutter draws its first frame. This splash comes after it.
