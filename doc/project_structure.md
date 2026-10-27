# Project structure

Where everything lives, and where a new file goes.

## Repository root

```
.
├── lib/                    the app (below)
├── test/                   tests, mirroring lib/
├── tool/rename_app.dart    turns the starter into your app (see getting started)
├── doc/                    this documentation
├── assets/                 fonts, images, logos, ad creatives
├── android/ ios/ web/      platform projects
├── .env_example            every .env key the app reads (copy to .env)
├── analysis_options.yaml   lints (flutter_lints)
└── pubspec.yaml            packages, grouped by purpose (each module page's "Depends on" lists its own)
```

## `lib/`

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  barrel
│   ├── apps.dart                 StarterApp: GlobalBlocConfig around StarterAppView
│   ├── app_view.dart             theme, MaterialApp.router, status-bar style, popup loader host
│   ├── app_bootstrappers.dart    app-wide listeners (update alert, auth edges)
│   ├── global_bloc_config.dart   app-wide BlocProviders
│   └── hive_bootstrap.dart       opens / clears every Hive box registered in it
├── core/
│   ├── di/                       get_it + injectable (injection.config.dart is generated)
│   ├── errors/                   exceptions, AppErrorHandler, AppErrorStrings
│   ├── network/                  Dio client, interceptors, RemoteService
│   ├── router/                   Routes enum, GoRouter, observers, AssetRoutes
│   ├── services/                 Firebase, share
│   ├── theme/                    theme builder, colors, component themes, typography, cubit, sources/presets, variants, ThemeExtension
│   └── utils/                    constants (EnvConfig, CommonStrings), enums, extensions, helpers
├── common/
│   ├── bloc/                     SafeCubit, PaginatedListState, PasswordVisibilityCubit
│   ├── observers/                AppBlocObserver
│   ├── usecases/                 UseCase, StreamUseCase, NoParams
│   └── widgets/                  ErrorView, loaders, text fields, image/svg wrappers, ...
└── modules/
    └── <module>/                 one folder per feature (below)
```

## A module

```
modules/<feature>/
├── <feature>.dart              top barrel: the only import other code uses
├── bootstrapper/               widget that wires the module into the app shell (optional)
├── argument/                   route arguments: <Subject><Screen>Args (optional)
├── data/
│   ├── model/                  JSON shape: all-nullable, fromJson/toJson/copyWith
│   ├── mapper/                 model ↔ entity
│   └── repository/
│       ├── local/              Local<Subject>RepositoryImpl (Hive, secure storage)
│       └── remote/             Remote<Subject>RepositoryImpl (RemoteService)
├── domain/
│   ├── entity/                 plain Dart types the app reasons about
│   ├── repository/{local,remote}/   abstract contracts (the swap points)
│   └── use_case/{local,remote}/     one action per class
├── features/                   sub-features of a big module, each shaped like a module (optional)
├── presentation/
│   ├── bloc/<name>/            <name>_cubit.dart (+ part <name>_state.dart) or _bloc/_event/_state
│   ├── views/                  <name>_screen.dart: <Name>Screen + <Name>View
│   └── widgets/                one widget per file, optional sub-folder per screen
└── utils/
    ├── constants/              <feature>_api_route.dart, _strings.dart, _error.dart, _constants.dart, _dummy.dart
    ├── helper/                 services and helpers
    ├── storage_helper/         <subject>_storage_keys.dart, <subject>_hive.dart
    ├── enums/
    └── extensions/
```

Only create the folders you use. Every folder gets a barrel named after it (`domain/domain.dart`, `widgets/widgets.dart`) that exports its files and sub-barrels.

## Where does a new file go?

| You're adding | Put it in |
|---|---|
| The JSON shape an endpoint returns | `data/model/` |
| A business type the app reasons about | `domain/entity/` |
| Translation between the two | `data/mapper/` |
| What the backend can do (contract) | `domain/repository/remote/` |
| What local storage can do (contract) | `domain/repository/local/` |
| The REST / Supabase / Firebase implementation | `data/repository/remote/` |
| The Hive / secure-storage implementation | `data/repository/local/` |
| One action the UI can trigger | `domain/use_case/{local,remote}/` (same side as its repository) |
| UI state | `presentation/bloc/<name>/` |
| A screen | `presentation/views/` |
| A widget used by this module only | `presentation/widgets/` |
| A widget used by several modules | `lib/common/widgets/` |
| Endpoint paths | `utils/constants/<feature>_api_route.dart` |
| User-facing text | `utils/constants/<feature>_strings.dart` (`_error.dart` for failures) |
| Skeleton placeholder data | `utils/constants/<feature>_dummy.dart` |
| Hive / secure-storage keys and the box opener | `utils/storage_helper/`; register the opener and clearer in `lib/app/hive_bootstrap.dart` |

## `local/` vs `remote/`

Split by the data source a class talks to. Network (REST, Supabase, Firebase) is `remote/`; Hive, secure storage and SQLite are `local/`. A use case sits on the same side as the repository it calls. A module with one side only keeps just that folder. Platform plugins fit neither side: device_info and package_info wrap theirs in `remote/` repositories, notifications wraps `flutter_local_notifications` in a `local/` one.

## Hidden details

- Generated files: `lib/core/di/injection.config.dart` and any `*.g.dart`. Never edit them by hand.
- `lib/firebase_options.dart` is written by `flutterfire configure` and gitignored. Nothing imports it until you uncomment the import and the `options:` line in `lib/core/services/firebase_service.dart`.
- A module's top barrel is for other modules. Inside the module, import the nearest layer barrel instead (`.../auth/domain/domain.dart`); importing your own top barrel pulls the whole module into every file.
