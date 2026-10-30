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
- **Release tools**: a store screenshot generator, an image optimizer, and CI/CD templates with step-by-step guides for Firebase App Distribution, Codemagic and Fastlane. See [Step 5](#step-5-release-it).

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

Everything is in [`doc/`](doc/README.md), one topic per page. Go through it in these steps.

### Step 1: Set up your app

1. [Getting started](doc/getting_started.md): copy and rename the starter, fill `.env`, run it, and set up Firebase only if you use it.
2. [Module catalog](doc/modules/README.md): decide which modules you keep. Each module page ends with **Remove** steps; follow them for every module you don't need.

### Step 2: Learn how the code is organised

1. [Architecture](doc/architecture.md): the layers, who may import whom, and how the app starts.
2. [Project structure](doc/project_structure.md): every folder, and where a new file goes.
3. [Conventions](doc/conventions.md): names, imports, screens, cubits, loading states, copy and commits. Read this before you write code.

### Step 3: Build your features

1. [Adding a module](doc/adding_a_module.md): one feature from entity to screen, step by step.
2. The core page for what your feature touches: [network](doc/core/network.md) (API calls), [storage](doc/core/storage.md) (saving data), [routing](doc/core/routing.md) (screens), [theme](doc/core/theme.md) (colors and text), [errors and messages](doc/core/errors_and_messages.md) (toasts, dialogs, loaders), [permissions](doc/core/permissions.md), [dependency injection](doc/core/dependency_injection.md), [sizing and fonts](doc/core/sizing_and_fonts.md), [utilities](doc/core/utilities.md).
3. The page of each module you kept, in [`doc/modules/`](doc/modules/README.md), when you use or change it.

### Step 4: Keep it up to date

[Upgrading](doc/upgrading.md): moving to newer Flutter and packages, and what is held back and why.

### Step 5: Release it

The starter ships the tools for this too, in the order you'd use them:

1. [Optimize images](doc/tools/optimize_images.md): `python3 tool/optimize_images.py` reports how much `assets/` can shrink (PNG, JPEG, WebP, GIF, AVIF, SVG), lossless by default, filtered by folder, name or size.
2. [Store screenshots](doc/tools/screenshots.md): `python3 tool/marketing/make_screenshots.py` turns your captures, a title and a description each into framed screenshots for every App Store and Play Store size ([samples](doc/tools/screenshots.md#samples)).
3. [CI/CD](doc/cicd/README.md): templates you copy in when you need them:
   - [Firebase App Distribution](doc/cicd/firebase_app_distribution/README.md): a GitHub Actions workflow that checks the code, builds a signed APK and sends it to your testers.
   - [Codemagic](doc/cicd/codemagic/README.md): signed `.aab` and `.ipa` builds uploaded to Play internal testing and App Store Connect.
   - [Fastlane](doc/cicd/fastlane/README.md): your store listings (text, screenshots, release notes) kept as files and uploaded with one command.

### Step 6: Work faster with Claude Code

[Using Claude Code](doc/using_claude_code.md): the `CLAUDE.md`, skills, subagent and hooks that make it follow the starter's conventions, check its own work and spend fewer tokens.
