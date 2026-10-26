# Settings

The dashboard's Settings tab: System / Light / Dark mode, a theme playground ("Customize theme"), an app tour replay, share, rate and report actions, and a link to About. Keep it as the base of your app's settings screen and add or remove tiles to suit.

## What it provides

- `SettingsScreen`: the Settings tab. It builds `SettingsView`, a list of grouped tiles.
- `ThemePlaygroundScreen`: "Customize theme". It builds `ThemePlaygroundView` (brightness, presets, source, preview).
- `SettingsTile`: one row with a tinted icon, a label, and an optional subtitle and trailing widget.
- `SettingsSectionHeader`: the small upper-case label above a group.
- `SettingsAppCard`: the app name card at the top of the tab.
- `SettingsThemePicker` and `SettingsThemeOption`: the System / Light / Dark switch.
- `SettingsThemePlaygroundTile`: opens the playground. Its subtitle says which kind of custom theme is on.
- `SettingsReplayOnboardingTile`: "Show app tour again".
- `SettingsShareFeedbackGroup`: share app QR, rate the app, report a problem.
- `SettingsAboutGroup`: opens the About screen.
- `ThemePlaygroundStatusBanner`: says whether a custom theme is on, with a Reset button.
- `ThemePlaygroundPresetPicker` and `ThemePlaygroundPresetChip`: one chip per entry in `ThemePresets.all`.
- `ThemePlaygroundSourcePicker` and `ThemePlaygroundSourceTile`: seed color, device colors or an image.
- `ThemePlaygroundSeedSwatches` and `ThemePlaygroundSeedSwatch`: the 12 seed colors.
- `ThemePlaygroundCustomColorButton` and `ThemePlaygroundColorDialog`: the "+" swatch and its color picker dialog.
- `ThemePlaygroundImageControls`: the picked image and the pick button.
- `ThemePlaygroundPreview`: stock Material widgets drawn with the current theme.
- `FeedbackEmailHelper.sendEmail()`: opens the mail app with device and app version lines in the body.
- `SettingsStrings` and `SettingsError`: the module's copy, in `utils/constants/`.

## Depends on

- `app_setting`: `AppSettingCubit.requestOnboardingReplay()` for the tour replay.
- `package_info`: `AppVersionFooter` at the bottom of the tab, and `PackageInfoCubit` for the report email.
- `device_info`: `DeviceInfoCubit` for the report email.
- `qr`: `QrPopup` for "Share app QR".
- Theme in core: `ThemeCubit`, `ThemePresets` and the `ThemeSource` types in `lib/core/theme/`.
- Common: `context.showPopupLoading()` while an image is picked.
- The cubits above are app-wide. They are provided in `lib/app/global_bloc_config.dart`.
- Routes it opens: `Routes.themePlayground`, `Routes.about` (the about module) and `Routes.onboarding` (the onboarding module).
- Packages only this module uses: `flutter_colorpicker` (custom color dialog) and `in_app_review` (rate the app).
- Shared packages: `image_picker` (also used by `lib/modules/image_picker/`), `lucide_icons_flutter`, and `url_launcher` through `UrlHelper`.
- Native config: iOS needs `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist` for the gallery pick. It is already there. Android needs nothing.

## Setup

1. In `lib/core/utils/constants/app_constants.dart`, set `appIosAppId` (the App Store ID that "Rate the app" falls back to on iOS) and `appAndroidPackageId` (the file name of the QR image the popup saves or shares).
2. In `lib/core/utils/constants/app_urls.dart`, set `supportEmail` (where reports go) and `appDownload` (what the QR encodes).
3. Optional: call `ThemePresets.register([...])` in `main()`, before the app builds, to show your own presets.

## Use

Both routes in `lib/core/router/routes.dart` sit under `/dashboard`:

```dart
context.goNamed(Routes.themePlayground.name); // /dashboard/settings/theme-playground
context.pushNamed(Routes.settings.name); // /dashboard/settings, as its own page
```

The tab itself is `SettingsScreen()` in `lib/modules/dashboard/presentation/widgets/dashboard_body.dart`.

To add tiles, make a group widget in `presentation/widgets/` and export it from `widgets.dart`. Its copy goes in `SettingsStrings` (add `legal`, `privacyPolicy` and `terms` for this example). This group opens pages in the web view:

```dart
class SettingsLegalGroup extends StatelessWidget {
  const SettingsLegalGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SettingsTile(
            icon: LucideIcons.shieldCheck,
            label: SettingsStrings.privacyPolicy,
            onTap: () => context.pushNamed(
              Routes.websiteView.name,
              extra: AppUrls.privacyPolicy,
            ),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: LucideIcons.fileText,
            label: SettingsStrings.terms,
            onTap: () => context.pushNamed(
              Routes.websiteView.name,
              extra: AppUrls.termsOfService,
            ),
          ),
        ],
      ),
    );
  }
}
```

