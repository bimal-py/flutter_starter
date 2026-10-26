# Modules

Every feature lives in `lib/modules/<module>/`. Each page below says what the module gives you, what it needs, how to use it, and how to remove it. The removal steps always have the same shape:

1. Delete `lib/modules/<module>/`.
2. Remove its lines from the composition points. Each one is marked `// Optional. Remove with lib/modules/<module>/.` (`lib/main.dart`, `lib/app/*.dart`, `lib/core/router/*.dart`).
3. Remove the packages and native keys only that module used.
4. `dart run build_runner build`, then `flutter analyze`.

## Catalog

| Module | What it is | Needs | Used by |
|---|---|---|---|
| [auth](auth.md) | Sign-in state, login, sign-up, password flows, Google / Apple hooks, token refresh, logout | user | none |
| [user](user.md) | The signed-in person: `UserEntity`, the saved copy, `users/me/` | none | auth |
| [pagination](pagination.md) | Paged lists: one page size, typed pages, auto-loading list widgets | none | none (ready for your lists) |
| [onboarding](onboarding.md) | Splash, then a swipeable intro on the first launch | app_setting | none |
| [app_setting](app_setting.md) | App-wide flags that survive a restart (onboarding done) | none | onboarding, settings |
| [dashboard](dashboard.md) | The bottom-bar shell after the splash | home, settings | none |
| [home](home.md) | Tab 0: a placeholder grid of demo tiles | about, website_view, qr (demo tiles) | dashboard |
| [settings](settings.md) | Tab 1: theme mode, theme playground, tour replay, share, rate, report | app_setting, package_info, device_info, qr | dashboard |
| [about](about.md) | The About screen | package_info | home, settings |
| [website_view](website_view.md) | An in-app browser for one URL | none | home |
| [qr](qr.md) | A QR dialog with save and share | none | home, settings |
| [image_picker](image_picker.md) | Camera or gallery photos through a sheet, compressed | none | none |
| [notifications](notifications.md) | Local notifications: show, schedule, cancel, taps | none | fcm (bridge) |
| [fcm](fcm.md) | Firebase push: token, topics, permission, messages | Firebase; notifications for the bridge | none |
| [app_upgrade](app_upgrade.md) | "Update available" dialog from Firebase Remote Config | Firebase, package_info's package | none |
| [mobile_ads](mobile_ads.md) | AdMob ads with consent and ATT, house ads, an ad-free switch | none | none |
| [package_info](package_info.md) | App name and version in an app-wide cubit, `AppVersionFooter` | none | settings, about |
| [device_info](device_info.md) | Device model and OS in an app-wide cubit | none | settings (report email) |

"Needs": the modules this one imports, so removing one of those breaks this one. "Used by": the modules that import this one, so removing this one means editing them too (their pages say how), or removing them together.

## Common combinations

- **No accounts**: remove auth and user. Nothing else changes.
- **No Firebase**: remove fcm and app_upgrade. Core's `FirebaseService` stays and does nothing while `FIREBASE_ENABLED=false`.
- **No ads**: remove mobile_ads, and the AdMob ids and `NSUserTrackingUsageDescription` it lists.
- **One screen, no tabs**: remove dashboard and home, point the splash at your screen, and move settings and about to the top level of the router.

## Not modules

Theme, routing, DI, network, storage, errors, permissions and sizing are core. They stay in every app: see [core](../README.md#core-always-present).
