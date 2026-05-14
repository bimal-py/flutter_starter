# Flutter Starter

Opinionated Flutter starter with a feature-first architecture, Material 3 theming, swappable backend layers, and a set of optional modules (auth, push, image picker, in-app upgrade alerts, …) that delete cleanly when you don't need them.

```
flutter pub get
dart run build_runner build
flutter run
```

`.env` lives at the project root and is loaded by `flutter_dotenv` — see [`.env.example`](.env.example) for the keys the starter reads.

---

## Table of contents

- [What's in the box](#whats-in-the-box)
- [Architecture at a glance](#architecture-at-a-glance)
- [Module folder convention](#module-folder-convention)
- [Adding a new module](#adding-a-new-module)
- [Adding utilities to a module](#adding-utilities-to-a-module)
- [Do's and don'ts](#dos-and-donts)
- **Reference (setup / use / remove per feature):**
  - [Theme](#theme)
  - [Localization & per-locale fonts](#localization--per-locale-fonts)
  - [State management (BLoC)](#state-management-bloc)
  - [Dependency injection](#dependency-injection)
  - [Routing](#routing)
  - [Responsive sizing](#responsive-sizing)
  - [Storage](#storage)
  - [Toasts](#toasts)
  - [Network / API layer](#network--api-layer) *(removable)*
  - [Auth](#auth) *(removable, backend-swappable)*
  - [Notifications](#notifications) *(removable, package-swappable)*
  - [FCM (push)](#fcm-push) *(removable)*
  - [App upgrade alert](#app-upgrade-alert) *(removable, needs Firebase Remote Config)*
  - [Image picker](#image-picker) *(removable)*
  - [Firebase](#firebase) *(opt-in)*
  - [Onboarding replay](#onboarding-replay)
- [Removability cheat sheet](#removability-cheat-sheet)
- [Q&A](#qa)
- [Build & ship](#build--ship)

---

## What's in the box

| Capability | Path | Optional? |
|---|---|---|
| Material 3 theming + 38-field semantic extension | [`lib/core/theme/`](lib/core/theme/) | No (core) |
| Brand-style preset themes (Christmas / Ocean / …) | [`lib/core/theme/source/theme_presets.dart`](lib/core/theme/source/theme_presets.dart) | No (replace list) |
| End-user theme playground (seed / image / dynamic device colors) | [`lib/modules/settings/`](lib/modules/settings/) | Removable |
| Per-locale fonts + scale | [`lib/core/theme/typography/`](lib/core/theme/typography/) | No (replace map) |
| BLoC + HydratedBloc persistence | App-wide | No |
| `get_it` + `injectable` DI | [`lib/core/di/`](lib/core/di/) | No |
| `go_router` typed routes | [`lib/core/router/`](lib/core/router/) | No |
| `flutter_scale_kit` responsive sizing | App-wide | Replaceable |
| Hive + `flutter_secure_storage` + HydratedBloc | App-wide | No |
| `CustomSnackbar` toasts | [`lib/common/widgets/`](lib/common/widgets/) | No |
| Dio network stack (interceptors, token refresh hook, logout interceptor) | [`lib/core/network/`](lib/core/network/) | Yes |
| Pluggable auth (REST / Firebase / Supabase / your own) | [`lib/modules/auth/`](lib/modules/auth/) | Yes |
| Local notifications (pluggable provider) | [`lib/modules/notifications/`](lib/modules/notifications/) | Yes |
| FCM push with action buttons + background display | [`lib/modules/fcm/`](lib/modules/fcm/) | Yes |
| Firebase Remote Config-driven update alert | [`lib/modules/app_upgrade/`](lib/modules/app_upgrade/) | Yes |
| Image picker + compression (single / multi / camera / gallery) | [`lib/modules/image_picker/`](lib/modules/image_picker/) | Yes |
| Onboarding replay | [`lib/modules/onboarding/`](lib/modules/onboarding/) | Replaceable |
| QR share popup (themed, scanner-safe) | [`lib/modules/qr/`](lib/modules/qr/) | Removable |
| Device / package info screens | [`lib/modules/device_info/`](lib/modules/device_info/) [`lib/modules/package_info/`](lib/modules/package_info/) | Removable |
| In-app webview wrapper | [`lib/modules/website_view/`](lib/modules/website_view/) | Removable |

---

## Architecture at a glance

```
lib/
├── main.dart                     app bootstrap; one line per optional module
├── app/                          composition root (StarterApp, BlocProviders, Hive bootstrap)
├── core/                         framework — never imports anything from lib/modules/
│   ├── di/                       get_it + injectable
│   ├── errors/                   AppException family, AppErrorStrings, AppErrorHandler
│   ├── network/                  Dio + interceptors + token refresh + ApiErrorStrings
│   ├── router/                   go_router config + typed Routes enum
│   ├── services/                 Firebase service (opt-in)
│   ├── theme/                    sources, cubit, extension, typography, presets
│   └── utils/                    EnvConfig, constants, helpers, extensions, enums (AppLoadingState)
├── common/                       reusable widgets, BlocObserver, UseCase / StreamUseCase / NoParams
└── modules/                      features (one folder per)
```

**Import rule of thumb**

```
modules/  ──►  core/ + common/        (allowed)
core/     ──►  nothing in lib/modules/ (NOT allowed — core stays generic)
common/   ──►  core/                  (allowed, but resist depending on modules)
```

Modules can call each other only through their public barrel (e.g. `import 'package:flutter_starter/modules/notifications/notifications.dart';`). Never reach into a sibling module's internals.

---

## Module folder convention

Every module (other than tiny cubit-only ones) follows this shape:

```
modules/<feature>/
├── <feature>.dart                 top-level barrel — the ONLY public surface
├── bootstrapper/                  optional. Widget(s) that wire the module into the app shell.
├── data/
│   ├── data.dart                  barrel
│   ├── model/                     JSON-shaped DTOs
│   │   └── model.dart             barrel
│   ├── mapper/                    model ↔ entity translators
│   │   └── mapper.dart            barrel
│   └── repository/                repository implementations (impls of domain/repository contracts)
│       ├── repository.dart        barrel (re-exports local/ + remote/ when both exist)
│       ├── local/                 impls backed by Hive / SecureStorage / SharedPreferences
│       │   └── local.dart         barrel
│       └── remote/                impls backed by your API / Firebase / Supabase / …
│           └── remote.dart        barrel
├── domain/
│   ├── domain.dart                barrel
│   ├── entity/                    pure-Dart business types (no Dio, no Hive, no JSON)
│   │   └── entity.dart            barrel
│   ├── repository/                abstract repository interfaces (the swap points)
│   │   ├── repository.dart        barrel
│   │   ├── local/                 contracts for local-only data sources
│   │   │   └── local.dart         barrel
│   │   └── remote/                contracts for network-backed data sources
│   │       └── remote.dart        barrel
│   └── use_case/                  UseCase<R,P> wrappers around repo calls.
│       ├── use_case.dart          barrel
│       ├── local/                 use cases that call local repositories
│       │   └── local.dart         barrel
│       └── remote/                use cases that call remote repositories
│           └── remote.dart        barrel
├── presentation/
│   ├── presentation.dart          barrel
│   ├── bloc/                      blocs or cubits, one folder per
│   │   ├── bloc.dart              barrel
│   │   └── <bloc_name>/
│   │       ├── <bloc_name>.dart   barrel
│   │       ├── <bloc_name>_bloc.dart   (or _cubit.dart)
│   │       ├── <bloc_name>_event.dart  (part of _bloc.dart)
│   │       └── <bloc_name>_state.dart  (part of _bloc.dart)
│   ├── views/                     screens (Scaffold + BlocProvider for that screen)
│   │   └── views.dart             barrel
│   └── widgets/                   small reusable widgets *for this module only*
│       └── widgets.dart           barrel
└── utils/
    ├── utils.dart                 barrel
    ├── constants/                 module-scoped constants
    ├── helper/                    service-style helpers (`*_service.dart`, `*_helper.dart`)
    ├── storage_helper/            keys + adapters for Hive / SecureStorage
    ├── enums/                     module-scoped enums
    └── extensions/                module-scoped extension methods
```

### `local/` vs `remote/`

Inside `repository/` and `use_case/`, split files by **which data source they talk to**:

- A class that talks to your API / Firebase / Supabase / any network service → `remote/`.
- A class that talks only to Hive / SecureStorage / SharedPreferences → `local/`.
- A use case lives in the same subfolder as the repository it calls. (`AuthRepository` is remote → every auth use case sits in `domain/use_case/remote/`, even the ones whose backend impl happens to read from local cache.)
- When a module only has one direction (e.g. push notifications are all-remote, FCM token storage is all-local), you can stay flat — but it's fine to keep a single `remote/` or `local/` subfolder for consistency.

Modules that don't have a "repository" concept at all (image picker, app upgrade, theme — utility-shaped) skip both subfolders.

### When to use which subdirectory

| You're adding… | Put it in… |
|---|---|
| A JSON shape coming back from the API | `data/model/` |
| A pure business object the rest of the app reasons about | `domain/entity/` |
| Translation between the two | `data/mapper/` |
| The "what the backend does" contract | `domain/repository/remote/` |
| The "what local storage does" contract | `domain/repository/local/` |
| A network-backed implementation (REST / Firebase / Supabase) | `data/repository/remote/` |
| A storage-backed implementation (Hive / SecureStorage) | `data/repository/local/` |
| A use case that calls a remote repository | `domain/use_case/remote/` |
| A use case that calls a local repository | `domain/use_case/local/` |
| A Bloc / Cubit for UI state | `presentation/bloc/<name>/` |
| A whole screen | `presentation/views/` |
| A widget used by several screens in this module | `presentation/widgets/` |
| A widget used by several modules | `lib/common/widgets/` instead |
| A constant only this module cares about | `utils/constants/` |
| Module-scoped helpers (services, formatters, calculators) | `utils/helper/` |
| Hive keys / SecureStorage keys / adapters | `utils/storage_helper/` |
| An enum scoped to this module | `utils/enums/` |
| Extension methods scoped to this module | `utils/extensions/` |
| A widget that wraps the app shell to wire the module in | `bootstrapper/` |

### Barrel files

Each subfolder has a tiny barrel (`entity.dart`, `repository.dart`, `domain.dart`, …) and the module exposes one top-level barrel (`auth.dart`, `fcm.dart`, …). Consumers import only the top-level one.

**Does adding barrels bloat the app?** No. They contain `export` lines only — pure compile-time directives. The Dart compiler tree-shakes unreferenced exports, so a barrel exporting 50 symbols ships only the ones you actually reference. Zero runtime cost, zero binary-size cost.

---

## Adding a new module

Worked recipe — adding an `astrologer_review` feature that fetches reviews from a REST API. Walks every layer (entity → model → mapper → abstract repository → impl → use case → cubit → barrel → wire).

### 1. Scaffold the folders

```bash
mkdir -p lib/modules/astrologer_review/{data/{model,mapper,repository/remote},domain/{entity,repository/remote,use_case/remote},presentation/{bloc,views,widgets},utils/{constants,helper}}
```

This feature only talks to the API, so we go straight to `remote/`. If it also cached locally, we'd add `repository/local/` and `use_case/local/` alongside.

### 2. Entity (domain language)

`lib/modules/astrologer_review/domain/entity/astrologer_review_entity.dart`:

```dart
import 'package:equatable/equatable.dart';

class AstrologerReviewEntity extends Equatable {
  const AstrologerReviewEntity({
    this.astrologer,
    this.user,
    this.rating,
    this.comment,
    this.createdAt,
  });

  final int? astrologer;
  final AstrologerReviewerEntity? user;
  final double? rating;
  final String? comment;
  final DateTime? createdAt;

  bool get hasComment => comment?.trim().isNotEmpty ?? false;
  bool get hasRating => (rating ?? 0) > 0;

  @override
  List<Object?> get props => [astrologer, user, rating, comment, createdAt];
}

class AstrologerReviewerEntity extends Equatable {
  const AstrologerReviewerEntity({this.fullName, this.profilePic});
  final String? fullName;
  final String? profilePic;

  @override
  List<Object?> get props => [fullName, profilePic];
}
```

### 3. Model (wire format)

`lib/modules/astrologer_review/data/model/astrologer_review_model.dart`:

```dart
class AstrologerReviewModel {
  AstrologerReviewModel({
    this.astrologer,
    this.user,
    this.rating,
    this.comment,
    this.createdAt,
  });

  final int? astrologer;
  final AstrologerReviewerModel? user;
  final double? rating;
  final String? comment;
  final DateTime? createdAt;

  factory AstrologerReviewModel.fromJson(Map<String, dynamic> json) =>
      AstrologerReviewModel(
        astrologer: json['astrologer'],
        user: json['user'] == null
            ? null
            : AstrologerReviewerModel.fromJson(json['user']),
        rating: (json['rating'] as num?)?.toDouble(),
        comment: json['comment'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
    'astrologer': astrologer,
    'user': user?.toJson(),
    'rating': rating,
    'comment': comment,
    'created_at': createdAt?.toIso8601String(),
  };
}

class AstrologerReviewerModel {
  AstrologerReviewerModel({this.fullName, this.profilePic});
  final String? fullName;
  final String? profilePic;

  factory AstrologerReviewerModel.fromJson(Map<String, dynamic> json) =>
      AstrologerReviewerModel(
        fullName: json['full_name'],
        profilePic: json['profile_pic'],
      );

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'profile_pic': profilePic,
  };
}
```

### 4. Mapper

`lib/modules/astrologer_review/data/mapper/astrologer_review_mapper.dart`:

```dart
import 'package:flutter_starter/modules/astrologer_review/astrologer_review.dart';

class AstrologerReviewMapper {
  AstrologerReviewMapper._();

  static AstrologerReviewEntity toEntity(AstrologerReviewModel m) =>
      AstrologerReviewEntity(
        astrologer: m.astrologer,
        user: m.user == null
            ? null
            : AstrologerReviewerEntity(
                fullName: m.user?.fullName,
                profilePic: m.user?.profilePic,
              ),
        rating: m.rating,
        comment: m.comment,
        createdAt: m.createdAt,
      );

  static List<AstrologerReviewEntity> fromJsonListToEntityList(
    List<dynamic> jsonList,
  ) => jsonList
      .map((json) => toEntity(
            AstrologerReviewModel.fromJson(json as Map<String, dynamic>),
          ))
      .toList();
}
```

### 5. Abstract repository (the swap point)

`lib/modules/astrologer_review/domain/repository/remote/remote_astrologer_review_repository.dart`:

```dart
import 'package:flutter_starter/modules/astrologer_review/astrologer_review.dart';

abstract class RemoteAstrologerReviewRepository {
  Future<List<AstrologerReviewEntity>> fetchAstrologerReviews();
}
```

### 6. Concrete implementation

`lib/modules/astrologer_review/data/repository/remote/remote_astrologer_review_repository_impl.dart`:

```dart
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/astrologer_review/astrologer_review.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RemoteAstrologerReviewRepository)
class RemoteAstrologerReviewRepositoryImpl
    implements RemoteAstrologerReviewRepository {
  RemoteAstrologerReviewRepositoryImpl(this._remote);

  final RemoteService _remote;

  @override
  Future<List<AstrologerReviewEntity>> fetchAstrologerReviews() async {
    final response = await _remote.get(
      endpoint: 'astrologer/reviews',
      authRequired: true,
    );
    if (response is Map<String, dynamic> && response['data'] is List) {
      return AstrologerReviewMapper.fromJsonListToEntityList(
        response['data'] as List<dynamic>,
      );
    }
    throw const ServerException(message: AppErrorStrings.invalidResponseShape);
  }
}
```

### 7. Use case

`lib/modules/astrologer_review/domain/use_case/remote/remote_fetch_astrologer_reviews_use_case.dart`:

```dart
import 'dart:async';

import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/astrologer_review/astrologer_review.dart';
import 'package:injectable/injectable.dart';

@injectable
class RemoteFetchAstrologerReviewsUseCase
    extends UseCase<List<AstrologerReviewEntity>, NoParams> {
  RemoteFetchAstrologerReviewsUseCase(this._repository);

  final RemoteAstrologerReviewRepository _repository;

  @override
  FutureOr<List<AstrologerReviewEntity>> execute(NoParams params) =>
      _repository.fetchAstrologerReviews();
}
```

Why a use case for a one-line wrapper? Three reasons: blocs grep readably ("which use cases does this bloc consume?"), method names like `RemoteFetchAstrologerReviewsUseCase` become the unit of testing, and adding cross-cutting logic later (caching, analytics, retry) has a single home.

### 8. Cubit

`lib/modules/astrologer_review/presentation/bloc/load_astrologer_reviews/load_astrologer_reviews_cubit.dart`:

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/astrologer_review/astrologer_review.dart';

part 'load_astrologer_reviews_state.dart';

class LoadAstrologerReviewsCubit extends Cubit<LoadAstrologerReviewsState> {
  LoadAstrologerReviewsCubit() : super(const LoadAstrologerReviewsState());

  final RemoteFetchAstrologerReviewsUseCase _fetchUseCase =
      getIt<RemoteFetchAstrologerReviewsUseCase>();

  Future<void> loadAstrologerReviews() async {
    emit(state.copyWith(
      loadingState: AppLoadingState.loading,
      clearError: true,
    ));
    try {
      final reviews = await _fetchUseCase.execute(const NoParams());
      emit(state.copyWith(
        loadingState: AppLoadingState.success,
        reviews: reviews,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        loadingState: AppLoadingState.failure,
        error: AppErrorHandler.getErrorMessage(error),
      ));
    }
  }

  Future<void> reloadAstrologerReviews() => loadAstrologerReviews();
}
```

Note three things every bloc/cubit should do:

1. **Resolve use cases via `getIt<…>()`** as final fields, not via constructor injection. Cubit has no required deps so screens can `BlocProvider(create: (_) => LoadAstrologerReviewsCubit()..loadAstrologerReviews())`.
2. **Use `AppLoadingState`** from [`lib/core/utils/enums/app_loading_state.dart`](lib/core/utils/enums/app_loading_state.dart) — `initial / loading / success / failure` — instead of inventing per-bloc loading enums.
3. **Run every catch through `AppErrorHandler.getErrorMessage(error)`** — turns `SocketException` into "No internet", `AppException` into its message, anything else into a safe fallback.

State:

```dart
part of 'load_astrologer_reviews_cubit.dart';

class LoadAstrologerReviewsState extends Equatable {
  const LoadAstrologerReviewsState({
    this.loadingState = AppLoadingState.initial,
    this.reviews = const [],
    this.error,
  });

  final AppLoadingState loadingState;
  final List<AstrologerReviewEntity> reviews;
  final String? error;

  LoadAstrologerReviewsState copyWith({
    AppLoadingState? loadingState,
    List<AstrologerReviewEntity>? reviews,
    String? error,
    bool clearError = false,
  }) => LoadAstrologerReviewsState(
    loadingState: loadingState ?? this.loadingState,
    reviews: reviews ?? this.reviews,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loadingState, reviews, error];
}
```

### 9. Barrels

One per folder. Keep them mechanical:

```dart
// lib/modules/astrologer_review/domain/entity/entity.dart
export 'astrologer_review_entity.dart';

// lib/modules/astrologer_review/domain/repository/remote/remote.dart
export 'remote_astrologer_review_repository.dart';

// lib/modules/astrologer_review/domain/repository/repository.dart
export 'remote/remote.dart';                       // add `local/local.dart` if local/ exists

// lib/modules/astrologer_review/domain/use_case/remote/remote.dart
export 'remote_fetch_astrologer_reviews_use_case.dart';

// lib/modules/astrologer_review/domain/use_case/use_case.dart
export 'remote/remote.dart';

// lib/modules/astrologer_review/domain/domain.dart
export 'entity/entity.dart';
export 'repository/repository.dart';
export 'use_case/use_case.dart';
```

Same skeleton for `data/repository/remote/remote.dart` and `data/data.dart`. Top-level barrel `lib/modules/astrologer_review/astrologer_review.dart`:

```dart
export 'data/data.dart';
export 'domain/domain.dart';
export 'presentation/presentation.dart';
```

### 10. Regenerate DI

```bash
dart run build_runner build
```

### 11. Use it

```dart
BlocProvider(
  create: (_) => LoadAstrologerReviewsCubit()..loadAstrologerReviews(),
  child: BlocBuilder<LoadAstrologerReviewsCubit, LoadAstrologerReviewsState>(
    builder: (context, state) => switch (state.loadingState) {
      AppLoadingState.loading => const CircularProgressIndicator(),
      AppLoadingState.success => ReviewsList(items: state.reviews),
      AppLoadingState.failure => ErrorBanner(message: state.error!),
      AppLoadingState.initial => const SizedBox(),
    },
  ),
)
```

That's the full recipe. The same shape applies whether the backend is REST, Firebase, Supabase, or local-only — only the repository implementation changes.

### UseCase + StreamUseCase

Both contracts live in [`lib/common/usecases/`](lib/common/usecases/):

```dart
abstract class UseCase<ReturnType, Params> {
  FutureOr<ReturnType> execute(Params params);
}

abstract class StreamUseCase<ReturnType, Params> {
  Stream<ReturnType> execute(Params params);
}

class NoParams extends Equatable { ... }
```

Use `UseCase` for one-shot actions, `StreamUseCase` for live data (auth state, chat messages, presence). When a use case takes no input, use `NoParams()` — never make `Params` nullable.

### Error handling at the bloc level

[`AppErrorHandler.getErrorMessage(error)`](lib/core/errors/error_handler.dart) is the one place that turns a caught `Object` into a user-presentable string. Every bloc's catch block should funnel through it:

```dart
try {
  ...
} catch (error) {
  emit(state.copyWith(
    loadingState: AppLoadingState.failure,
    error: AppErrorHandler.getErrorMessage(error),
  ));
}
```

It handles:
- `SocketException` → `AppErrorStrings.noInternetConnection`
- `AppException` (and subclasses: `ServerException`, `AuthenticationException`, …) → `error.message`
- anything else → `AppErrorStrings.somethingWentWrong`

If you need a feature-specific failure message, declare a constant in `lib/modules/<feature>/utils/constants/<feature>_error_strings.dart` and throw it as `ServerException(message: MyErrorStrings.x)`. The handler picks up `error.message` for free.

---

## Adding utilities to a module

Quick decision tree for *where* to put a new helper:

| The thing you're adding | Where |
|---|---|
| A constant string / int / list (only this module reads it) | `<module>/utils/constants/` |
| A function that wraps a platform API (sharing, vibrating, capturing) | `<module>/utils/helper/` as `<thing>_helper.dart` |
| A singleton service the module owns | `<module>/utils/helper/` as `<name>_service.dart` |
| Hive / SecureStorage key constants | `<module>/utils/storage_helper/` |
| An enum used only in this module | `<module>/utils/enums/` |
| Extension methods on `BuildContext` / strings / numbers, scoped to this module | `<module>/utils/extensions/` |
| Same as above but used everywhere | `lib/core/utils/extensions/` instead |

**Always update the matching barrel** (`helper.dart`, `constants.dart`, etc.) when you add a file — that way external imports only ever touch the top-level module barrel.

---

## Do's and don'ts

**Do**

- Import other modules through their top-level barrel (`.../auth.dart`) — never reach into `.../auth/domain/repository/auth_repository.dart` directly.
- Keep `core/` module-agnostic. If `core/` needs something module-shaped, put a contract in `core/` and the implementation in a module.
- Wrap every repository method in a use case (`UseCase` or `StreamUseCase`), even one-liners. Blocs resolve them via `getIt<…>()` as final fields. See [Adding a new module](#adding-a-new-module).
- Funnel every bloc / cubit `catch` through [`AppErrorHandler.getErrorMessage(error)`](lib/core/errors/error_handler.dart) instead of building error strings inline.
- Use [`AppLoadingState`](lib/core/utils/enums/app_loading_state.dart) for loading-state enums in bloc states — don't invent per-bloc variants.
- Throw typed `AppException` subclasses ([`lib/core/errors/exceptions.dart`](lib/core/errors/exceptions.dart)). Don't `throw 'string'` or rethrow Dio types past your repository.
- Validate at boundaries (parsed JSON, user input). Trust internal callers.
- Use `context.colorScheme`, `context.textTheme`, `context.read<X>()` extensions ([`lib/core/utils/extensions/context_extension.dart`](lib/core/utils/extensions/context_extension.dart)) — they're shorter and read better.
- Use `12.r`, `16.w`, `8.h` from `flutter_scale_kit` for sizes/paddings — fixed pixels look wrong at non-default device font scales.

**Don't**

- Don't reach `getIt<X>()` from inside a widget. Resolve at the cubit / bloc level (final field), pass primitives through the constructor when needed. Widgets stay testable.
- Don't put a bloc that's tied to a screen into [`global_bloc_config.dart`](lib/app/global_bloc_config.dart). That file is for app-lifecycle cubits (theme, auth, app settings). Screen-scoped blocs belong in a `BlocProvider` next to the screen.
- Don't surface raw `error.toString()` to users — go through `AppErrorHandler` so `SocketException` reads "No internet" instead of `SocketException: Failed host lookup …`.
- Don't write comments that re-state code. Comments are for the *why* — surprising constraints, prior incidents, backend quirks.
- Don't hard-code `Colors.white` / `Colors.black` in UI unless you literally need a fixed value (e.g. a QR pattern). Use the theme.
- Don't mock the database in integration tests — the in-memory implementations (e.g. [`InMemoryAuthRepository`](lib/modules/auth/data/repository/remote/in_memory_auth_repository.dart)) exist specifically so tests can use the real persistence without a backend.

---

## Theme

The theme system has three layers:

1. **Developer source** — what your app code wires at startup. Defaults to `SeedOnlySource(seed: AppColors.seed, accent: AppColors.accent)`.
2. **User override** — what the in-app playground writes. When set, wins over the developer's source. Cleared via Reset.
3. **Variants** — light / dark / system (extensible via `ThemeVariant.custom(name)`).

All theming flows through [`lib/core/theme/`](lib/core/theme/).

### Setup

Edit [`lib/core/theme/colors/app_colors.dart`](lib/core/theme/colors/app_colors.dart):

```dart
class AppColors {
  AppColors._();
  static const Color seed = Color(0xFF1B3A6B);   // your brand
  static const Color accent = Color(0xFFC8A96B); // optional, harmonized to seed
}
```

To opt into device wallpaper colors (Android 12+), wire a different default source in [`lib/app/global_bloc_config.dart`](lib/app/global_bloc_config.dart):

```dart
BlocProvider<ThemeCubit>(
  create: (_) => ThemeCubit(
    developerSource: DynamicDeviceSource(fallbackSeed: AppColors.seed),
  ),
),
```

### Use

```dart
final scheme = Theme.of(context).colorScheme;
final ext = Theme.of(context).extension<CustomThemeExtension>()!;
Container(color: scheme.primaryContainer);
Container(color: ext.success);
Container(color: ext.brandAccent);
Text('Hi', style: context.textTheme.titleMedium);
```

### ThemeSource variants

| Variant | When to use |
|---|---|
| `SeedOnlySource` | Default. Pick one brand color; Material 3 derives the rest. |
| `SeedWithOverridesSource` | Seed + override specific Material roles. |
| `FullCustomSource` | Hand every color and TextTheme entry. |
| `DynamicDeviceSource` | Use device wallpaper colors (Android 12+). |
| `FromImageSource` | Extract dominant color from an image (camera, gallery, asset). |

### Preset themes (Christmas / Ocean / Sunset / …)

[`lib/core/theme/source/theme_presets.dart`](lib/core/theme/source/theme_presets.dart) ships six seasonal/brand looks. Replace with your own from `main.dart` before MaterialApp builds:

```dart
ThemePresets.register([
  ThemePreset(id: 'brand-a', label: 'Brand A',
              swatch: Color(0xFF…),
              source: SeedOnlySource(seed: Color(0xFF…), accent: Color(0xFF…))),
]);
```

The playground picks them up automatically.

### CustomThemeExtension — surviving scheme changes

When you customize semantic colors (success, brandAccent, gradient stops, …) and use dynamic device colors or image-derived seeds, your tweaks would be lost the moment the scheme changes. Wire a builder so they re-apply against any scheme:

```dart
BlocProvider<ThemeCubit>(
  create: (_) => ThemeCubit(
    extensionBuilder: (scheme, brightness) =>
        (brightness == Brightness.dark
            ? CustomThemeExtension.darkDefault(scheme)
            : CustomThemeExtension.lightDefault(scheme))
        .copyWith(
          heroGradientStart: scheme.tertiary,    // your tweaks
          ratingActive: const Color(0xFFFEA500),
        ),
  ),
),
```

### Theme playground (end-user customization)

Settings → "Customize theme" opens a screen where the user picks brightness + preset + source + seed (or image). Writes to `ThemeCubit.userOverride`; Reset restores the developer's source. No code needed — it's already wired.

### Remove

Theme is non-removable — it's how the app draws. To remove the playground:
- Delete [`lib/modules/settings/presentation/views/theme_playground_screen.dart`](lib/modules/settings/presentation/views/theme_playground_screen.dart) and the matching tile widget.
- Drop the `themePlayground` route from [`routes.dart`](lib/core/router/routes.dart) + [`app_router.dart`](lib/core/router/app_router.dart).
- Remove `flutter_colorpicker` from [`pubspec.yaml`](pubspec.yaml).

To remove device dynamic colors:
- Stop using `DynamicDeviceSource`.
- Unwrap `DynamicColorBuilder` in [`lib/app/app.dart`](lib/app/app.dart).
- Remove `dynamic_color` from pubspec.

---

## Localization & per-locale fonts

Some scripts (Devanagari, Bengali, Arabic) render visually smaller than Latin at the same `fontSize`. [`LocalizedFonts`](lib/core/theme/typography/localized_fonts.dart) maps locale → `AppFont(family, scale)`.

### Setup

Add font files to `assets/fonts/`, declare them in [`pubspec.yaml`](pubspec.yaml), then edit `LocalizedFonts.defaults()`:

```dart
factory LocalizedFonts.defaults() => const LocalizedFonts(
  defaultFont: AppFont(family: 'Inter', scale: 1.0),
  byLocale: {
    'ne': AppFont(family: 'Mukta', scale: 1.10),
    'hi': AppFont(family: 'Mukta', scale: 1.10),
  },
);
```

### Use

The `TextTheme` from `Theme.of(context)` already carries the right family + scale. Use `context.textTheme.bodyMedium` etc. — don't hard-code `TextStyle(fontSize: 16)`.

### Remove

Drop the entry from `LocalizedFonts.defaults()` and the asset from `pubspec.yaml`.

---

## State management (BLoC)

Default to `Cubit`. Use `Bloc` when state transitions naturally come from typed events (auth, complex flows).

App-wide cubits live in [`lib/app/global_bloc_config.dart`](lib/app/global_bloc_config.dart). HydratedCubit persists their state automatically.

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}
```

```dart
context.read<CounterCubit>().increment();
BlocBuilder<CounterCubit, int>(builder: ...);
```

For persisted state extend `HydratedCubit<T>` and implement `toJson`/`fromJson`. Storage is initialized in `main.dart`.

### Naming conventions

One rule per kind. BLoC-side rules follow the [official Bloc library conventions](https://bloclibrary.dev/naming-conventions/); the rest mirror karmakanda.

#### Domain layer

| Type | Pattern | Examples | Lives in |
|---|---|---|---|
| Entity | `<Subject>Entity` | `AuthUser`, `AstrologerReviewEntity` | `domain/entity/` |
| Abstract repository | `<Subject>Repository` *(or `Remote<Subject>Repository` / `Local<Subject>Repository` — see [Local / Remote prefix rule](#local--remote-prefix-rule) below)* | `AuthRepository`, `UserSessionStore`, `RemoteAstrologerReviewRepository` | `domain/repository/{remote,local}/` |
| Third-party adapter contract | `<Provider>AuthProvider` / `<Provider>Provider` | `ThirdPartyAuthProvider`, `NotificationProvider` | `domain/repository/remote/` |
| Use case | `<Verb><Subject>UseCase` | `LoginWithEmailPasswordUseCase`, `FetchAstrologerReviewsUseCase`, `WatchAuthUserUseCase` | `domain/use_case/{remote,local}/` |
| Use-case params | `<UseCase>Params` | `LoginWithEmailPasswordParams`, `ResetPasswordParams` | next to the use case |

#### Data layer

| Type | Pattern | Examples | Lives in |
|---|---|---|---|
| Model | `<Subject>Model` | `AstrologerReviewModel`, `UserModel` | `data/model/` |
| Mapper | `<Subject>Mapper` | `AstrologerReviewMapper`, `UserMapper` | `data/mapper/` |
| Repository impl (strategy-named) | `<Strategy><Subject>Repository` | `InMemoryAuthRepository`, `RestAstrologerReviewRepositoryImpl`, `HiveSecureSessionStore` | `data/repository/{remote,local}/` |

#### Presentation layer

| Type | Pattern | Examples | Lives in |
|---|---|---|---|
| Bloc | `<Subject>Bloc` | `AuthBloc` | `presentation/bloc/<subject>/` |
| Cubit | `<Subject>Cubit` | `LoadAstrologerReviewsCubit`, `ImagePickerCubit` | `presentation/bloc/<subject>/` |
| Event base class | `<Subject>Event` | `AuthEvent` | next to bloc |
| Event subclass | `<Subject><Noun?><Verb-past-tense>` | `AuthLoginRequested`, `CounterIncrementPressed` | next to bloc |
| Initial-load event | `<Subject>Started` | `AuthStarted` | next to bloc |
| State (single-class) | `<Subject>State` + `<Subject>Status` enum (`initial / loading / success / failure` or context-specific) | `AuthState` + `AuthStatus`, `LoadAstrologerReviewsState` + `AppLoadingState` | next to bloc |
| State (sealed-class) | `<Subject>Initial`, `<Subject>LoadInProgress`, `<Subject>LoadSuccess`, `<Subject>LoadFailure` | `CounterInitial`, `CounterLoadSuccess` | next to bloc |
| Screen (full-page Scaffold) | `<Subject>Screen` | `OnboardingScreen`, `DashboardScreen`, `ThemePlaygroundScreen` | `presentation/views/` |
| View (a screen-shaped widget used inside a screen) | `<Subject>View` | `LoginView`, `SignupCompleteRegistrationView` | `presentation/views/` |
| Reusable widget | `<Subject><Element>` | `LoginButton`, `SignupForm`, `UpdateAppPopupWidget`, `QrImageWidget` | `presentation/widgets/` *(module-scoped)* or `lib/common/widgets/` *(app-wide)* |
| Bootstrapper widget | `<Subject>Bootstrapper` | `AuthBootstrapper`, `AppUpgradeBootstrapper` | `bootstrapper/` |

#### Utils

| Type | Pattern | Examples | Lives in |
|---|---|---|---|
| Service (singleton orchestrating a platform / SDK) | `<Subject>Service` | `FcmService`, `NotificationService`, `RemoteConfigService` | `utils/helper/` |
| Helper (stateless utility class) | `<Subject>Helper` | `PermissionHelper`, `RemoteConfigHelper`, `ImageCompressor` | `utils/helper/` |
| Storage adapter | `<Subject>SecureStorage` / `<Subject>Storage` | `FcmSecureStorage` | `utils/storage_helper/` |
| Storage keys class | `<Subject>StorageKeys` | `AuthStorageKeys`, `FcmStorageKeys` | `utils/storage_helper/` |
| Constants class | `<Subject>Constants` | `AppUpgradeConstants`, `FcmConstants` | `utils/constants/` |
| Enum | `<Subject>Status` / `<Subject>Type` / `<Subject>Kind` | `AuthStatus`, `AppLoadingState`, `NotificationPriority` | `utils/enums/` |
| Extension | `<Type>Extension` or `<Type>X` on the type being extended | `ContextExtension`, `AppUpgradeStatusX` | `utils/extensions/` |

#### Files & folders

- File names are always `snake_case` matching the primary class — `auth_bloc.dart`, `astrologer_review_entity.dart`, `update_app_popup_widget.dart`.
- Bloc / cubit feature folders under `presentation/bloc/` use the `snake_case` subject — `presentation/bloc/auth/`, `presentation/bloc/load_astrologer_reviews/`.
- Barrel file is the folder name, again `snake_case` — `presentation/bloc/auth/auth.dart`, `domain/repository/remote/remote.dart`.

#### Local / Remote prefix rule

When a module has implementations in **both** local and remote directions and the subject alone is ambiguous (could mean either), prefix the abstract repository with `Remote` / `Local`. Otherwise the name stays bare:

| Subject | Has both? | Convention |
|---|---|---|
| Auth | Yes, but names disambiguate already (`AuthRepository` = backend; `UserSessionStore` = local persistence). | **No prefix.** Reader knows what each is by name. |
| Chat | Yes, and "chat" alone is ambiguous. | `RemoteChatRepository` + `LocalChatCacheRepository`. |
| Astrologer reviews | Only remote in this app. | `RemoteAstrologerReviewRepository` *(prefix kept for consistency with karmakanda, even without a local counterpart)*. |
| Resource library (rashifal-style) | Yes — fetch + persist. | `RemoteResourceRepository` + `LocalResourceRepository`. |

Same rule for use cases: if the subject is ambiguous and both directions exist, prefix `Remote<Verb>…UseCase` / `Local<Verb>…UseCase`. Otherwise just `<Verb>…UseCase` is enough.

**Repository impls** don't need the `Remote` / `Local` prefix — name them by strategy:
- `RestAuthRepositoryImpl`, `FirebaseAuthRepository`, `SupabaseAuthRepository`, `InMemoryAuthRepository` — strategy is the differentiator, not the layer.
- `HiveSecureSessionStore`, `DriftCacheRepository` — same: storage technology, not "local".

#### Why these patterns

- **Past tense for events**: events are things that *already happened* from the bloc's perspective — the UI reports "the user pressed login", not commands "log in".
- **Subject prefix on states**: without it (`Initial`, `Loading`, `Failure`) you can't tell two blocs apart in stack traces or DevTools, and they collide in barrels.
- **`Entity` / `Model` suffix**: makes it impossible to confuse `AstrologerReview` (which one?) with `AstrologerReviewEntity` (domain) and `AstrologerReviewModel` (wire).
- **`UseCase` suffix**: lets you grep "what use cases does this bloc consume?" with one keyword.

#### Worked starter example — auth

```dart
// domain/entity/auth_user.dart
class AuthUser extends Equatable { … }

// domain/repository/remote/auth_repository.dart
abstract class AuthRepository { … }                      // no prefix — subject disambiguates

// domain/repository/local/user_session_store.dart
abstract class UserSessionStore { … }                    // no prefix — subject disambiguates

// domain/use_case/remote/login_with_email_password_use_case.dart
class LoginWithEmailPasswordUseCase
    extends UseCase<void, LoginWithEmailPasswordParams> { … }
class LoginWithEmailPasswordParams extends Equatable { … }

// data/repository/remote/in_memory_auth_repository.dart
class InMemoryAuthRepository implements AuthRepository { … }   // strategy-named

// data/repository/local/hive_secure_session_store.dart
class HiveSecureSessionStore implements UserSessionStore { … } // strategy-named

// presentation/bloc/auth/auth_bloc.dart, auth_event.dart (parts)
enum AuthStatus { initial, busy, authenticated, unauthenticated }
class AuthState extends Equatable { … }
class _AuthLoginRequested extends AuthEvent { … }        // past tense, subject-prefixed

// bootstrapper/auth_bootstrapper.dart
class AuthBootstrapper extends StatelessWidget { … }
```

❌ Avoid:
- `AuthLogin` — is this an event or a state?
- `Login`, `Logout` — no subject; collides across modules.
- `IncrementCounter` — imperative, not past tense.
- `CounterCubitState` — redundant "Cubit" inside the state name.
- `RemoteAuthRepository` — `Auth` already means "remote auth backend"; the prefix adds noise.
- `LocalUserSessionStore` — same: `UserSessionStore` is unambiguously local persistence.
- `RemoteFetchAstrologerReviewsUsecase` *(lowercase c)* — typo'd in karmakanda; use `UseCase`.

---

## Dependency injection

`get_it` + `injectable` (codegen).

```dart
@Injectable(as: MyRepository)
class MyRepositoryImpl implements MyRepository { … }

@singleton                       // single instance, eagerly created
class MyService { … }

@injectable                      // new instance per resolve
class MyHandler { … }
```

Run `dart run build_runner build` after annotating to regenerate [`lib/core/di/injection.config.dart`](lib/core/di/injection.config.dart). `configureDependencyInjection()` is already called from `main.dart`.

```dart
final repo = getIt<MyRepository>();
```

Resolve dependencies in cubit constructors, not in widgets. Cross-cutting platform singletons (FlutterSecureStorage, Connectivity, etc.) live in [`lib/core/di/service_module.dart`](lib/core/di/service_module.dart).

---

## Routing

`go_router` with a typed `Routes` enum.

Add to [`lib/core/router/routes.dart`](lib/core/router/routes.dart) and register in [`lib/core/router/app_router.dart`](lib/core/router/app_router.dart). Navigate with `context.goNamed(Routes.x.name)` / `context.pushNamed(...)`.

---

## Responsive sizing

`flutter_scale_kit` extension methods on `num`:

```dart
EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
BorderRadius.circular(12.r)
fontSize: 16.spClamp(12, 20)
```

`ScaleKitBuilder` is wired in `main.dart` with a 425×691 design size — edit there if your designs target a different reference.

---

## Storage

Three tools, one job each:

- **HydratedBloc** for cubit/bloc state. Automatic.
- **Hive** for structured app data. Register box openers in [`lib/app/hive_bootstrap.dart`](lib/app/hive_bootstrap.dart).
- **flutter_secure_storage** for tokens / secrets. Reach via `SecureStorageHelper.instance`.

`shared_preferences` is included for libraries that need it (e.g. `dynamic_color`); app code should reach for one of the above.

---

## Toasts

```dart
CustomSnackbar.success(context, 'Saved');
CustomSnackbar.error(context, 'Could not save');
CustomSnackbar.info(context, 'Heads up');
```

Prefer this over `ScaffoldMessenger.showSnackBar`.

---

## Network / API layer

Path: [`lib/core/network/`](lib/core/network/). Dio-backed.

### Setup

Set `API_BASE_URL` in `.env`. `RemoteService` is registered via `@Injectable` — `dart run build_runner build` puts it in DI.

### Use

```dart
@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);
  final RemoteService _remote;

  @override
  Future<Profile> fetch() async {
    final data = await _remote.get(
      endpoint: 'me',
      authRequired: true,
      accessToken: () => SecureStorageHelper.instance.read('access_token'),
    );
    if (data is! Map<String, dynamic>) {
      throw const ServerException(message: AppErrorStrings.invalidResponseShape);
    }
    return Profile.fromJson(data);
  }
}
```

Wire token refresh by setting `refreshTokenCallback` on `RemoteServiceImpl`:

```dart
(getIt<RemoteService>() as RemoteServiceImpl).refreshTokenCallback = () async {
  // call refresh endpoint, persist new tokens, return new access token
};
```

### Error model

- **Wire failures** (network down, 401, 500) → `ServerException(message: ApiErrorStrings.x)` from `RemoteService`.
- **Shape failures** (2xx but malformed) → throw `ServerException(message: AppErrorStrings.invalidResponseShape)` in your repo.
- **Feature-specific failures** → declare `<feature>_error_strings.dart` in `<feature>/utils/constants/` and throw with its constants.

### Remove

- Delete [`lib/core/network/`](lib/core/network/).
- Remove `dio` from `pubspec.yaml`.
- Remove `API_BASE_URL` from `.env`.
- `dart run build_runner build`.

`AppErrorStrings` stays in `core/errors/` — domain failures happen regardless of HTTP.

---

## Auth

Path: [`lib/modules/auth/`](lib/modules/auth/). **No UI shipped** — bring your own login/signup screens. The starter provides the wiring: state machine, session persistence, route-aware redirect callback.

### Architecture

```
auth/
├── domain/
│   ├── entity/auth_user.dart                                minimal user (id, email, displayName, photoUrl, extras{})
│   ├── repository/
│   │   ├── remote/
│   │   │   ├── auth_repository.dart                         THE swap point — REST / Firebase / Supabase / your own
│   │   │   └── third_party_auth_provider.dart               optional OAuth provider contract
│   │   └── local/
│   │       └── user_session_store.dart                      token + user persistence contract
│   └── use_case/remote/                                     login, register, logout, watch-user, … (@injectable)
├── data/
│   └── repository/
│       ├── remote/
│       │   └── in_memory_auth_repository.dart               @LazySingleton(as: AuthRepository) stub — swap before shipping
│       └── local/
│           └── hive_secure_session_store.dart               @LazySingleton(as: UserSessionStore) — Hive + secure storage
├── presentation/bloc/auth/                                  AuthBloc, AuthState (initial / busy / authenticated / unauthenticated)
├── bootstrapper/auth_bootstrapper.dart                      wraps app shell; fires onAuthenticated / onUnauthenticated callbacks
└── utils/storage_helper/auth_storage_keys.dart
```

### `AuthRepository` contract

Every method an implementation must provide ([auth_repository.dart](lib/modules/auth/domain/repository/remote/auth_repository.dart)):

| Method | What the impl should do | May no-op? |
|---|---|---|
| `loginWithEmailAndPassword({email, password})` | Authenticate against your backend, then call `UserSessionStore.saveSession(user, access, refresh)` so `watchUser` emits. | No |
| `registerEmail({email})` | Send a verification code to the user's inbox (two-step sign-up). | Yes — when sign-up isn't code-gated |
| `registerUser({email, password, fullName, code, phoneNumber})` | Finalise registration; usually saves a session on success. Pass `code: ''` if email verification isn't required. | No |
| `forgetPassword({email})` | Trigger a password-reset email / link. | No |
| `resetPassword({oldPassword, newPassword})` | Change the password for the currently authenticated user. | No |
| `loginWithGoogle()` | Run the Google OAuth flow via [`ThirdPartyAuthProvider`](lib/modules/auth/domain/repository/remote/third_party_auth_provider.dart), then save the session. | Throw "not configured" until you wire a provider |
| `loginWithApple()` | Same, for Sign in with Apple. | Throw "not configured" until you wire a provider |
| `getLoggedInUser()` | Return the persisted user snapshot (no network call). Backed by `UserSessionStore.getUser()`. | No |
| `watchUser()` | Live stream of the persisted user. Must emit current value on subscribe + `null` after logout. Backed by `UserSessionStore.watchUser()`. | No |
| `logout({wasStillAuthenticated})` | Clear the local session (always). Hit your `/auth/logout` server endpoint **only** when `wasStillAuthenticated == true`. | No |

Throw [`AuthenticationException`](lib/core/errors/exceptions.dart) (or another `AppException` subclass) on failure — [`AppErrorHandler`](lib/core/errors/error_handler.dart) picks up `.message` automatically.

### Setup

Wiring is already in place. The bloc resolves use cases via `getIt`:

```dart
// lib/app/global_bloc_config.dart
BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
```

Add redirect callbacks in [`lib/app/app.dart`](lib/app/app.dart):

```dart
AuthBootstrapper(
  onAuthenticated:   (_, user) => router.goNamed('dashboard'),
  onUnauthenticated: (_)       => router.goNamed('login'),
  child: child!,
)
```

### Use

```dart
// Sign in
context.read<AuthBloc>().login(email: '...', password: '...');

// Watch state
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) => switch (state.status) {
    AuthStatus.busy            => const CircularProgressIndicator(),
    AuthStatus.authenticated   => HomeScreen(user: state.user!),
    AuthStatus.unauthenticated => LoginScreen(error: state.error),
    AuthStatus.initial         => const SizedBox(),
  },
);

// Sign out
context.read<AuthBloc>().logout();
```

Full bloc surface: `login`, `registerEmail`, `registerUser`, `loginWithGoogle`, `loginWithApple`, `forgetPassword`, `resetPassword`, `logout`. Each fans out to a `@injectable` use case in [`lib/modules/auth/domain/use_case/`](lib/modules/auth/domain/use_case/) — add new actions by adding a new use case alongside.

### Switching the auth backend

The bloc and use cases resolve `AuthRepository` via DI — they don't know which backend you're using. Swap by replacing the registered implementation:

1. Add the SDK deps you need to [`pubspec.yaml`](pubspec.yaml) (e.g. `firebase_auth`, `supabase_flutter`). `dio` is already included for REST-style backends.
2. Create `lib/modules/auth/data/repository/remote/<your>_auth_repository.dart` implementing [`AuthRepository`](lib/modules/auth/domain/repository/remote/auth_repository.dart), annotated `@LazySingleton(as: AuthRepository)`. Inject `UserSessionStore` (and `ThirdPartyAuthProvider` if you ship OAuth) via its constructor — they're already in DI.
3. Delete [`in_memory_auth_repository.dart`](lib/modules/auth/data/repository/remote/in_memory_auth_repository.dart) so only one binding remains for `AuthRepository`.
4. `dart run build_runner build` to regenerate [`injection.config.dart`](lib/core/di/injection.config.dart).
5. **Dev-only**: clear stale fake tokens from the previous stub once — either `Hive.box(AppConstants.appBoxName).clear()` from a debug button, or uninstall + reinstall the app. `InMemoryAuthRepository` writes `fake-access-…` tokens that won't pass server-side checks.
6. Smoke-test: launch → login → cold restart should still be authenticated. Then logout → confirm `onUnauthenticated` fires in [`AuthBootstrapper`](lib/modules/auth/bootstrapper/auth_bootstrapper.dart).

The bloc, use cases, bootstrapper, and `AuthUser` don't change — only the implementation behind the `AuthRepository` interface.

### Backend integration patterns

Skeletons for the four most common backends. Each shows the same triad — `loginWithEmailAndPassword`, `watchUser`, `logout` — enough to extrapolate the rest of the contract.

#### REST API + Dio

Uses [`RemoteService`](lib/core/network/service/remote_service.dart) (already in DI) and the starter's [`AuthInterceptor`](lib/core/network/dio/interceptors/auth_interceptor.dart) for per-request token attachment.

```dart
@LazySingleton(as: AuthRepository)
class RestAuthRepository implements AuthRepository {
  RestAuthRepository(this._remote, this._store);

  final RemoteService _remote;
  final UserSessionStore _store;

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final data = await _remote.post(
      endpoint: 'auth/login',
      body: {'email': email, 'password': password},
    );
    if (data is! Map<String, dynamic>) {
      throw const ServerException(message: AppErrorStrings.invalidResponseShape);
    }
    final tokens = data['tokens'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);
    await _store.saveSession(
      user: user,
      accessToken: tokens['access'] as String,
      refreshToken: tokens['refresh'] as String,
    );
  }

  @override
  Stream<AuthUser?> watchUser() => _store.watchUser();

  @override
  Future<void> logout({bool wasStillAuthenticated = true}) async {
    if (wasStillAuthenticated) {
      try {
        await _remote.post(
          endpoint: 'auth/logout',
          body: {'refresh': await _store.getRefreshToken()},
          authRequired: true,
          accessToken: _store.getAccessToken,
        );
      } catch (_) {/* clear local state anyway */}
    }
    getIt<LogoutInterceptor>().markAsLoggedOut();
    await _store.clearSession();
  }
  // … registerEmail, registerUser, forgetPassword, resetPassword,
  //   loginWithGoogle, loginWithApple, getLoggedInUser
}
```

Then follow the [Switching checklist](#switching-the-auth-backend).

#### Firebase Auth

Add `firebase_auth` to [`pubspec.yaml`](pubspec.yaml). Firebase already comes up via [`FirebaseService.init`](lib/core/services/firebase_service.dart) when `FIREBASE_ENABLED=true`.

```dart
@LazySingleton(as: AuthRepository)
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._store);

  final UserSessionStore _store;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _toAuthUser(cred.user!);
      await _store.saveSession(
        user: user,
        accessToken: (await cred.user!.getIdToken()) ?? '',
        refreshToken: cred.user!.refreshToken ?? '',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(message: e.message ?? e.code);
    }
  }

  /// Bridge Firebase's userChanges stream into our [AuthUser] shape. Note we
  /// also fan into the local store so cold start matches the live session.
  @override
  Stream<AuthUser?> watchUser() =>
      _auth.userChanges().asyncMap((u) async => u == null ? null : _toAuthUser(u));

  @override
  Future<void> logout({bool wasStillAuthenticated = true}) async {
    await _auth.signOut();
    getIt<LogoutInterceptor>().markAsLoggedOut();
    await _store.clearSession();
  }

  Future<AuthUser> _toAuthUser(User u) async => AuthUser(
    id: u.uid,
    email: u.email,
    displayName: u.displayName,
    photoUrl: u.photoURL,
    phoneNumber: u.phoneNumber,
    isEmailVerified: u.emailVerified,
    extras: {'idToken': await u.getIdToken()},
  );
  // … register*, forgetPassword (use _auth.sendPasswordResetEmail),
  //   resetPassword (_auth.currentUser!.updatePassword), loginWithGoogle/Apple
}
```

`registerEmail` is a no-op for Firebase (no separate verification-code step). `forgetPassword` becomes `_auth.sendPasswordResetEmail(email: email)`.

#### Supabase

Add `supabase_flutter` to [`pubspec.yaml`](pubspec.yaml). Initialise Supabase in `main.dart` before `runApp` (`await Supabase.initialize(url: ..., anonKey: ...)`).

```dart
@LazySingleton(as: AuthRepository)
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._store);

  final UserSessionStore _store;
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = res.session;
      final user = res.user;
      if (session == null || user == null) {
        throw const AuthenticationException(message: 'No session returned');
      }
      await _store.saveSession(
        user: _toAuthUser(user),
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    }
  }

  @override
  Stream<AuthUser?> watchUser() => _client.auth.onAuthStateChange.map(
    (event) => event.session?.user == null ? null : _toAuthUser(event.session!.user),
  );

  @override
  Future<void> logout({bool wasStillAuthenticated = true}) async {
    await _client.auth.signOut();
    getIt<LogoutInterceptor>().markAsLoggedOut();
    await _store.clearSession();
  }

  AuthUser _toAuthUser(User u) => AuthUser(
    id: u.id,
    email: u.email,
    displayName: u.userMetadata?['full_name'] as String?,
    extras: u.userMetadata ?? const {},
  );
  // … register*, forgetPassword (_client.auth.resetPasswordForEmail),
  //   loginWithGoogle/Apple (_client.auth.signInWithOAuth)
}
```

#### Custom JWT / generic OAuth2

No SDK lock-in. Reuses [`RemoteService`](lib/core/network/service/remote_service.dart) and the starter's `AuthInterceptor` / `RemoteServiceImpl.refreshTokenCallback`. Suitable when you own both client and server or are using a vanilla OAuth2 provider (Keycloak, Auth0 without their Flutter SDK, etc.).

```dart
@LazySingleton(as: AuthRepository)
class JwtAuthRepository implements AuthRepository {
  JwtAuthRepository(this._remote, this._store);

  final RemoteService _remote;
  final UserSessionStore _store;

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final data = await _remote.post(
      endpoint: 'oauth/token',
      body: {
        'grant_type': 'password',
        'username': email,
        'password': password,
      },
    );
    final access = (data as Map)['access_token'] as String;
    final refresh = data['refresh_token'] as String? ?? '';
    await _store.saveTokens(accessToken: access, refreshToken: refresh);
    final me = await _remote.get(
      endpoint: 'userinfo',
      authRequired: true,
      accessToken: _store.getAccessToken,
    );
    await _store.saveUser(AuthUser.fromJson(me as Map<String, dynamic>));
  }

  @override
  Stream<AuthUser?> watchUser() => _store.watchUser();

  @override
  Future<void> logout({bool wasStillAuthenticated = true}) async {
    if (wasStillAuthenticated) {
      try {
        await _remote.post(
          endpoint: 'oauth/revoke',
          body: {'token': await _store.getRefreshToken()},
        );
      } catch (_) {}
    }
    getIt<LogoutInterceptor>().markAsLoggedOut();
    await _store.clearSession();
  }
  // … register*, forgetPassword, resetPassword, loginWithGoogle/Apple
}
```

Wire token refresh once at app start (after `configureDependencyInjection()`):

```dart
(getIt<RemoteService>() as RemoteServiceImpl).refreshTokenCallback = () async {
  final refresh = await getIt<UserSessionStore>().getRefreshToken();
  if (refresh == null || refresh.isEmpty) return null;
  final data = await getIt<RemoteService>().post(
    endpoint: 'oauth/token',
    body: {'grant_type': 'refresh_token', 'refresh_token': refresh},
  );
  final access = (data as Map)['access_token'] as String;
  await getIt<UserSessionStore>().saveAccessToken(access);
  return access;
};
```

After picking any backend, follow the [Switching checklist](#switching-the-auth-backend).

### Third-party providers

The starter ships **no** OAuth deps (no `google_sign_in`, no `sign_in_with_apple`) — they're heavy and not every app needs them. When you do, implement `ThirdPartyAuthProvider`, register it `@LazySingleton(as: ThirdPartyAuthProvider)`, and inject it into your real `AuthRepository`:

```dart
@LazySingleton(as: ThirdPartyAuthProvider)
class GoogleAppleProvider implements ThirdPartyAuthProvider { … }

@LazySingleton(as: AuthRepository)
class RestAuthRepository implements AuthRepository {
  RestAuthRepository(this._remote, this._store, this._oauth);
  final ThirdPartyAuthProvider _oauth;
  …
}
```

### Hook the network layer into auth

[`AuthInterceptor`](lib/core/network/dio/interceptors/auth_interceptor.dart) and [`LogoutInterceptor`](lib/core/network/dio/interceptors/logout_interceptor.dart) are already wired into the Dio stack via DI — you don't add interceptors, you only feed their callbacks.

**Attach `Bearer <token>` per request** — pass `accessToken` whenever `authRequired: true`:

```dart
final me = await _remote.get(
  endpoint: 'me',
  authRequired: true,
  accessToken: getIt<UserSessionStore>().getAccessToken,  // <- the live callback
);
```

The interceptor reads through the callback once per request, so token rotations (after a refresh) take effect immediately without restarting Dio.

**Short-circuit in-flight requests on logout**:

```dart
@override
Future<void> logout({bool wasStillAuthenticated = true}) async {
  // ... server hop if needed ...
  getIt<LogoutInterceptor>().markAsLoggedOut();   // every queued / new request fails fast
  await _store.clearSession();
}
```

Call `getIt<LogoutInterceptor>().clearLoggedOut()` from your next successful `loginWithEmailAndPassword` so subsequent requests aren't blocked.

**401-driven refresh** — set the callback once after `configureDependencyInjection()`:

```dart
(getIt<RemoteService>() as RemoteServiceImpl).refreshTokenCallback = () async {
  // call your refresh endpoint, persist via UserSessionStore.saveAccessToken, return the new token
};
```

See the [Network / API layer](#network--api-layer) section for the wider error / retry model.

### Remove

- Delete [`lib/modules/auth/`](lib/modules/auth/).
- Remove the `AuthBloc` provider from [`global_bloc_config.dart`](lib/app/global_bloc_config.dart).
- Remove the `AuthBootstrapper` wrap in [`app.dart`](lib/app/app.dart).

No pubspec changes — auth only uses deps the starter already needs.

---

## Notifications

Path: [`lib/modules/notifications/`](lib/modules/notifications/). Local notifications, FCM-independent.

### Pluggable provider

`NotificationService` (singleton) delegates to a `NotificationProvider`. Default: `FlutterLocalNotificationsProvider`. To swap packages (e.g. `awesome_notifications`), implement the interface and pass it at init.

### Setup

Already wired — `await NotificationService.instance.initialize()` in `main.dart`.

Native config (not auto-applied):
- **Android**: `POST_NOTIFICATIONS` permission, `RECEIVE_BOOT_COMPLETED` for scheduled, `flutter_local_notifications` receiver entries. Add a monochrome `@drawable/ic_notification`.
- **iOS**: usage description in `Info.plist` if you use action categories; `UNUserNotificationCenter` delegate in `AppDelegate.swift`.

### Use

```dart
final granted = await NotificationService.instance.requestPermissions();

await NotificationService.instance.show(
  NotificationPayload(
    id: 42,
    title: 'Reminder',
    body: 'You have a meeting at 3pm',
    channel: NotificationChannels.highPriorityChannelId,
    priority: NotificationPriority.high,
    actions: [
      NotificationAction(id: 'view',   label: 'View'),
      NotificationAction(id: 'snooze', label: 'Snooze'),
    ],
  ),
);

await NotificationService.instance.schedule(
  NotificationPayload(id: 43, title: 'Wake up', body: ''),
  DateTime.now().add(const Duration(hours: 8)),
);

NotificationService.instance.onTap.listen((event) {
  // navigate based on event.payload.data and event.actionId
});
```

### Remove

- Delete [`lib/modules/notifications/`](lib/modules/notifications/).
- Remove the `NotificationService.instance.initialize()` line from `main.dart`.
- Remove `flutter_local_notifications` and `timezone` from `pubspec.yaml`.
- If FCM is still installed, also delete [`lib/modules/fcm/integrations/notifications_bridge.dart`](lib/modules/fcm/integrations/notifications_bridge.dart) and switch back to `fcmBackgroundHandler`.

---

## FCM (push)

Path: [`lib/modules/fcm/`](lib/modules/fcm/). Depends on Firebase. Independent of Notifications (an optional bridge lives in `integrations/`).

### Setup

1. Configure Firebase (see [Firebase](#firebase) below).
2. `FIREBASE_ENABLED=true` in `.env`.
3. The two main.dart lines are already in place:
   ```dart
   FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
   await FcmService.instance.initialize(
     onForegroundMessage: buildNotificationBridge(),
   );
   ```
4. Native config:
   - **iOS**: APNs key/cert in Firebase console, Push Notifications capability, Background Modes → Remote notifications.
   - **Android**: `google-services.json` (pulled by `flutterfire configure`).

When `FIREBASE_ENABLED=false`, both lines no-op.

### Default topics

[`FcmConstants.defaultTopics`](lib/modules/fcm/utils/constants/fcm_constants.dart) holds the list subscribed to on every launch (default: `['app_update', 'promotions']`). Edit the constant — or pass `defaultTopics: …` to `initialize()` (empty list opts out entirely).

### Background / killed behaviour

Two wiring options for the background handler:

| Handler | Backend sends `notification` payload | Backend sends data-only payload |
|---|---|---|
| `fcmBackgroundHandler` (default) | OS displays automatically | Nothing displays in background/killed |
| `fcmBackgroundDisplayHandler` | OS displays automatically (handler skips to avoid duplicates) | Handler renders a local notification with action buttons from `data.actions` |

Wire the display handler if your backend ships **data-only** messages (the only reliable way to get action buttons cross-platform):

```dart
FirebaseMessaging.onBackgroundMessage(fcmBackgroundDisplayHandler);
```

### Backend payload contract (for action buttons)

FCM data values are strings, so `actions` ships as a JSON-encoded array:

```json
{
  "message": {
    "token": "<fcm token>",
    "data": {
      "title": "New message",
      "body": "Alex: are you online?",
      "channel": "high_priority",
      "actions": "[{\"id\":\"reply\",\"label\":\"Reply\"},{\"id\":\"mute\",\"label\":\"Mute\",\"destructive\":true}]",
      "chat_id": "1234"
    },
    "android": { "priority": "high" }
  }
}
```

- `android.priority: "high"` wakes a killed Android device and triggers the handler. Without it, data-only messages get throttled in Doze.
- iOS action buttons require `DarwinNotificationCategory` instances registered up-front (the `channel` doubles as `categoryIdentifier`). Android action buttons are dynamic — they work out of the box.
- iOS background delivery for data-only messages is unreliable by design. For reliable iOS background, send a `notification` payload + `content_available: true`.

### Use

```dart
final token = await FcmService.instance.getToken();

await FcmService.instance.subscribeToTopic('news');

if (await FcmService.instance.shouldSyncToken(token: token!, userId: '42')) {
  await yourBackend.upsertFcmToken(token, userId: '42');
  await FcmService.instance.markTokenSynced(token: token, userId: '42');
}

FcmService.instance.onMessageOpenedApp.listen((msg) {
  // navigate based on msg.data
});
```

### Remove

- Delete [`lib/modules/fcm/`](lib/modules/fcm/).
- Remove both FCM lines from `main.dart`.
- Remove `firebase_messaging` from `pubspec.yaml`.
- `dart run build_runner build`.

To remove the bridge but keep FCM: delete [`integrations/notifications_bridge.dart`](lib/modules/fcm/integrations/notifications_bridge.dart) and pass `onForegroundMessage: null`.

---

## App upgrade alert

Path: [`lib/modules/app_upgrade/`](lib/modules/app_upgrade/). Firebase Remote Config-driven update popup. **No-ops when Firebase is disabled** — safe to leave wired during early development.

### What it does

On each launch (after the splash), checks `latest_released_app_version` from Remote Config. If lower than the installed version and the per-platform kill switch is on, shows a themed dialog rendering HTML from the `update_message` key. Force-update mode blocks the back button; otherwise the user can Remind later or Ignore (the ignored version is remembered in Hive).

### Setup

1. Enable Firebase (see [Firebase](#firebase) below).
2. Push the parameters from [`firebase_remote_config_template.json`](lib/modules/app_upgrade/firebase_remote_config_template.json) to your Firebase Console (Remote Config → Import).
3. Wiring is already in place — `AppUpgradeBootstrapper` wraps the app shell in [`app.dart`](lib/app/app.dart) and `AppUpgradeCubit` is provided in [`global_bloc_config.dart`](lib/app/global_bloc_config.dart).

### Remote Config keys

| Key | Type | Effect |
|---|---|---|
| `latest_released_app_version` | string (semver) | Triggers the dialog when installed version is lower |
| `update_message` | string (HTML) | Body of the dialog. Supports `<p>`, `<b>`, `<i>`, `<ul>`, `<li>`, `<h3>`, `<br>` |
| `enabled_on_ios` | bool | Per-platform kill switch |
| `enabled_on_android` | bool | Per-platform kill switch |
| `force_update` | bool | Blocks back / barrier / "Remind later" |

### Use

The dialog auto-surfaces. To trigger a manual recheck (e.g. from a debug menu):

```dart
context.read<AppUpgradeCubit>().checkForUpdate();
```

### Remove

- Delete [`lib/modules/app_upgrade/`](lib/modules/app_upgrade/).
- Remove the `AppUpgradeCubit` provider from [`global_bloc_config.dart`](lib/app/global_bloc_config.dart).
- Remove the `AppUpgradeBootstrapper` wrap in [`app.dart`](lib/app/app.dart).
- Remove `firebase_remote_config` and `flutter_widget_from_html` from `pubspec.yaml`.

---

## Image picker

Path: [`lib/modules/image_picker/`](lib/modules/image_picker/). Single / multi-pick + camera + gallery + JPG compression + HEIC handling.

### Setup

Native config:
- **iOS**: `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` in `Info.plist`.
- **Android**: nothing for image picker on Android 13+. Camera capture needs `CAMERA` permission in `AndroidManifest.xml`.

### Use — quick (one-off)

```dart
await ImagePickerSheet.show(
  context,
  shouldPickMultipleImages: false,
);
```

Spins up a transient cubit for the sheet. Use this when you want one image and don't need to track state elsewhere.

### Use — with cubit (typical)

```dart
BlocProvider(
  create: (_) => ImagePickerCubit()..setSingleImagePicker(single: false),
  child: BlocBuilder<ImagePickerCubit, ImagePickerState>(
    builder: (context, state) {
      return Column(
        children: [
          for (final file in state.files) Image.file(file),
          OutlinedButton(
            onPressed: () => ImagePickerSheet.show(
              context,
              cubit: context.read<ImagePickerCubit>(),
              shouldPickMultipleImages: true,
            ),
            child: const Text('Pick images'),
          ),
        ],
      );
    },
  ),
)
```

Compression is automatic (JPG re-encode for non-JPGs, dart:ui decode for HEIC on Android). Failures fall back to the original file.

### Remove

- Delete [`lib/modules/image_picker/`](lib/modules/image_picker/).
- Remove `image_picker`, `flutter_image_compress`, `image`, `path` from `pubspec.yaml`.

---

## Firebase

Opt-in. Without enabling, the app builds and runs without any Firebase code executing.

### Setup

1. `dart pub global activate flutterfire_cli`.
2. `flutterfire configure` — generates `lib/firebase_options.dart` (gitignored).
3. Uncomment the import + `options:` line in [`lib/core/services/firebase_service.dart`](lib/core/services/firebase_service.dart).
4. `FIREBASE_ENABLED=true` in `.env`.

### Use

Already wired in `main.dart` — Crashlytics + Analytics come up in release builds only.

```dart
FirebaseAnalytics.instance.logEvent(name: 'add_to_cart', parameters: {...});
FirebaseCrashlytics.instance.recordError(e, st, fatal: false);
```

### Remove

- Delete [`lib/core/services/firebase_service.dart`](lib/core/services/firebase_service.dart) (and `lib/modules/fcm/` + `lib/modules/app_upgrade/` if used).
- Remove the two `FirebaseService.…` calls from `main.dart`.
- Remove `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_messaging`, `firebase_remote_config` from `pubspec.yaml`.
- Remove `FIREBASE_ENABLED` from `.env`.
- Delete `lib/firebase_options.dart` if generated.

---

## Onboarding replay

`AppSettingCubit` holds `showOnboardingAtAppOpen` (default `true`). When true on next launch, the splash routes to onboarding.

End users replay onboarding from Settings → "Show app tour again":

```dart
context.read<AppSettingCubit>().requestOnboardingReplay();
context.goNamed(Routes.onboarding.name);
```

Customize the carousel pages in [`lib/modules/onboarding/presentation/views/onboarding_screen.dart`](lib/modules/onboarding/presentation/views/onboarding_screen.dart).

---

## Removability cheat sheet

| Feature | Delete | Remove from main.dart / app.dart / global_bloc_config | Remove from pubspec | Remove from .env |
|---|---|---|---|---|
| Notifications | `lib/modules/notifications/` | `NotificationService.instance.initialize()` line | `flutter_local_notifications`, `timezone` | — |
| FCM | `lib/modules/fcm/` | both FCM lines | `firebase_messaging` | — |
| App upgrade | `lib/modules/app_upgrade/` | `AppUpgradeCubit` provider, `AppUpgradeBootstrapper` wrap | `firebase_remote_config`, `flutter_widget_from_html` | — |
| Auth | `lib/modules/auth/` | `AuthBloc` provider, `AuthBootstrapper` wrap | — | — |
| Image picker | `lib/modules/image_picker/` | — | `image_picker`, `flutter_image_compress`, `image`, `path` | — |
| Network/API | `lib/core/network/` | — | `dio` | `API_BASE_URL` |
| Firebase (all) | `lib/core/services/firebase_service.dart` + every Firebase module | all Firebase + FCM + upgrade lines | every `firebase_*` | `FIREBASE_ENABLED` |
| Theme playground | playground screen + tile + route | — | `flutter_colorpicker` (also drop `image_picker` if no other consumer) | — |
| Device dynamic color | unwrap `DynamicColorBuilder` in `app.dart` | — | `dynamic_color` | — |

Run `dart run build_runner build` after any module deletion to drop generated registrations.

---

## Q&A

Short answers to the questions that come up while wiring this starter into a new app.

### Architecture & layout

#### 1. When should I create a new module vs. add to an existing one?

New module when the feature has its own data + domain + UI surface and could be removed independently (e.g. a "payments" or "notifications-center" feature). Add to an existing one when it's a sub-feature of something already there (a new screen inside `dashboard/`, a new event inside `AuthBloc`). If you find yourself importing more than the top-level barrel from a neighbouring module, the boundary is wrong.

#### 2. Do all modules need data/domain/presentation?

No. The full split applies when a module talks to a backend or persistence. Utility modules (image_picker, app_upgrade, theme playground, fcm) skip whichever layers don't apply. See [Module folder convention](#module-folder-convention).

#### 3. When do I add a `local/` and `remote/` subfolder?

Whenever the module has repository implementations in both directions, or when you only have one direction but want consistency with karmakanda-style projects (review, chat, livekit all use `remote/` even without a `local/` counterpart). Single-direction utility modules (just helpers, no repositories) stay flat.

#### 4. Where do I put a constant / helper / extension that lots of modules use?

Constants → [`lib/core/utils/constants/`](lib/core/utils/constants/). Helpers → [`lib/core/utils/helpers/`](lib/core/utils/helpers/). Extensions on `BuildContext` etc. → [`lib/core/utils/extensions/`](lib/core/utils/extensions/). Reusable widgets → [`lib/common/widgets/`](lib/common/widgets/).

#### 5. The `core/` layer can't import from `modules/`. How do I avoid that when a core helper needs a module-shaped thing?

Put the *contract* in `core/` (e.g. an `AsyncValueGetter<String?>` callback parameter, like `AuthInterceptor` does for tokens) and let the module hand the implementation through that contract at the call site. The core stays generic.

### State management

#### 6. Cubit or Bloc?

Default to Cubit. Reach for Bloc when state transitions naturally arise from typed events (auth, multi-step flows with replay, anything with concurrency requirements that benefit from `transformer:`). Both follow the [Naming conventions](#naming-conventions) above.

#### 7. Where do I put a bloc — globally or near the screen?

App-lifecycle blocs (theme, auth, app settings) → [`lib/app/global_bloc_config.dart`](lib/app/global_bloc_config.dart). Screen-scoped blocs → `BlocProvider` next to the screen, usually inside `presentation/views/`. Don't mix.

#### 8. How does the bloc get its use cases?

As `final X _x = getIt<X>();` fields. Same pattern in every cubit/bloc in the starter — see [`auth_bloc.dart`](lib/modules/auth/presentation/bloc/auth/auth_bloc.dart) and the [astrologer_review example](#adding-a-new-module). Don't take use cases via constructor (it makes `BlocProvider(create: (_) => MyBloc())` clutter for screens) and don't reach `getIt` from inside widgets.

#### 9. How do I surface errors to the UI?

Catch the error and emit via `AppErrorHandler.getErrorMessage(error)` — see [Error handling at the bloc level](#error-handling-at-the-bloc-level).

### Auth

#### 10. How do I switch from the in-memory stub to a real backend?

See the [Switching the auth backend](#switching-the-auth-backend) checklist. Six steps: add deps, write your `@LazySingleton(as: AuthRepository)`, delete the stub, rebuild, clear stale tokens once, smoke-test.

#### 11. Do I have to use Hive + secure storage for the session?

No — that's the [`HiveSecureSessionStore`](lib/modules/auth/data/repository/local/hive_secure_session_store.dart) default. Replace it with your own `@LazySingleton(as: UserSessionStore)` (Drift, GetStorage, SharedPreferences, whatever) and the auth repository will pick it up via DI.

#### 12. How does logout cascade to in-flight requests?

Call `getIt<LogoutInterceptor>().markAsLoggedOut()` in your `AuthRepository.logout()`. Every request that's already in flight (or queued behind another) fails fast with a Dio cancel exception. Reset on next successful login with `clearLoggedOut()`.

#### 13. Where's the token refresh hook?

`RemoteServiceImpl.refreshTokenCallback` — wire it once after `configureDependencyInjection()`. See the [JWT pattern](#custom-jwt--generic-oauth2) for a complete example.

### Theme

#### 14. How do I change the brand color?

Edit [`AppColors.seed` and `AppColors.accent`](lib/core/theme/colors/app_colors.dart). The whole Material scheme regenerates from those.

#### 15. How do I ship my own preset themes (Christmas / Black-Friday-Sale / …)?

Call `ThemePresets.register([…])` in `main()` before MaterialApp builds — see the [Theme section](#preset-themes-christmas--ocean--sunset-).

#### 16. How do I customize a single Material widget (AppBar, FilledButton, …)?

Add or edit the corresponding builder in [`lib/core/theme/component_themes/`](lib/core/theme/component_themes/). `AppThemeBuilder.compose` already invokes them — no other wiring.

### Storage

#### 17. Hive vs HydratedBloc vs flutter_secure_storage vs SharedPreferences — which do I use?

HydratedBloc for cubit/bloc state (automatic, no API). Hive for structured app data (user profile, cached entities, …). flutter_secure_storage for tokens / secrets. SharedPreferences only for libraries that demand it (e.g. `dynamic_color`). See [Storage](#storage).

#### 18. How do I add a new Hive box?

Add an opener to `_boxOpeners` in [`hive_bootstrap.dart`](lib/app/hive_bootstrap.dart) and a clearer to `_boxClearers`. Box-name constants live in your module's `utils/storage_helper/`.

### Firebase / push

#### 19. Does Firebase ship turned on?

No. `FIREBASE_ENABLED=false` by default in `.env`. The starter compiles and runs without `firebase_options.dart`. See [Firebase](#firebase).

#### 20. Will FCM messages arrive when the app is killed?

`notification`-payload messages always (OS handles them). Data-only payloads need [`fcmBackgroundDisplayHandler`](lib/modules/fcm/utils/helper/fcm_background_handler.dart) wired in `main.dart` and `android.priority: "high"` from the backend. iOS data-only is best-effort. See [Background / killed behaviour](#background--killed-behaviour).

#### 21. How do I show notification action buttons (Reply / Mute / …)?

Backend sends data-only with `data.actions` as a JSON-encoded array. The bridge parses it and renders via `flutter_local_notifications`. Cross-platform on Android; iOS needs pre-registered `DarwinNotificationCategory` instances. See [Backend payload contract](#backend-payload-contract-for-action-buttons).

### Build & release

#### 22. How do I rename the app?

Search-replace `flutter_starter` in [`pubspec.yaml`](pubspec.yaml), Android `applicationId` ([`android/app/build.gradle`](android/app/build.gradle)), iOS `PRODUCT_BUNDLE_IDENTIFIER` ([`ios/Runner.xcodeproj/project.pbxproj`](ios/Runner.xcodeproj/project.pbxproj)), and update `AppConstants.appName` + `appBundleID` + `appIosAppId` in [`app_constants.dart`](lib/core/utils/constants/app_constants.dart).

#### 23. When do I need to run `build_runner`?

After: adding / removing an `@injectable` (`@LazySingleton`, etc.) class, deleting a module that had any. The generated file is [`injection.config.dart`](lib/core/di/injection.config.dart).

#### 24. Do I commit `injection.config.dart`?

Yes. It's checked in so fresh clones don't need a build to compile.

### Removing things

#### 25. How do I remove a module I'm not using?

Each module has its own "Remove" subsection — auth, FCM, notifications, app_upgrade, image_picker. The summary table is at [Removability cheat sheet](#removability-cheat-sheet).

#### 26. Can I remove the network layer if my app has no API?

Yes. Delete `lib/core/network/`, drop `dio` from pubspec, drop `API_BASE_URL` from `.env`, run `build_runner`. Domain `AppException` family stays — failures happen regardless of HTTP.

#### 27. What about removing onboarding entirely?

Delete `lib/modules/onboarding/`, set the initial `go_router` location to `Routes.dashboard.path` in [`app_router.dart`](lib/core/router/app_router.dart), and remove the "Show app tour again" tile from settings.

---

## Build & ship

```
flutter build apk --release
flutter build ipa --release          # then ship through Xcode/Transporter
```

Before shipping:
- Rename the package (search for `flutter_starter` in `pubspec.yaml`, Android `applicationId`, iOS `PRODUCT_BUNDLE_IDENTIFIER`).
- Replace the seed + accent in `AppColors`.
- Drop unused modules per the cheat sheet above.
- Swap `InMemoryAuthRepository` for your real backend.
- `flutter analyze && flutter test` clean.
- Smoke-test the playground reset, theme picker, and onboarding replay.
