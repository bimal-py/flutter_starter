# Architecture

Feature-first clean architecture. Every feature is a module under `lib/modules/` with its own data, domain and presentation layers. Shared code lives in `core/` (framework) and `common/` (widgets and base classes). `app/` and `main.dart` wire the modules in.

## Layers

```
lib/
├── main.dart     start-up: env, storage, DI, Firebase, runApp
├── app/          composition root: root widget, global blocs, Hive boxes, app-wide listeners
├── core/         framework: DI, errors, network, router, services, theme, utils
├── common/       shared widgets, SafeCubit, UseCase base, BlocObserver
└── modules/      one folder per feature (auth, user, settings, pagination, ...)
```

Who may import whom:

```
main.dart, app/   ──►  everything (they are the composition root)
modules/<a>/      ──►  core/, common/, and other modules through their top barrel
common/           ──►  core/
core/             ──►  nothing in modules/ (the router is the one exception: it
                       lists the screens)
```

Because `core/` never imports a module, deleting a module never breaks the framework. The places that know about modules are few and fixed:

| Composition point | What it wires |
|---|---|
| `lib/main.dart` | start-up calls (notifications, FCM, ads) |
| `lib/app/global_bloc_config.dart` | app-wide blocs (theme, settings, auth, ...) |
| `lib/app/app_bootstrappers.dart` | app-wide listeners (update alert, auth edges) |
| `lib/app/hive_bootstrap.dart` | the Hive box of each module |
| `lib/core/router/` | routes and screens |

## Inside a module

```
widget ──► cubit / bloc ──► use case ──► repository (abstract, domain)
                                              ▲
                                              │ implements
                                 repository impl (data) ──► RemoteService / Hive
```

- **domain/**: entities (plain Dart, Equatable), abstract repositories (the swap points), use cases (one action each). No Flutter, Dio, Hive or JSON here.
- **data/**: models (JSON shape), mappers (model ↔ entity), repository implementations (`remote/` talks to the network, `local/` to Hive or secure storage).
- **presentation/**: cubits/blocs with their states, screens (`views/`), widgets.
- **utils/**: the module's constants (api routes, strings, errors, dummy data), helpers, storage keys.

The full folder layout is in [project structure](project_structure.md); names are in [conventions](conventions.md).

## State management

- `flutter_bloc`. Default to a **Cubit**; use a **Bloc** when transitions come from typed events (search with debounce, auth state).
- Cubits extend `SafeCubit` (`lib/common/bloc/safe_cubit.dart`): `emit` does nothing after close, so a late reply can't crash a closed screen.
- State is minimal: `loadingState` (`AppLoadingState`: initial, loading, success, failure), the data, `error`.
- Cubits are not registered in DI. They take their use cases from `getIt` in field initialisers, so a screen just writes `BlocProvider(create: (_) => XCubit()..load())`.
- App-wide blocs (theme, app settings, auth, package/device info) are provided once in `global_bloc_config.dart`. Screen blocs are provided by their screen.

## Dependency injection

`get_it` + `injectable`. Repositories, use cases and services carry annotations (`@injectable`, `@LazySingleton(as: X)`), and `dart run build_runner build` writes `lib/core/di/injection.config.dart`. Details: [dependency injection](core/dependency_injection.md).

## Network and auth

`RemoteService` (`lib/core/network/`) is the only HTTP gateway. It signs requests, refreshes tokens, retries and turns failures into `ServerException`s with a readable message. The auth module plugs its tokens in by registering an `AuthTokenHandler`. The network layer looks it up per request and never imports auth, so deleting the auth module leaves HTTP working with unsigned requests. Details: [network](core/network.md), [auth](modules/auth.md).

## Start-up order

`lib/main.dart`:

1. The FCM background handler (`FirebaseMessaging.onBackgroundMessage`), which must be registered before anything else.
2. `.env` (`EnvHelper.init`).
3. HydratedBloc storage, then Hive with every module's box (`Hive.openAllBoxes()`).
4. `Bloc.observer`, portrait lock, `configureDependencyInjection()`.
5. Local notifications, Firebase (when `FIREBASE_ENABLED=true` and `firebase_options.dart` exist), FCM.
6. `runApp(ScaleKitBuilder(... StarterApp()))`.
7. After the first frame: the Mobile Ads SDK (consent and ATT prompts need a visible app). Then Crashlytics and Analytics.

`StarterApp` (`lib/app/apps.dart`) wraps the app in the popup loader host and the global blocs. `StarterAppView` (`lib/app/app_view.dart`) builds the theme, `MaterialApp.router`, one status-bar style for the whole app, and `AppBootstrappers`.

## Hidden details

- `AuthBloc` is created eagerly (`lazy: false`) so the saved session is restored while the splash screen shows.
- The router is a top-level `GoRouter` (`lib/core/router/app_router.dart`); widgets above the navigator (bootstrappers) reach it through `router`, not `context`.
- Text scaling is clamped to 1.2 in `app_view.dart` so system font sizes can't break layouts.
- Barrels cost nothing at runtime: `export` lines are compile-time only and unused symbols are tree-shaken.
