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

Everything is in [`doc/`](doc/README.md), one topic per page. Read it in this order.

**1. Set up your app**

1. [Getting started](doc/getting_started.md): copy and rename the starter, fill `.env`, run it, and set up Firebase only if you use it.
2. [Module catalog](doc/modules/README.md): decide which modules you keep. Each module page ends with **Remove** steps; follow them for every module you don't need.

**2. Learn how the code is organised**

3. [Architecture](doc/architecture.md): the layers, who may import whom, and how the app starts.
4. [Project structure](doc/project_structure.md): every folder, and where a new file goes.
5. [Conventions](doc/conventions.md): names, imports, screens, cubits, loading states, copy and commits. Read this before you write code.

**3. Build your features**

6. [Adding a module](doc/adding_a_module.md): one feature from entity to screen, step by step.
7. The core page for what your feature touches: [network](doc/core/network.md) (API calls), [storage](doc/core/storage.md) (saving data), [routing](doc/core/routing.md) (screens), [theme](doc/core/theme.md) (colors and text), [errors and messages](doc/core/errors_and_messages.md) (toasts, dialogs, loaders), [permissions](doc/core/permissions.md), [dependency injection](doc/core/dependency_injection.md), [sizing and fonts](doc/core/sizing_and_fonts.md), [utilities](doc/core/utilities.md).
8. The page of each module you kept, in [`doc/modules/`](doc/modules/README.md), when you use or change it.

**4. Keep it up to date**

9. [Upgrading](doc/upgrading.md): moving to newer Flutter and packages, and what is held back and why.

**Working with Claude Code**

10. [Using Claude Code](doc/using_claude_code.md): the `CLAUDE.md`, skills, subagent and hooks that make it follow the starter's conventions, check its own work and spend fewer tokens.
