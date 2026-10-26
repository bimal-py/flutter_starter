# App upgrade

Shows an "Update available" dialog when Firebase Remote Config says a newer version is out. You drive it from the Firebase console: the latest version, an HTML changelog, a switch per platform and a force-update mode. Keep it when the app ships through the stores and you use Firebase. Without Firebase it does nothing.

## What it provides

- `AppUpgradeCubit` (`presentation/bloc/app_upgrade/`): `checkForUpdate()` reads Remote Config and sets `state.status` (`idle`, `checking`, `updateAvailable`, `upToDate`) with `latestVersion`, `updateMessage` and `isForceUpdate`. `ignoreCurrentReleasedVersion()` remembers the version the user ignored.
- `AppUpgradeBootstrapper` (`bootstrapper/`): runs the check after the first frame and opens the dialog once the app has left the splash route. Wired in `lib/app/app_bootstrappers.dart`.
- `UpdateAppPopup` (`presentation/widgets/`): the dialog. "Update now" opens the store page; "Remind me later" and "Ignore" are there unless the update is forced.
- `RemoteConfigService` (`utils/helper/`): the Remote Config singleton and its in-app defaults. `RemoteConfigHelper`: the installed version, the version comparison, the ignored version in Hive.
- `AppUpgradeConstants` (Remote Config keys, store URLs, fetch interval and timeout) and `AppUpgradeStrings` (dialog copy and the fallback message).
- `firebase_remote_config_template.json`: the five parameters, ready to import into the Firebase console.

## Depends on

- Firebase: `FirebaseService.init()` in `lib/main.dart` must succeed (`FIREBASE_ENABLED=true` in `.env`, `flutterfire configure` done). Until then `RemoteConfigService.init()` returns at once and every check ends `upToDate`.
- Packages only this module uses: `firebase_remote_config`, `flutter_widget_from_html`. Shared: `package_info_plus` (also the [package_info](package_info.md) module), `hive_flutter` (the app box), `url_launcher` through `UrlHelper`.
- Core: `router`, `navigatorKey` and `Routes.splash` (`lib/core/router/`), `Hive.appBox` (`lib/core/utils/helpers/hive_helper.dart`), `AppConstants.appIosAppId` and `AppConstants.appAndroidPackageId`.
- No native keys and no DI classes.

## Setup

1. Set up Firebase: [getting started](../getting_started.md#3-set-up-firebase-only-if-you-use-it), then uncomment the `firebase_options.dart` import and the `options:` line in `lib/core/services/firebase_service.dart`.
2. In `lib/core/utils/constants/app_constants.dart`, set `appIosAppId` (the number in your App Store URL) and `appAndroidPackageId`.
3. In the Firebase console, open Remote Config and import `lib/modules/app_upgrade/firebase_remote_config_template.json`, or add the five parameters below by hand. Publish.
4. For each release, raise `latest_released_app_version` and write its `update_message`.

The wiring is already in place: `AppUpgradeCubit` in `lib/app/global_bloc_config.dart`, `AppUpgradeBootstrapper` in `lib/app/app_bootstrappers.dart`.

| Parameter | Type | In-app default | Effect |
|---|---|---|---|
| `latest_released_app_version` | string | `0.0.0` | The dialog shows when the installed version is lower. |
| `update_message` | string (HTML) | `AppUpgradeStrings.defaultUpdateMessage` | The dialog body. |
| `enabled_on_ios` | bool | `true` | Off: never shows on iOS. |
| `enabled_on_android` | bool | `true` | Off: never shows on Android (and any other non-iOS platform). |
| `force_update` | bool | `false` | Only "Update now"; back does nothing; an ignored version shows again. |

## Use

The dialog appears by itself. To check again by hand (a debug menu, say):

```dart
context.read<AppUpgradeCubit>().checkForUpdate();
```

To read the result elsewhere:

```dart
final hasUpdate = context.select(
  (AppUpgradeCubit cubit) => cubit.state.status.isUpdateAvailable,
);
```

To try it: set `latest_released_app_version` above the `version:` in `pubspec.yaml`, publish, and restart a debug build (debug builds fetch on every launch).

## Remove

1. Delete `lib/modules/app_upgrade/`.
2. `lib/app/app_bootstrappers.dart`: remove `import 'package:flutter_starter/modules/app_upgrade/app_upgrade.dart';` and the `AppUpgradeBootstrapper(` wrap with its `// Optional. Remove with lib/modules/app_upgrade/.` comment, so `build` returns `AuthBootstrapper(child: child)`.
3. `lib/app/global_bloc_config.dart`: remove `import 'package:flutter_starter/modules/app_upgrade/app_upgrade.dart';` and `BlocProvider<AppUpgradeCubit>(create: (_) => AppUpgradeCubit()),` with the comment above it.
4. `pubspec.yaml`: remove `firebase_remote_config` (and its comment line) and `flutter_widget_from_html`. Keep `package_info_plus` while the package_info module stays.
5. Optional: delete the parameters in the Firebase console. The `ignored_app_version` entry left in the Hive `app_box` is harmless.
6. `dart run build_runner build`, then `flutter analyze`.

## Hidden details

- Version comparison is dotted integers, a missing part counting as 0: `1.2` equals `1.2.0`, `1.10.0` is newer than `1.9.0`. Anything else (`1.3.0-beta`) counts as "not newer", so a typo in the console can't force the dialog. The installed version is `package_info_plus`'s `version`, cut at any `+`.
- The in-app default for `latest_released_app_version` is `0.0.0`, so nothing shows before the first successful fetch. The template's default, `1.0.0`, equals the starter's `pubspec.yaml` version.
- Each check calls `fetchAndActivate` with a 1-minute timeout. The minimum fetch interval is zero in debug and one hour in release, so a console change can take an hour to reach release builds. A failed fetch (offline) leaves the service uninitialised and the next check retries; any failure ends the check `upToDate`.
- The dialog opens at most once per launch (a static flag in the bootstrapper) and never on the splash route: the bootstrapper listens to the router and waits for the next route. A second `checkForUpdate()` in the same launch updates the state but opens nothing.
- "Ignore" saves the version in the Hive `app_box` under `ignored_app_version`, and that version is skipped until a newer one is published. `force_update` ignores it. "Remind me later" (or back) only closes the dialog; the next launch asks again.
- When forced, the dialog can't be closed: `barrierDismissible: false`, `PopScope(canPop: false)`, no other buttons. "Update now" opens the store and leaves the dialog up.
- Store links: `https://apps.apple.com/app/id<appIosAppId>` on iOS, `https://play.google.com/store/apps/details?id=<appAndroidPackageId>` everywhere else. If the link can't open, a toast says so.
- The bootstrapper sits above the navigator, so it shows the dialog through `navigatorKey`'s overlay, one frame after the route change so the new screen has built first.
- `update_message` goes through `flutter_widget_from_html`: `<p>`, `<b>`, `<i>`, `<ul>`, `<li>`, `<h3>`, `<br>` work. Long text scrolls inside the dialog.
