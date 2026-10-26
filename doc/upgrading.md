# Upgrading

How to move the starter (or an app built from it) to newer Flutter and packages, and what was deliberately held back.

## Current baseline

- Flutter 3.47, Dart 3.13 (`environment` in `pubspec.yaml` matches what the packages need).
- Android: AGP 9.1.0, Kotlin 2.4.0, Gradle 9.3.1, `compileSdk 37`, `minSdk 24` and `targetSdk 36` (Flutter defaults), Java 17.
- iOS: deployment target 15.0 (Podfile and Xcode project), CocoaPods.

## Steps

1. `flutter upgrade`.
2. `flutter pub upgrade --major-versions`, then `flutter pub outdated` to see what stayed behind and why.
3. Read the changelog of every package that changed major version (`~/.pub-cache/hosted/pub.dev/<package>-<version>/CHANGELOG.md`). Look for "BREAKING", minimum SDK, minSdk, compileSdk, iOS deployment target.
4. `flutter analyze` and fix the errors. Then fix the deprecations (or note why one stays).
5. Native: create a throwaway project with the new Flutter and diff its platform files against yours:

   ```sh
   flutter create --org com.example --project-name flutter_starter /tmp/fresh
   diff /tmp/fresh/android/settings.gradle.kts android/settings.gradle.kts
   diff /tmp/fresh/android/app/build.gradle.kts android/app/build.gradle.kts
   diff /tmp/fresh/android/gradle/wrapper/gradle-wrapper.properties android/gradle/wrapper/gradle-wrapper.properties
   ```

   Copy the version bumps; keep your own manifest entries, permissions and Info.plist keys.
6. Build both platforms and smoke-test start-up, login, push and ads.

## Held back on purpose

| Package | Kept at | Why |
|---|---|---|
| `go_router` | 17.x | 18 moved to the standalone `material_ui` package and only recognises its `MaterialApp`; with the SDK's `MaterialApp` pages lose their Material transitions. |
| `dynamic_color` | 1.x | 2 returns `material_ui` `ColorScheme`s, a different type from the SDK's, so the theme won't compile. |
| `cached_network_image` | 3.x | 4 also moved to `material_ui`. |

Flutter is moving Material and Cupertino out of the SDK into `material_ui` / `cupertino_ui`. When the packages the app uses (skeletonizer, flutter_scale_kit, loader_overlay, ...) have moved too, migrate the app (`dart fix` ships the import changes) and lift these three holds together.

## Deprecations left in place

- `firebase_messaging` 17 deprecates `getToken()`, `deleteToken()` and `onTokenRefresh` in favour of `register()` / `onRegistered`, which hand out a Firebase Installation ID for FCM's direct send instead of the registration token backends store today. `FcmService` keeps the token APIs with a note until the backend sends by installation ID.

## Hidden details

- `permission_handler` 13 compiles against Android SDK 37 and requires the app to as well; that's why `compileSdk = 37` is set by hand instead of `flutter.compileSdkVersion`.
- Firebase (BoM 35, Apple SDK 13), `flutter_local_notifications` 22 and `flutter_secure_storage` 11 need Android `minSdk` 24; Flutter's default is already 24.
- `flutter_secure_storage` 11 drops the old Android ciphers. An app that still has data from a version before 10 must ship a 10.x release first so the data is migrated.
- `flutter analyze` may add an `analyzer: exclude:` block to `analysis_options.yaml`; that's the Flutter tool migrating the file, keep it.
- The newer `lints` flag `prefer_initializing_formals` for private fields set from named parameters: use private named parameters (`{this._field}`, callers still write `field:`), which this project's language version (3.13) supports.
