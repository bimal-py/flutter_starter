# Getting started

Turn this starter into your app: rename it, pick the modules you need, run it.

## Requirements

- Flutter 3.47 or newer (Dart 3.13). Check with `flutter --version`.
- Android Studio Panda 2 (2025.3.2) or newer, which is needed to sync AGP 9.1, with Android SDK 37 (the build asks for it; Gradle downloads the rest).
- Xcode 26 and CocoaPods for iOS.
- No separate JDK if Android Studio is installed: Flutter uses the one bundled with it. Flutter looks in this order: `flutter config --jdk-dir`, Android Studio, `JAVA_HOME`, `PATH`. Any JDK from 17 to 25 works with this Gradle version. To use a specific one, run `flutter config --jdk-dir="<path>"` for Flutter and set Settings, Build Tools, Gradle, Gradle JDK for Android Studio's sync.

## 1. Create your app from the starter

1. Copy the repository into a new folder and start a fresh git history:

   ```sh
   git clone https://github.com/bimal-py/flutter_starter.git my_shop
   cd my_shop
   rm -rf .git && git init
   ```

2. Rename the package, the bundle ids and the app name in one go:

   ```sh
   dart run tool/rename_app.dart \
     --package my_shop \
     --bundle-id com.mycompany.myshop \
     --label "My Shop" \
     --name "My Shop Inventory"
   ```

   - `--package`: the Dart package name (`pubspec.yaml` and every import).
   - `--bundle-id`: Android `applicationId` and iOS bundle identifier. Two or more segments, each starting with a letter and using letters, digits or `_`. Leave out `_` if you ship on iOS: Apple bundle ids don't allow it, and the tool writes the same id to both.
   - `--label`: the name under the app icon (keep it short).
   - `--name`: the full name shown inside the app (`AppConstants.appName`). Defaults to `--label`.

3. Create the env file:

   ```sh
   cp .env_example .env
   ```

   Fill in `API_BASE_URL`, with or without a trailing `/` (`DioConfig` trims it). Everything else can stay empty until you use that feature. See [utilities](core/utilities.md) for every key.

4. Generate code and check the project:

   ```sh
   flutter pub get
   dart run build_runner build
   flutter analyze
   ```

5. Run it:

   ```sh
   flutter run
   ```

## 2. Keep only the modules you need

Every optional feature is a folder in `lib/modules/`. Open the [module catalog](modules/README.md), and for each module you don't need follow its **Remove** steps. They are always the same shape:

1. Delete `lib/modules/<module>/`.
2. Remove its lines from the composition points (`lib/main.dart`, `lib/app/*.dart`, `lib/core/router/*.dart`): its imports, the code under each `// Optional. Remove with lib/modules/<module>/` comment, and its `Routes` entries in `routes.dart`, which end with `// <module>`.
3. Edit the modules that use it (the catalog's **Used by** column), or remove them too.
4. Remove the packages only that module used from `pubspec.yaml`, and its native keys (AndroidManifest.xml, Info.plist, Podfile).
5. Run `dart run build_runner build` and `flutter analyze`.

## 3. Set up Firebase (only if you use it)

Crashlytics, Analytics, push (fcm) and update alerts (app_upgrade) need Firebase.

1. `dart pub global activate flutterfire_cli`
2. `flutterfire configure` (writes `lib/firebase_options.dart`, which is gitignored).
3. Set `FIREBASE_ENABLED=true` in `.env`.
4. In `lib/core/services/firebase_service.dart`, uncomment the `firebase_options.dart` import and the `options: DefaultFirebaseOptions.currentPlatform,` line.

Without these steps the app runs and the Firebase features stay off. After step 4 the app needs `lib/firebase_options.dart` to compile, so run `flutterfire configure` on every fresh clone (or stop ignoring the file). Crashlytics collects in release builds only.

## 4. Build your first feature

Follow [adding a module](adding_a_module.md). It walks one feature from entity to screen with the project's naming and folder rules ([conventions](conventions.md)).

## Everyday commands

| Task | Command |
|---|---|
| Install packages | `flutter pub get` |
| Regenerate DI after adding/removing `@injectable` classes | `dart run build_runner build` |
| Static checks | `flutter analyze` |
| Format | `dart format lib test` |
| Tests | `flutter test` |
| Upgrade packages | see [upgrading](upgrading.md) |

## Hidden details

- `.env` is bundled into the app binary. Put only public values there (API base URL, ad unit ids, OAuth client ids). Real secrets stay on your server.
- `.env` is gitignored but required: `pubspec.yaml` lists it under `assets`, so a clone without it doesn't build, and `EnvHelper.init()` throws at start-up if it is empty.
- `lib/core/di/injection.config.dart` is generated but committed, so a fresh clone compiles before you run `build_runner`. Regenerate it whenever you add, rename or delete an annotated class.
- `pubspec.lock` is committed on purpose: everyone builds with the same versions.
- iOS uses CocoaPods (`enable-swift-package-manager: false` in `pubspec.yaml`). Flip it to `true` once every plugin you keep supports Swift Package Manager.
