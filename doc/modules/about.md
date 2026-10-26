# About

A static About screen: the app description, a developer card with email, GitHub and website buttons, and the app version. Keep it if the app should say what it is and who made it; nothing else depends on it.

## What it provides

- `AboutScreen`: the screen the router builds. It builds `AboutView`.
- `AboutDescription`: a card with `AppConstants.aboutAppText`.
- `AboutDeveloperCard`: the developer's name, role and three link buttons.
- `AboutLinkButton`: an icon button that runs a launch and shows an error toast if it fails.
- `AboutSectionHeader`: the label above the developer card.
- `AboutStrings`: the module's copy, in `utils/constants/`.

## Depends on

- `package_info`: `AppVersionFooter`, which reads the app-wide `PackageInfoCubit`.
- Core: `AppConstants` (description, name, role), `AppUrls` (developer links) and `UrlHelper`.
- Packages: none that only this module uses. `lucide_icons_flutter` and `url_launcher` (through `UrlHelper`) are shared.
- Native config: none.

## Setup

1. In `lib/core/utils/constants/app_constants.dart`, replace `aboutAppText`, `developerName` and `developerRole`.
2. In `lib/core/utils/constants/app_urls.dart`, replace `developerEmail`, `developerGithub` and `developerWebsite`.

## Use

The route is `Routes.about` (`/dashboard/about`) in `lib/core/router/routes.dart`:

```dart
context.pushNamed(Routes.about.name);
```

The "About app" tile in Settings and the About card on the home screen open it this way.

## Remove

1. Delete `lib/modules/about/`.
2. In `lib/core/router/app_router.dart`, delete `import 'package:flutter_starter/modules/about/about.dart';` and the `GoRoute` for `Routes.about`.
3. In `lib/core/router/routes.dart`, delete `about(name: 'about', path: 'about'),`.
4. In `lib/modules/settings/presentation/views/settings_screen.dart`, delete `SettingsSectionHeader(label: SettingsStrings.about)`, `SettingsAboutGroup()` and the `20.verticalSpace` above them. Then delete `lib/modules/settings/presentation/widgets/settings_about_group.dart` and its line in that folder's `widgets.dart`.
5. In `lib/modules/home/presentation/views/home_screen.dart`, delete the `HomeFeatureCard` with `label: HomeStrings.about`.
6. Optional: delete `aboutAppText`, `developerName` and `developerRole` from `AppConstants`, and `developerEmail`, `developerGithub` and `developerWebsite` from `AppUrls`, once grep shows nothing else uses them.
7. Run `dart run build_runner build` and `flutter analyze`.

## Hidden details

- The email button opens `mailto:<developerEmail>` with `UrlHelper.launch`, so the mail has no subject or body.
- A failed launch shows the error in a toast, for example "Could not open <url>" from `UrlHelper`.
- Lucide ships no brand logos, so the GitHub button uses the code icon.
- The version line stays empty until `PackageInfoCubit` has loaded. It loads at app start (`lazy: false` in `lib/app/global_bloc_config.dart`).
