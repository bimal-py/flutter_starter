# Getting started

Turn this starter into your app: rename it, pick the modules you need, run it.

## Requirements

- Flutter 3.47 or newer (Dart 3.13). Check with `flutter --version`.
- Android Studio with Android SDK 37 (the build asks for it; Gradle downloads the rest).
- Xcode 26 and CocoaPods for iOS.
- JDK 17 or newer.

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
   - `--bundle-id`: Android `applicationId` and iOS bundle identifier. Segments start with a letter and use letters, digits or `_`.
   - `--label`: the name under the app icon (keep it short).
   - `--name`: the full name shown inside the app (`AppConstants.appName`). Defaults to `--label`.

3. Create the env file:

   ```sh
   cp .env_example .env
   ```

   Fill in `API_BASE_URL` (with a trailing `/`). Everything else can stay empty until you use that feature. See [utilities](core/utilities.md) for every key.

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
2. Remove its lines from the composition points (`lib/main.dart`, `lib/app/*.dart`, `lib/core/router/*.dart`). Each line is marked `// Optional. Remove with lib/modules/<module>/`.
3. Remove the packages only that module used from `pubspec.yaml`, and its native keys (AndroidManifest.xml, Info.plist).
4. Run `dart run build_runner build` and `flutter analyze`.

## 3. Set up Firebase (only if you use it)

Crashlytics, Analytics, push (fcm) and update alerts (app_upgrade) need Firebase.

1. `dart pub global activate flutterfire_cli`
2. `flutterfire configure` (writes `lib/firebase_options.dart`, which is gitignored).
3. Set `FIREBASE_ENABLED=true` in `.env`.

Without these steps the app runs and the Firebase features stay off.

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
- `lib/core/di/injection.config.dart` is generated but committed, so a fresh clone builds before you run `build_runner`. Regenerate it whenever you add, rename or delete an annotated class.
- `pubspec.lock` is committed on purpose: everyone builds with the same versions.
- iOS uses CocoaPods (`enable-swift-package-manager: false` in `pubspec.yaml`). Flip it to `true` once every plugin you keep supports Swift Package Manager.
