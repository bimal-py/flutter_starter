# Package info

Reads the app's name, package id, version and build number once at start-up and keeps them in an app-wide cubit. It ships `AppVersionFooter`, the "Version 1.0.0 (1)" line at the bottom of Settings and About. Keep it while something shows or sends the version.

## What it provides

- `PackageInfoCubit` (`presentation/bloc/package_info/`): `load()`; state `loadingState`, `packageInfo`, `error`. Provided app-wide in `lib/app/global_bloc_config.dart`.
- `PackageInfoEntity` (`domain/entity/`): `appName`, `packageName`, `version`, `buildNumber`, `buildSignature`.
- `AppVersionFooter` (`presentation/widgets/`): the centred version line.
- `GetPackageInfoUseCase` (DI `@injectable`), `RemotePackageInfoRepository` and `RemotePackageInfoRepositoryImpl` (DI `@LazySingleton`).
- `PackageInfoStrings.version(version, buildNumber)`.

## Depends on

- `package_info_plus`, also used by the [app_upgrade](app_upgrade.md) module (`RemoteConfigHelper` reads the installed version).
- The values come from `version:` in `pubspec.yaml` (`1.0.0+1`: version `1.0.0`, build `1`) through Flutter's build settings: `FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER` in `ios/Runner/Info.plist`, `flutter.versionName` / `flutter.versionCode` in `android/app/build.gradle.kts`.
- No other module, no `.env` keys.

## Setup

Nothing to set up. Raise `version:` in `pubspec.yaml` for every release.

## Use

```dart
// At the bottom of a ListView
const AppVersionFooter(),

// Anywhere else
final version = context.select(
  (PackageInfoCubit cubit) => cubit.state.packageInfo?.version,
);
```

## Remove

1. Delete `lib/modules/package_info/`.
2. `lib/app/global_bloc_config.dart`: remove `import 'package:flutter_starter/modules/package_info/package_info.dart';` and the `BlocProvider<PackageInfoCubit>(...)` block (`create: (_) => PackageInfoCubit()..load()`).
3. `lib/modules/settings/presentation/views/settings_screen.dart` and `lib/modules/about/presentation/views/about_screen.dart`: remove the `package_info` import and `const AppVersionFooter(),`.
4. `lib/modules/settings/utils/helper/feedback_email_helper.dart`: remove the `package_info` import, the `_formatPackageInfo(...)` line in `sendEmail` and the `_formatPackageInfo` method.
5. `pubspec.yaml`: remove `package_info_plus` only if the app_upgrade module is gone too.
6. `dart run build_runner build` (drops `RemotePackageInfoRepositoryImpl` and `GetPackageInfoUseCase` from `lib/core/di/injection.config.dart`), then `flutter analyze`.

## Hidden details

- Loaded once at start-up (`lazy: false`). Until then, and after a failure, `packageInfo` is null and `AppVersionFooter` renders nothing: no shimmer and no error view for one line of diagnostics.
- A failure stays in the state (`loadingState` failure, `error`); nothing is shown.
- `buildSignature` is the SHA-256 of the Android signing key (hex); it is empty on the other platforms.
- The footer reads the cubit from the tree: it works on any screen under `GlobalBlocConfig`, and throws if you use it outside (a test without the provider, say).