Then list it in `SettingsView` (`presentation/views/settings_screen.dart`):

```dart
const SettingsSectionHeader(label: SettingsStrings.legal),
const SettingsLegalGroup(),
20.verticalSpace,
```

## Remove

1. Delete `lib/modules/settings/`.
2. In `lib/core/router/app_router.dart`, delete `import 'package:flutter_starter/modules/settings/settings.dart';` and the `GoRoute` for `Routes.settings`, with the `Routes.themePlayground` route nested in it.
3. In `lib/core/router/routes.dart`, delete `settings(name: 'settings', path: 'settings'),` and `themePlayground(name: 'theme-playground', path: 'theme-playground'),`.
4. In `lib/modules/dashboard/presentation/widgets/dashboard_body.dart`, delete the settings import and `SettingsScreen()` from `children`.
5. In `lib/modules/dashboard/presentation/widgets/dashboard_nav_bar.dart`, delete the Settings `NavigationDestination`, and `DashboardStrings.settings` if nothing else uses it. `NavigationBar` needs at least two destinations, so put your own tab in its place or remove the dashboard ([dashboard.md](dashboard.md)).
6. In `pubspec.yaml`, delete `flutter_colorpicker` and `in_app_review`. Keep `image_picker` unless you also remove `lib/modules/image_picker/`.
7. Run `flutter pub get`, `dart run build_runner build` and `flutter analyze`.

To remove only the theme playground:

1. Delete `presentation/views/theme_playground_screen.dart`, `presentation/widgets/theme_playground/` and `presentation/widgets/settings_theme_playground_tile.dart`, and their lines in `views.dart` and `widgets.dart`.
2. In `SettingsView`, delete `const SettingsThemePlaygroundTile()` and the `8.verticalSpace` above it.
3. In `app_router.dart`, delete the `GoRoute` for `Routes.themePlayground`. In `routes.dart`, delete `themePlayground(...)`.
4. In `pubspec.yaml`, delete `flutter_colorpicker`.
5. Run `flutter analyze`.

## Hidden details

- Theme choices persist. `ThemeCubit` is a `HydratedCubit`, so the mode and the playground's `userOverride` survive restarts. There is no Save button: each choice applies at once.
- Reset calls `clearUserOverride()`, which goes back to the developer's source (`AppColors.seed` unless you pass `developerSource` to `ThemeCubit`). That source is saved too, so a later brand change reaches existing installs only after their data is cleared ([theme.md](../core/theme.md)).
- A picked image is stored as a file path, not pixels. `applyUserImage` first applies a `FromImageSource` (drawn with the fallback seed), then swaps it for a `SeedOnlySource` of the extracted color. If extraction fails, the `FromImageSource` stays.
- Extraction is not on a background isolate. `ThemeCubit` samples every 16th pixel of the image (picked at most 1024 px wide) on the main isolate, reduces them to 16 colors and takes the best-scored one. The hint under the pick button claims a background isolate; that copy is wrong.
- The popup loader covers the whole image pick: the gallery, then the extraction.
- Presets match by seed color only. The default seed, `AppColors.seed` (`0xFF1B3A6B`), is also the Midnight preset's seed, so Midnight shows as selected on a fresh install.
- The source picker reads the active source once, when the screen opens. Tapping a preset afterwards does not move its selection.
- "Dynamic device colors" uses the device colors that `DynamicColorBuilder` in `lib/app/app_view.dart` provides (the wallpaper colors on Android 12+). Where there are none, it uses the current seed.
- "Customize theme" uses `goNamed`, so the stack becomes dashboard, Settings page, playground. Back from the playground lands on Settings as its own page (`/dashboard/settings`), not on the tab. Use `pushNamed` if back should return to the tab.
- "Show app tour again" sets `showOnboardingAtAppOpen` and replaces the stack with the tour. Finishing the tour clears the flag. If the app closes mid-tour, the next launch shows the tour again.
- "Rate the app" calls `requestReview()` when in-app review is available, and opens the store listing otherwise. The OS rate-limits the review sheet, so a tap can show nothing. On Android the sheet only shows for an app installed from Google Play.
- "Report a problem" writes to `AppUrls.supportEmail` with the subject "Report from user (app name)". The body holds the device and OS (for example `Device: <brand> <model>` and `OS: Android <release> (API <sdk>)`) and `App Version: <version> (<build>)`, from the app-wide `DeviceInfoCubit` and `PackageInfoCubit`. Before they load, it says `Device: Unknown Platform` and `App Version: N/A`. With no mail app, a toast says "No email app available".
