# Flutter Starter

A production-ready Flutter starting point: feature-first clean architecture, BLoC, get_it/injectable, go_router, Material 3 theming, a Dio network layer with token refresh, auth, and a set of optional modules you delete when you don't need them.

## What's inside

- **Architecture**: one folder per feature (`lib/modules/`), each with data / domain / presentation layers and barrel files.
- **Network**: `RemoteService` over Dio with token refresh, retries, readable errors and upload helpers.
- **Auth**: sessions, remember me, email-code sign-up, password reset, Google / Apple hooks, instant logout.
- **State**: `flutter_bloc` with `SafeCubit`, a shared loading-state pattern, skeleton loading, error views and a popup loader.
- **Theme**: Material 3 from a seed or the device's colors, presets, dark mode, per-locale fonts, a theme playground.
- **Storage**: Hive (a box per module), secure storage for tokens, HydratedBloc.
- **Lists**: a pagination module with one page size, typed pages and auto-loading list widgets.
- **Optional modules**: push (FCM), local notifications, in-app update alerts, image picker, QR, ads, onboarding, settings, about, web view.

## Quick start

1. Copy the repo and rename it into your app:

   ```sh
   git clone https://github.com/bimal-py/flutter_starter.git my_app && cd my_app
   rm -rf .git && git init
   dart run tool/rename_app.dart --package my_app --bundle-id com.mycompany.myapp --label "My App"
   ```

2. `cp .env_example .env` and set `API_BASE_URL`.
3. `flutter pub get`
4. `dart run build_runner build`
5. `flutter run`

Needs Flutter 3.47+ (Dart 3.13). Details and the optional Firebase setup: [getting started](doc/getting_started.md).

## Documentation

Everything is in [`doc/`](doc/README.md): architecture, project structure, conventions, adding a module, the core layer, and one page per module with **how to remove it**.
