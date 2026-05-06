# Flutter Starter

**A production-ready Flutter starter** — architecture, theming, DI, routing, storage, and the boring integrations are already wired up.
**Clone it. Rename it. Build your feature.**

[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.11.5-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Material 3](https://img.shields.io/badge/Material%203-6750A4)](https://m3.material.io)
[![BLoC](https://img.shields.io/badge/state-flutter__bloc-1389FD)](https://bloclibrary.dev)
[![go_router](https://img.shields.io/badge/routing-go__router-7e57c2)](https://pub.dev/packages/go_router)

---

## Table of contents

### Getting started
- [What this gives you](#what-this-gives-you)
- [Two ways to use this starter](#two-ways-to-use-this-starter)
- [Quick start](#quick-start)
- [Make it your own](#make-it-your-own)
- [Migrate into an existing project](#migrate-into-an-existing-project)

### Project structure
- [How the app starts](#how-the-app-starts)
- [Where features live](#where-features-live)
- [A feature's anatomy](#a-features-anatomy)

### FAQ
- [FAQ — quick answers](#faq--quick-answers)

### Daily use
- [Daily commands](#daily-commands)
- [Add a new feature](#add-a-new-feature)
- [Add an API layer](#add-an-api-layer)

### Subsystems
- [State management](#state-management--cubit-by-default-bloc-when-you-need-events)
- [Dependency injection](#dependency-injection--annotate-generate-resolve)
- [Routing](#routing--typed-enum--gorouter)
- [Theming](#theming--seed--harmonized-accent-via-brandpalette)
- [Responsive sizing](#responsive-sizing--never-hard-code-pixel-values)
- [Multi-language text scaling](#multi-language-text-scaling)
- [Constants & env](#constants--env--three-files-three-lifetimes)
- [Local storage](#local-storage--hive-hydratedbloc-or-secure-storage)
- [Toasts & messages](#toasts--messages--customsnackbar)
- [Firebase (optional)](#firebase-optional--opt-in-no-op-until-you-enable-it)
- [Built-in integrations](#built-in-integrations--share-qr-webview-rate-report)

### Shipping
- [Build & release](#build--release)
- [Troubleshooting](#troubleshooting)
- [Before shipping](#before-shipping)

---

## What this gives you

A boring, opinionated Flutter app skeleton so you can skip the first week of every project. Pick the bits you need, delete the rest.

- **Architecture** — `core/` + `common/` + feature `modules/` with one import rule
- **State** — `flutter_bloc` (Cubit by default, Bloc when you need events) + `hydrated_bloc`
- **DI** — `get_it` + `injectable` (annotation-driven codegen)
- **Routing** — `go_router` driven by a typed `Routes` enum
- **Theming** — Material 3 from a seed + harmonized accent, built on `material_color_utilities`
- **Responsive sizing** — `flutter_scale_kit` (`.w` `.h` `.r` `.sp`)
- **Storage** — Hive · HydratedBloc · Secure Storage (each for a specific job)
- **Env & config** — three files, three lifetimes (constants / urls / env)
- **Toasts** — `CustomSnackbar` (success / error / info) — context-free, survives navigation
- **Optional Firebase** — opt-in, no-op until you flip the flag
- **Built-in** — Share · QR · WebView · in-app review · permissions · connectivity

> First run shows: **Splash → Onboarding → Dashboard** (Home + Settings tabs). The Settings tab demos every built-in integration so you can copy and adapt.

> **No HTTP client included.** Plug in `dio` or `http` next to [`EnvConfig`](lib/core/utils/constants/env_config.dart). See [Add an API layer](#add-an-api-layer).

---

## Two ways to use this starter

You can either **start a fresh project from this repo** (recommended) or **migrate the structure into an existing project**.

```
┌─ Starting a new app?       → Quick start                (5 minutes)
└─ Already have an app?      → Migrate into existing      (incremental)
```

---

## Quick start

For a brand-new app:

```sh
git clone https://github.com/bimal-py/flutter_starter.git my_app
cd my_app

cp .env_example .env                                       # 1. env file
flutter pub get                                            # 2. packages
dart run build_runner build --delete-conflicting-outputs   # 3. DI codegen (required)
cd ios && pod install && cd ..                             # 4. iOS only
flutter run                                                # 5. go
```

All `.env` keys are optional — leave them blank for now.

> ⚠️ `.env` ships **inside** the binary. Use it for OAuth client IDs, API URLs, and obfuscation-tier keys — not real secrets.

After it's running, jump to [Make it your own](#make-it-your-own).

---

## Make it your own

### 1 · Cut the git history and rename the package

```sh
rm -rf .git && git init                              # fresh history
dart pub global activate rename                      # one-time
rename setBundleId  --value com.yourco.myapp         # iOS + Android IDs
rename setAppName   --value "My App"                 # display name
flutter pub get
```

The [`rename`](https://pub.dev/packages/rename) tool also rewrites every `package:flutter_starter/...` import for you.

<details>
<summary>Prefer to do it manually?</summary>

- `pubspec.yaml` → `name: flutter_starter` → `name: my_app`
- Find/replace `package:flutter_starter/` → `package:my_app/` across `lib/` and `test/`
- iOS bundle ID in `ios/Runner.xcodeproj/project.pbxproj`
- Android `applicationId` in `android/app/build.gradle`
- Display name in `ios/Runner/Info.plist` (`CFBundleDisplayName`) and `android/app/src/main/AndroidManifest.xml` (`android:label`)

</details>

### 2 · Replace brand identity

| File | What to change |
| --- | --- |
| [`lib/core/utils/constants/app_constants.dart`](lib/core/utils/constants/app_constants.dart) | `appName`, `appIosAppId`, `appAndroidPackageId` |
| [`lib/core/utils/constants/app_urls.dart`](lib/core/utils/constants/app_urls.dart) | Privacy / terms / support email |
| [`lib/core/theme/colors/app_colors.dart`](lib/core/theme/colors/app_colors.dart) | `seed` (drives the M3 palette) and `accent` (harmonized brand accent) |
| [`assets/images/logos/`](assets/images/logos/) | Replace `app_logo.png` and `app_logo.svg` |

### 3 · Strip what you don't need

Each `lib/modules/<feature>/` folder is independent. Delete the folders you won't use (e.g. `qr/`, `website_view/`, `device_info/`, `package_info/`) and remove their routes from [`lib/core/router/app_router.dart`](lib/core/router/app_router.dart).

### 4 · Optional polish

- **Fonts** — Inter and NotoSansDevanagari ship by default. Swap or remove in [`pubspec.yaml`](pubspec.yaml).
- **Firebase** — see [Firebase (optional)](#firebase-optional--opt-in-no-op-until-you-enable-it).
- **App icons + splash** — [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) + [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash).

---

## Migrate into an existing project

Already have an app? You don't need to clone the repo. Bring the pieces over in this order — each step is independent and your app keeps building between steps.

### 1 · Add the core dependencies

Copy the relevant entries from this repo's [`pubspec.yaml`](pubspec.yaml) into yours:

```yaml
# state + DI + routing
flutter_bloc: ^...
hydrated_bloc: ^...
get_it: ^...
injectable: ^...
go_router: ^...

# sizing + theming + storage + env
flutter_scale_kit: ^...
hive_ce: ^...
flutter_secure_storage: ^...
flutter_dotenv: ^...

dev_dependencies:
  build_runner: ^...
  injectable_generator: ^...
```

### 2 · Copy `lib/core/` and `lib/common/`

These are framework-level — they don't import any feature modules, so they drop in cleanly. Run a find/replace from `package:flutter_starter/` to `package:<your_app>/` after copying.

### 3 · Adopt one subsystem at a time

Pick what's painful in your current project and migrate just that piece. Suggested order:

1. **Routing** — copy [`lib/core/router/`](lib/core/router/) and switch to `Routes` enum + `GoRouter`.
2. **Theming** — copy [`lib/core/theme/`](lib/core/theme/) and use [`ThemeConfig`](lib/core/config/theme_config.dart) in your `MaterialApp`.
3. **DI** — copy [`lib/core/di/`](lib/core/di/), annotate your classes, run `build_runner`.
4. **Storage** — copy [`lib/app/hive_bootstrap.dart`](lib/app/hive_bootstrap.dart) and the helpers in `core/utils/helpers/`.
5. **Sizing** — wrap your root in `ScaleKit(...)` (see [`main.dart`](lib/main.dart)) and start using `.w` / `.h` / `.r` / `.sp`.

### 4 · Reorganise existing features into `modules/`

Move each feature into a `lib/modules/<feature>/` folder following [the layout](#where-features-live). Delete the old paths once nothing imports from them.

### 5 · Replace your `main.dart`

Mirror this repo's [`main.dart`](lib/main.dart) so init order is right: env → HydratedBloc → Hive → DI → Firebase → `runApp`.

---

## How the app starts

[`lib/main.dart`](lib/main.dart) does these in order — order matters:

1. Load `.env` → `EnvHelper.init()`
2. Set up `HydratedBloc` storage
3. Open all Hive boxes (in parallel)
4. Attach `Bloc.observer` for debug logs
5. Lock orientation to portrait
6. Run DI codegen output → `configureDependencyInjection()`
7. Init Firebase (no-op if disabled)
8. `runApp(StarterApp)`

[`StarterApp`](lib/app/app.dart) wraps the tree with a global loader, provides app-wide blocs ([`GlobalBlocConfig`](lib/app/global_bloc_config.dart)), and builds the `MaterialApp.router`.

---

## Where features live

```
lib/
├── main.dart       bootstrap
├── app/            composition root — wires modules together
├── core/           framework code — does NOT import modules/
├── common/         shared widgets — does NOT import modules/
└── modules/        features (one folder per feature)
```

**The one import rule:** `modules/` may import `core/` and `common/`. **Modules cannot import other modules.** Only `lib/app/` knows about every module.

If two features share code, lift the shared piece into `common/` (widgets) or `core/` (services / utilities). Don't reach across modules.

<details>
<summary>Inside <code>core/</code> and <code>modules/</code></summary>

```
core/
├── config/theme_config.dart       theme entry
├── di/                            injection.dart, service_module.dart
├── errors/                        AppException
├── router/                        Routes enum + GoRouter
├── services/                      firebase_service, share_service
├── text/                          AppText (per-language scale)
├── theme/                         colors, components, light/dark
│   └── colors/brand_palette.dart  reusable M3 palette generator
└── utils/                         constants, extensions, helpers
                                   └── helpers/custom_snackbar.dart

modules/
├── theme/                  ThemeCubit
├── app_setting/            AppSettingCubit
├── onboarding/             splash + onboarding screens
├── dashboard/              bottom-nav shell
├── home/                   Home tab
├── settings/               Settings tab
├── device_info/            device info screen
├── package_info/           package info screen
├── qr/                     QR popup
└── website_view/           WebView wrapper
```

</details>

### A feature's anatomy

```
lib/modules/<feature>/
├── <feature>.dart                  barrel — public API of the module
├── data/repository/                data sources (local / remote)
├── domain/
│   ├── entity/                     plain models
│   └── repository/                 abstract interfaces
├── utils/<feature>_hive.dart       only if it owns a Hive box
└── presentation/
    ├── cubit/ or bloc/             state
    ├── views/                      full screens (one widget = one route)
    └── widgets/                    feature-local components composed by views
```

The barrel (`<feature>.dart`) is what `app/` and other places import from. Everything else is internal.

**`views/` vs `widgets/`** — every feature's presentation layer follows the same split:

- `views/` holds screen-level widgets (the things `GoRouter` builds — `HomeScreen`, `SettingsScreen`, `OnboardingScreen`, etc.). One file per route.
- `widgets/` holds the smaller composable pieces that screens render (e.g. `HomeHeroBanner`, `SettingsThemePicker`, `OnboardingPage`). Keep these small and named after the feature so they don't collide across modules.
- A `widgets/widgets.dart` barrel re-exports them for the screen to import.

If a widget is needed by **two modules**, lift it into [`lib/common/widgets/`](lib/common/widgets/) — modules cannot import each other. (`InfoRowTile`, used by both `device_info` and `package_info`, lives there for exactly this reason.)

---

## FAQ — quick answers

Quick answers to the questions every new contributor asks. Read these once and you'll skip a lot of digging.

<details>
<summary><strong>Cubit or Bloc — which one do I use?</strong></summary>

Reach for **Cubit by default**. A Cubit is a Bloc without the event class — you call methods directly. Use a full `Bloc` only when you actually benefit from an event stream: debouncing, ordering, replay, or multi-step flows. See [State management](#state-management--cubit-by-default-bloc-when-you-need-events).
</details>

<details>
<summary><strong>Where do I put a new screen / feature?</strong></summary>

Inside `lib/modules/<feature>/`. One folder per feature. It owns its `data/`, `domain/`, `presentation/` and exposes a single barrel file (`<feature>.dart`). Walk through [Add a new feature](#add-a-new-feature) once and the pattern sticks.
</details>

<details>
<summary><strong>Where does a new widget go — <code>views/</code> or <code>widgets/</code>?</strong></summary>

- **`views/`** — full screens (anything `GoRouter` builds). One file per route.
- **`widgets/`** — smaller components composed by views, scoped to one feature. Re-exported via a `widgets.dart` barrel.
- **`lib/common/widgets/`** — widgets shared across **two or more modules**. Modules cannot import each other, so anything reused must live here.

See [A feature's anatomy](#a-features-anatomy).
</details>

<details>
<summary><strong>Can a module import another module?</strong></summary>

No. **Modules cannot import other modules.** Modules import only `core/` and `common/`. If two features share code, lift the shared piece into `common/` (widgets) or `core/` (services). Only `lib/app/` knows about every module.
</details>

<details>
<summary><strong>I added <code>@injectable</code> and got "X is not registered" — what do I do?</strong></summary>

Run codegen:

```sh
dart run build_runner build --delete-conflicting-outputs
```

The DI graph lives in `lib/core/di/injection.config.dart` (generated). It only updates when you re-run the generator.
</details>

<details>
<summary><strong>Where do constants / URLs / env vars go?</strong></summary>

Three files, three lifetimes:

| File | What goes here |
| --- | --- |
| [`app_constants.dart`](lib/core/utils/constants/app_constants.dart) | App identity (changes once) |
| [`app_urls.dart`](lib/core/utils/constants/app_urls.dart) | Static external URLs |
| [`env_config.dart`](lib/core/utils/constants/env_config.dart) | Anything from `.env` (changes per environment) |

Never call `EnvHelper.get('SOME_KEY')` directly — add a typed getter to `EnvConfig`.
</details>

<details>
<summary><strong>Hive vs HydratedBloc vs Secure Storage — which one?</strong></summary>

| Use case | What |
| --- | --- |
| Structured data, lists, models | **Hive** (a box per feature) |
| Small flags persisted with bloc state | **HydratedBloc** auto-syncs your bloc state |
| Tokens, passwords | **`SecureStorageHelper`** (OS keychain) |

Full guide: [Local storage](#local-storage--hive-hydratedbloc-or-secure-storage).
</details>

<details>
<summary><strong>How do I show a snack / toast?</strong></summary>

Use `CustomSnackbar` — context-free and survives route changes. From any `BuildContext`:

```dart
context.showSuccessToast('Saved');
context.showErrorToast('Something broke');
context.showInfoToast('Heads up');
```

Or call directly: `CustomSnackbar.show(type: ToastType.success, message: '...')`. See [Toasts & messages](#toasts--messages--customsnackbar).
</details>

<details>
<summary><strong>How do I theme the app or change the seed color?</strong></summary>

Edit two lines in [`app_colors.dart`](lib/core/theme/colors/app_colors.dart):

```dart
static const Color seed = Color(0xFF1B3A6B);   // primary brand color
static const Color accent = Color(0xFFC8A96B); // harmonized to seed
```

Both feed [`BrandPalette`](lib/core/theme/colors/brand_palette.dart), a thin wrapper around `material_color_utilities` that builds the light + dark `ColorScheme` and harmonizes the accent toward the seed. For brand-specific colors that don't fit in `ColorScheme` (e.g. shimmer base, premium gold), add a field to [`CustomThemeExtension`](lib/core/theme/extension/custom_theme_extension.dart). See [Theming](#theming--seed--harmonized-accent-via-brandpalette).
</details>

<details>
<summary><strong>How do I navigate between screens?</strong></summary>

```dart
context.pushNamed(Routes.deviceInfo.name);
context.goNamed(Routes.dashboard.name);
context.pushNamed(Routes.websiteView.name, extra: 'https://flutter.dev');
```

To add a route: add an entry to the [`Routes`](lib/core/router/routes.dart) enum, then a matching `GoRoute` in [`app_router.dart`](lib/core/router/app_router.dart). Nested routes use **relative** paths (no leading `/`).
</details>

<details>
<summary><strong>Why doesn't my theme change show up?</strong></summary>

Use **hot restart** (`R`), not hot reload (`r`). Theme changes are picked up on a fresh build only.
</details>

<details>
<summary><strong>Can I drop Firebase entirely?</strong></summary>

Yes — it's opt-in. The build is green out of the box without Firebase. Set `FIREBASE_ENABLED=false` (or leave it blank) and skip [`flutterfire configure`](#firebase-optional--opt-in-no-op-until-you-enable-it).
</details>

<details>
<summary><strong>Why no HTTP client?</strong></summary>

Different projects want different ones. Plug in `dio` or `http` next to [`EnvConfig`](lib/core/utils/constants/env_config.dart). Walkthrough: [Add an API layer](#add-an-api-layer).
</details>

<details>
<summary><strong>Why is text smaller in Nepali / Hindi / Arabic?</strong></summary>

Some scripts render visually smaller than Latin at the same `fontSize`. Use [`AppText`](lib/core/text/app_text.dart) instead of `Text` for body content — it applies per-language scale factors from [`font_scale.dart`](lib/core/text/font_scale.dart). See [Multi-language text scaling](#multi-language-text-scaling).
</details>

---

## Daily commands

```sh
flutter run                                              # run the app
dart run build_runner build --delete-conflicting-outputs # after adding @injectable
dart run build_runner watch --delete-conflicting-outputs # auto-regen on save
flutter analyze                                          # lint
flutter test                                             # tests
dart format lib test                                     # format
flutter clean                                            # if anything's weird
```

---

## State management — Cubit by default, Bloc when you need events

This starter uses `flutter_bloc`, but **reach for `Cubit` first**. A Cubit is a Bloc without the event class — you call methods directly. Use a full `Bloc` only when you actually benefit from an event stream (debouncing, ordering, complex transitions, replay).

| Use a... | When you have... |
| --- | --- |
| `Cubit` | Simple state — load, toggle, submit. The default. |
| `Bloc` | An event stream worth modeling explicitly (search debounce, paginated lists, multi-step flows). |
| `HydratedCubit` / `HydratedBloc` | State that must survive app restarts (theme, "has seen onboarding"). |

```dart
// Read once
final mode = context.read<ThemeCubit>().state.themeMode;

// Rebuild on change
BlocBuilder<ThemeCubit, ThemeModeState>(
  builder: (context, state) => Switch(value: state.isDark, onChanged: ...),
);

// React without rebuilding (snackbars, navigation)
BlocListener<SplashBloc, SplashState>(listener: ..., child: ...);
```

**Where to provide:**

| Scope | Where |
| --- | --- |
| App-wide (theme, auth, current user) | [`GlobalBlocConfig`](lib/app/global_bloc_config.dart) — resolved from `getIt` |
| Screen-only (form, list) | `BlocProvider` at the screen root |

For persisted state, see [`ThemeCubit`](lib/modules/theme/blocs/theme/theme_cubit.dart) — a small `HydratedCubit` example with `fromJson` / `toJson`.

## Dependency injection — annotate, generate, resolve

```dart
@injectable           // new instance per resolve
@lazySingleton        // one instance, created on first resolve
@singleton            // one instance, created at startup
```

After adding an annotation:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Resolve anywhere:

```dart
final cubit = getIt<ThemeCubit>();
```

For third-party classes you can't annotate (e.g. `SharedPreferences`), register them in [`ServiceModule`](lib/core/di/service_module.dart). Use `@preResolve` for async deps that must be ready before `runApp`.

**Inject** things you'd mock in tests (repos, network clients).
**Don't inject** stateless utility helpers.

## Routing — typed enum + GoRouter

Two files own routing:

- [`routes.dart`](lib/core/router/routes.dart) — the `Routes` enum (single source of truth)
- [`app_router.dart`](lib/core/router/app_router.dart) — the `GoRouter` config

```dart
context.pushNamed(Routes.deviceInfo.name);
context.goNamed(Routes.dashboard.name);
context.pushNamed(Routes.websiteView.name, extra: 'https://flutter.dev');
```

To add a route: add an entry to the enum, then a matching `GoRoute` in `app_router.dart`. Nested routes use **relative** paths (no leading `/`).

## Theming — seed + harmonized accent via `BrandPalette`

Two lines drive the entire scheme:

```dart
// lib/core/theme/colors/app_colors.dart
static const Color seed = Color(0xFF1B3A6B);   // primary brand color
static const Color accent = Color(0xFFC8A96B); // optional, harmonized to seed
```

Both feed [`BrandPalette`](lib/core/theme/colors/brand_palette.dart) — a thin wrapper around `material_color_utilities` (the same package that powers `ColorScheme.fromSeed`). It generates:

- A full Material 3 [`ColorScheme`](lib/core/theme/light_theme.dart) for light + dark, including all the modern surface roles (`surfaceContainer`, `surfaceContainerHigh`, `surfaceDim`, etc.).
- A harmonized accent — `accent` is shifted up to 15° in hue toward `seed` via `Blend.harmonize`, so the two colors read as belonging to the same family no matter what brand colors you pick.
- Direct tonal access if you need it: `palette.primaryTone(95, brightness: ...)`, `palette.neutralTone(20, brightness: ...)`.

`BrandPalette` is **self-contained** (no app-specific imports) — copy `brand_palette.dart` into another Flutter project as-is.

```dart
final brand = BrandPalette(
  seed: const Color(0xFF1B3A6B),
  accent: const Color(0xFFC8A96B), // optional
  contrastLevel: 0.0,              // -1.0 to 1.0
  variant: DynamicSchemeVariant.tonalSpot, // or vibrant, expressive, content...
);

MaterialApp(
  theme: ThemeData.from(colorScheme: brand.light),
  darkTheme: ThemeData.from(colorScheme: brand.dark),
);
```

**Customizing further:**

- **Restyle a component everywhere?** Edit the matching file in [`core/theme/component_themes/`](lib/core/theme/component_themes/) — don't wrap widgets in custom variants.
- **Need a color outside `ColorScheme`?** Add a field to [`CustomThemeExtension`](lib/core/theme/extension/custom_theme_extension.dart). It ships with `brandAccent` (the harmonized accent) and `brandAccentMuted` (translucent variant for halos and subtle fills), exposed via `Theme.of(context).extension<CustomThemeExtension>()!`.

> ⚠️ **Don't override `color:` on text styles in widget code.** Material 3 components (`ListTile`, `AppBar`, `Card`, etc.) apply `colorScheme.onSurface` automatically — overriding `color` per-Text fights that and produces unreadable titles. If you need a custom weight, use `textTheme.titleSmall?.copyWith(fontWeight: ...)` and let color flow through.

The Settings tab demos light / dark / system switching, persisted across launches.

## Responsive sizing — never hard-code pixel values

Use the extensions from `flutter_scale_kit` (vendored at [`lib/core/scale_size/`](lib/core/scale_size/)):

| | Use for |
| --- | --- |
| `.w` / `.h` | width / height |
| `.r` | radius, square sizes (icon size) |
| `.sp` | font size |
| `.sw` / `.sh` | % of screen width / height |
| `.spClamp(min, max)` etc. | clamped variants — won't grow / shrink past bounds |

```dart
EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
BorderRadius.circular(12.r)
fontSize: 14.spClamp(12, 16)
```

Design dimensions are set in [`main.dart`](lib/main.dart) (`425 × 691`).

## Multi-language text scaling

Some scripts (Devanagari, Bengali, Arabic) render visually smaller than Latin at the same `fontSize`. Two pieces handle that:

1. Per-language scale factors in [`font_scale.dart`](lib/core/text/font_scale.dart):

   ```dart
   static const Map<String, double> _scales = {
     'ne': 1.10,
     'bn': 1.10,
     'ar': 1.05,
   };
   ```

2. Use [`AppText`](lib/core/text/app_text.dart) (drop-in replacement for `Text`) for body content — it applies the active scale automatically.

## Constants & env — three files, three lifetimes

| File | What goes here |
| --- | --- |
| [`app_constants.dart`](lib/core/utils/constants/app_constants.dart) | App identity (name, store IDs, Hive box names) — changes once per app |
| [`app_urls.dart`](lib/core/utils/constants/app_urls.dart) | Static external URLs (download, privacy, support email) |
| [`env_config.dart`](lib/core/utils/constants/env_config.dart) | Everything from `.env` (API base, auth keys, OAuth IDs) — changes per environment |

**Rule:** never call `EnvHelper.get('SOME_KEY')` directly. Add a typed getter to [`EnvConfig`](lib/core/utils/constants/env_config.dart) and use that:

```dart
// ❌ Don't
final url = EnvHelper.get('API_BASE_URL');

// ✅ Do
final url = EnvConfig.apiBaseUrl;
```

`EnvConfig.authKey` automatically picks `PROD_AUTH_KEY` in release builds and `DEV_AUTH_KEY` otherwise.

## Local storage — Hive, HydratedBloc, or Secure Storage?

| Use case | What |
| --- | --- |
| Structured data, lists, models | **Hive** (a box per feature) |
| Small flags persisted with bloc state (theme, "first run") | **HydratedBloc** auto-syncs your bloc state |
| Tokens, passwords | [**`SecureStorageHelper`**](lib/core/utils/helpers/secure_storage_helper.dart) — OS keychain |

**Hive — adding a feature box** (only if your module needs structured local data):

1. Create `lib/modules/<feature>/utils/<feature>_hive.dart`:

   ```dart
   class FeatureHiveBoxNameKeys {
     static const String dataBoxName = 'feature_data';
   }

   extension FeatureBoxExtension on HiveInterface {
     Future<Box<dynamic>> openFeatureBox() =>
         Hive.openBox(FeatureHiveBoxNameKeys.dataBoxName);

     Box<dynamic> get featureBox =>
         Hive.box(FeatureHiveBoxNameKeys.dataBoxName);

     Future<int> clearFeatureBox() => featureBox.clear();
   }
   ```

2. Register the open + clear in [`hive_bootstrap.dart`](lib/app/hive_bootstrap.dart):

   ```dart
   final _boxOpeners = [
     () => Hive.openAppBox(),
     () => Hive.openFeatureBox(),    // ← add
   ];
   final _boxClearers = [
     () => Hive.clearAppBox(),
     () => Hive.clearFeatureBox(),   // ← add
   ];
   ```

`main.dart` only ever calls `Hive.openAllBoxes()`. For "log out", call `Hive.clearAllBoxes()`.

**Secure storage:**

```dart
await SecureStorageHelper.instance.write('access_token', token);
final token = await SecureStorageHelper.instance.read('access_token');
```

## Toasts & messages — `CustomSnackbar`

The starter does **not** use `ScaffoldMessenger.showSnackBar(...)`. Instead, [`CustomSnackbar`](lib/core/utils/helpers/custom_snackbar.dart) wraps `fluttertoast` with three semantic types — `success`, `error`, `info`. It works without a `Scaffold` in scope, survives navigation between routes, and auto-cancels the previous toast.

**From any `BuildContext`:**

```dart
context.showSuccessToast('Saved');
context.showErrorToast('Network failed');
context.showInfoToast('Heads up');
```

**Without a context** (e.g. from a service or input formatter):

```dart
CustomSnackbar.show(type: ToastType.error, message: 'Invalid input');
CustomSnackbar.cancel(); // dismiss any visible toast
```

To restyle, edit `_backgroundFor(...)` in `custom_snackbar.dart` or pass `backgroundColor` / `textColor` per call.

## Firebase (optional) — opt-in, no-op until you enable it

The starter does **not** initialise Firebase by default — the build is green out of the box.

```sh
# 1. Install the CLI (one time)
dart pub global activate flutterfire_cli

# 2. Configure (creates lib/firebase_options.dart, gitignored)
flutterfire configure

# 3. In lib/core/services/firebase_service.dart, uncomment:
#    - the firebase_options import
#    - the `options:` line in Firebase.initializeApp(...)

# 4. In .env:
FIREBASE_ENABLED=true

# 5. Run
flutter run
```

Crashlytics is enabled in **release builds only**. Analytics logs `app_open` automatically.

## Built-in integrations — Share, QR, WebView, Rate, Report

All wired up and demo'd in the Settings tab — copy the call sites as templates.

```dart
// Sharing
await ShareService.shareText(context: context, text: 'Hello: $url');
await ShareService.shareFiles(context: context, filePaths: [path]);
await ShareService.shareImageBytes(context: context, bytes: png, fileName: 'qr.png');

// QR popup
QrPopup.show(context, qrData: AppUrls.appDownload, fileName: AppConstants.appAndroidPackageId);

// WebView
context.pushNamed(Routes.websiteView.name, extra: 'https://flutter.dev');

// Rate
final review = InAppReview.instance;
if (await review.isAvailable()) {
  await review.requestReview();
} else {
  await review.openStoreListing(appStoreId: AppConstants.appIosAppId);
}

// Report (mailto)
await const UrlHelper().sendEmail(to: AppUrls.supportEmail, subject: 'Report');
```

[`PermissionHelper`](lib/core/utils/helpers/permission_helper.dart) handles iOS limited photos and Android ≤ 9 storage. Modern Android needs nothing.

---

## Add a new feature

Walk through this once and the pattern sticks. Example: a `reminders` feature.

### 1 · Create the folder

```
lib/modules/reminders/
├── reminders.dart                       barrel
├── data/repository/local/...
├── domain/
│   ├── entity/reminder.dart
│   └── repository/reminders_repository.dart
├── utils/reminders_hive.dart            (only if it owns a Hive box)
└── presentation/
    ├── cubit/
    │   ├── reminders_cubit.dart
    │   └── reminders_state.dart
    ├── views/reminders_screen.dart
    └── widgets/...
```

### 2 · Build the cubit

```dart
@injectable
class RemindersCubit extends Cubit<RemindersState> {
  RemindersCubit(this._repo) : super(const RemindersState());
  final RemindersRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final items = await _repo.getAll();
    emit(state.copyWith(loading: false, items: items));
  }
}
```

### 3 · Register the repository

```dart
@LazySingleton(as: RemindersRepository)
class RemindersLocalRepository implements RemindersRepository { ... }
```

### 4 · Regenerate DI

```sh
dart run build_runner build --delete-conflicting-outputs
```

### 5 · Wire the screen

```dart
class RemindersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RemindersCubit>()..load(),
      child: const _RemindersView(),
    );
  }
}
```

### 6 · Register the route

```dart
// routes.dart
reminders(name: 'reminders', path: 'reminders'),

// app_router.dart (inside dashboard's `routes:`)
GoRoute(
  name: Routes.reminders.name,
  path: Routes.reminders.path,
  builder: (_, __) => const RemindersScreen(),
),
```

### 7 · (If using Hive) register the box

See [Local storage](#local-storage--hive-hydratedbloc-or-secure-storage).

### 8 · Navigate

```dart
context.pushNamed(Routes.reminders.name);
```

That's the whole cycle: folder → state → DI → route → navigate.

---

## Add an API layer

The starter ships with no HTTP client — pick what fits.

<details>
<summary>Recommended: Dio</summary>

```sh
flutter pub add dio
flutter pub add pretty_dio_logger
```

```dart
@lazySingleton
class ApiClient {
  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    headers: {'Authorization': 'Bearer ${EnvConfig.authKey}'},
  ));

  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post(AuthEndpoints.login, data: {
      'email': email, 'password': password,
    });
    return res.data as Map<String, dynamic>;
  }
}
```

Add endpoint paths next to [`env_config.dart`](lib/core/utils/constants/env_config.dart):

```dart
class AuthEndpoints {
  AuthEndpoints._();
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
}
```

Translate package errors into [`AppException`](lib/core/errors/exceptions.dart) at the repository boundary — UI code never sees `DioException`.

</details>

---

## Build & release

```sh
flutter build apk --release           # Android APK
flutter build appbundle --release     # Android Play Store bundle
flutter build ipa --release           # iOS archive
```

App icons + splash:

- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
- [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash)

For Android signing, set up `android/key.properties` per the [official guide](https://docs.flutter.dev/deployment/android#signing-the-app).

---

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `Type 'X' not found` after pulling code | `dart run build_runner build --delete-conflicting-outputs` |
| `MissingPluginException` after adding a package | `flutter clean && flutter pub get && cd ios && pod install` |
| `Box hasn't been opened` | Forgot to register it in [`hive_bootstrap.dart`](lib/app/hive_bootstrap.dart) |
| iOS pod errors | `cd ios && pod repo update && pod install` |
| Theme changes not appearing | Use **hot restart** (`R`), not hot reload |
| `getIt<X> is not registered` | Missing `@injectable`, or you forgot build_runner |
| Anything weird | `flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs` |

---

## Before shipping

- [ ] Replace `appName`, `appIosAppId`, `appAndroidPackageId` in [`app_constants.dart`](lib/core/utils/constants/app_constants.dart)
- [ ] Replace placeholder URLs in [`app_urls.dart`](lib/core/utils/constants/app_urls.dart)
- [ ] Update bundle / package ID in `ios/Runner.xcodeproj` and `android/app/build.gradle`
- [ ] Set `API_BASE_URL` and `PROD_AUTH_KEY` in `.env`
- [ ] Replace the seed color in [`app_colors.dart`](lib/core/theme/colors/app_colors.dart)
- [ ] Replace `assets/images/logos/app_logo.*` with your logo
- [ ] Add app icons + splash assets
- [ ] Pick a font (or keep Inter / NotoSansDevanagari)
- [ ] Set up Android release signing
- [ ] Wire up Firebase (optional)
- [ ] `flutter analyze` clean
- [ ] Test on a low-end Android and a small iPhone

---

<div align="center">

Built by **[Bimal Khatri](https://github.com/bimal-py)** · Issues and PRs welcome

If this saved you a weekend, ⭐ the repo on [GitHub](https://github.com/bimal-py/flutter_starter).

</div>
