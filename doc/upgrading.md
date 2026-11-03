# Upgrading

How to move the starter (or an app built from it) to newer Flutter and packages, and what was deliberately held back.

## Current baseline

- Flutter 3.47, Dart 3.13 (`environment` in `pubspec.yaml` matches what the packages need).
- Android: AGP 9.1.0, Kotlin 2.4.0, Gradle 9.3.1, `compileSdk 37`, `minSdk 24` and `targetSdk 36` (Flutter defaults), Java 17.
- iOS: deployment target 15.0 (Podfile and Xcode project), CocoaPods.

## Steps

1. `flutter upgrade`.
2. `flutter pub upgrade --major-versions`, then `flutter pub outdated` to see what stayed behind and why. `--major-versions` also lifts the three holds below (`go_router`, `dynamic_color`, `cached_network_image`); put those constraints back.
3. Read the changelog of every package that changed major version (`~/.pub-cache/hosted/pub.dev/<package>-<version>/CHANGELOG.md`). Look for "BREAKING", minimum SDK, minSdk, compileSdk, iOS deployment target.
4. `flutter analyze` and fix the errors. Then fix the deprecations (or note why one stays).
5. Native: create a throwaway project with the new Flutter and diff its platform files against yours:

   ```sh
   flutter create --org com.example --project-name flutter_starter /tmp/fresh
   diff /tmp/fresh/android/settings.gradle.kts android/settings.gradle.kts
   diff /tmp/fresh/android/app/build.gradle.kts android/app/build.gradle.kts
   diff /tmp/fresh/android/gradle/wrapper/gradle-wrapper.properties android/gradle/wrapper/gradle-wrapper.properties
   diff /tmp/fresh/android/gradle.properties android/gradle.properties
   diff /tmp/fresh/android/app/src/main/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
   diff /tmp/fresh/ios/Runner/AppDelegate.swift ios/Runner/AppDelegate.swift
   diff /tmp/fresh/ios/Runner/Info.plist ios/Runner/Info.plist
   ```

   Copy the version bumps; keep your own additions: `compileSdk = 37` and desugaring in `app/build.gradle.kts`, manifest entries, permissions, Info.plist keys, and the `UNUserNotificationCenter` delegate in `AppDelegate.swift`.
6. Build both platforms and smoke-test start-up, login, push and ads.

## Held back on purpose

| Package | Kept at | Why |
|---|---|---|
| `go_router` | 17.x | 18 moved to the standalone `material_ui` package and only recognises its `MaterialApp`; with the SDK's `MaterialApp` pages lose their Material transitions. |
| `dynamic_color` | 1.x | 2 returns `material_ui` `ColorScheme`s, a different type from the SDK's, so the theme won't compile. |
| `cached_network_image` | 3.x | 4 also moved to `material_ui`. |

Flutter is moving Material and Cupertino out of the SDK into `material_ui` / `cupertino_ui`. When the packages the app uses (loader_overlay, flutter_colorpicker, ...) have moved too, migrate the app (`dart fix` ships the import changes) and lift these three holds together.

## Copied in on purpose

`flutter_scale_kit` lives in `lib/core/scale_size/`, not `pubspec.yaml`, because the published package leaves all text invisible after a 0 × 0 screen. It imports `package:flutter/material.dart`, so it moves to `material_ui` with the app. To take a new release: [sizing and fonts](core/sizing_and_fonts.md).

## On a beta on purpose

`flutter_inappwebview` is on `^6.2.0-beta.3` because the latest stable, 6.1.5 from 2024, doesn't build on AGP 9: `flutter_inappwebview_android` 1.1.3 calls `getDefaultProguardFile('proguard-android.txt')`, which AGP 9 rejects. Move to a stable release once one is out.

## Deprecations left in place

- `firebase_messaging` 17 deprecates `getToken()` and `onTokenRefresh` in favour of `register()` / `onRegistered`, and `deleteToken()` in favour of `unregister()` / `onUnregistered`. The new APIs hand out a Firebase Installation ID for FCM's direct send instead of the registration token backends store today. `FcmService` keeps the token APIs with a note until the backend sends by installation ID.

## Hidden details

- `permission_handler` 13 compiles against Android SDK 37 and requires the app to as well; that's why `compileSdk = 37` is set by hand instead of `flutter.compileSdkVersion`.
- Firebase (BoM 35), `flutter_local_notifications` 22 and `flutter_secure_storage` 11 need Android `minSdk` 24; Flutter's default is already 24.
- On iOS the app gets Firebase Apple SDK 12.19.3, not 13. `firebase_core` 5.1 pins 13.1.1 only for Swift Package Manager; for CocoaPods it pins 12.19.3 and notes that new Firebase releases stop publishing to CocoaPods in October 2026. This project builds with CocoaPods (`enable-swift-package-manager: false` in `pubspec.yaml`). 12.19.3 is only partly on CocoaPods (`Firebase` and `FirebaseCore`; `FirebaseAnalytics` and the rest stop at 12.19.0), so `firebase_analytics`, which asks for `FirebaseAnalytics` 12.19.3 exactly, can't resolve. `$FirebaseSDKVersion = '12.19.0'` at the top of `ios/Podfile` pins every FlutterFire plugin to 12.19.0. Remove it when a `firebase_core` release pins a version that exists for every pod, then run `cd ios && pod update`.
- Android Studio versions before Panda 2 (2025.3.2) refuse to sync AGP 9.1 ("Latest supported version is AGP 8.13.1"). Update Android Studio rather than downgrading AGP; `flutter build` and `flutter run` from a terminal don't depend on the Android Studio version.
- `flutter_secure_storage` 11 drops the old Android ciphers. An app that still has data from a version before 10 must ship a 10.x release first so the data is migrated.
- The `analyzer: exclude:` block in `analysis_options.yaml` (`build/**` and the platform folders) comes from the Flutter tool: every command that runs pub (`flutter pub get`, `flutter analyze`, `flutter test`, ...) adds any entry that is missing, such as `macos/**` once that folder exists. Keep it.
- From language version 3.12, `prefer_initializing_formals` (enabled through `flutter_lints`) also flags a private field set from a named parameter. Use a private named parameter (`{this._field}`, callers still write `field:`), which 3.12 added; this project is on 3.13.
