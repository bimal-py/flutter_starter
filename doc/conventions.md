# Conventions

The rules every file follows. When a rule and existing code disagree, the rule wins; fix the code.

## Names

| Kind | Pattern | Example |
|---|---|---|
| Entity | `<Subject>Entity` | `UserEntity` |
| Model | `<Subject>Model` | `UserModel` |
| Mapper | `<Subject>Mapper` | `UserMapper` |
| Remote repository / impl | `Remote<Subject>Repository` / `…Impl` | `RemoteAuthRepository`, `RemoteAuthRepositoryImpl` |
| Local repository / impl | `Local<Subject>Repository` / `…Impl` | `LocalAuthSessionRepository` |
| Use case | `<Verb><Subject>UseCase` | `LoginUseCase`, `FetchUserUseCase` |
| Use-case params | `<UseCase>Params` (the use case's name + `Params`) | `LoginUseCaseParams` |
| Cubit / Bloc | ends in `Cubit` / `Bloc` (by the class it extends) | `LoginCubit`, `AuthBloc` |
| Bloc event | subject + past tense | `NotesSearchChanged` |
| State | `<Cubit name without Cubit>State` | `LoginState` |
| Screen / its body | `<Name>Screen` / `<Name>View` | `SettingsScreen`, `SettingsView` |
| Widget | `<Subject><Element>`, no `Widget` suffix | `SettingsTile`, `LoginForm` |
| Skeleton | `<Subject>Skeleton` | `ProductListSkeleton` |
| Route arguments | `<Subject><Screen>Args` | `ResetPasswordArgs` |
| Constants / routes / copy | `<Subject>Constants`, `<Subject>ApiRoute`, `<Subject>Strings`, `<Subject>Error` | `AuthApiRoute` |
| Storage keys / box | `<Subject>StorageKeys`, `<subject>_hive.dart` | `AuthStorageKeys` |
| Skeleton data | `k<Subject>SkeletonDummy` | `kProductListSkeletonDummy` |

Files are `snake_case` of the main class. Data and domain folders are singular (`model/`, `entity/`, `use_case/`). Strip API artifacts from names: route `vproduct/` still means `Product…`.

## Imports

- Import barrels only. Every folder except `lib/` and `lib/modules/` has one, named after the folder.
- Other areas: `package:<app>/core/core.dart`, `package:<app>/common/common.dart`, `package:<app>/modules/<other>/<other>.dart`.
- Inside a module: the nearest barrel of the target's layer (`…/auth/domain/domain.dart`, `…/widgets/widgets.dart`). Never your own top barrel, never a deep file.
- Adding or renaming a file means updating its folder's barrel in the same change. A state or event file is a `part` of its cubit or bloc, so the barrel exports only the cubit or bloc file.

## Data layer

- **Model**: plain class, every field nullable, `copyWith`, `fromRawJson`, `toRawJson`, `fromJson`, `toJson`. Snake-case keys. One sibling model per nested object. Parse defensively (`?.toString()`, `(x as num?)?.toInt()`, `DateTime.tryParse`).
- **Entity**: `extends Equatable`, `const` constructor, fields nullable unless always present, full `props`, no `copyWith`, no JSON. Convenience getters are fine (`initials`).
- **Mapper**: static class with the ten functions `toEntity`, `toModel`, `fromJsonToEntity`, `fromRawJsonToEntity`, `toJsonFromEntity`, `toRawJsonFromEntity`, `fromJsonListToEntityList`, `fromRawJsonListToEntityList`, `toJsonListFromEntityList`, `toRawJsonListFromEntityList`. Names of people and places go through `capitalizeWords` here.
- **Repository**: returns entities (or `PaginatedEntity<T>` for lists), never models or maps. `RemoteService` already throws on non-2xx, so don't re-check success. Unwrap replies with `ApiResponseEnvelope.asObject` / `asPaginationEnvelope`; both return `null` for a reply of another shape, and the repository then throws a `ServerException` with the feature's copy (`UserError.invalidReply`).
- **API routes**: paths only, no leading slash, trailing slash (`auth/login/`). Times from the backend are UTC; convert with `.toLocal()` in the model.

## Use cases

One per action a cubit or bloc invokes, even one-liners; cubits and blocs never call a repository directly. `@injectable`, extends `UseCase<Return, Params>` (or `StreamUseCase`). `NoParams` when there is no input. Trim and lowercase emails in the use case, not in the UI.

## Presentation

- **Screens**: `presentation/views/<name>_screen.dart` holds `<Name>Screen`, always a `StatelessWidget` that provides the screen's blocs and the `BlocListener`s for side effects (loader, toast, navigation), and below it `<Name>View`, which builds the UI. A reusable component is a widget, not a view.
- **Widgets**: one widget class per file in `presentation/widgets/` (a sub-folder per screen when it grows). No `Widget _buildX()` helpers: make them widgets.
- **Cubits**: extend `SafeCubit`; one whose state must survive a restart extends `HydratedCubit` instead (`ThemeCubit`, `AppSettingCubit`). Method names: `load()` (first load, "Try again"), `refresh()` (pull-to-refresh, keeps what is on screen), `loadMore()` (next page). State holds `loadingState`, the data and `error` only (a paged list adds `isLoadingMore`, which `PaginatedListState` requires).
- **Loading**: no `CircularProgressIndicator` for a loading state. First load: a skeleton (`<Subject>Skeleton` = the real widget inside `Skeletonizer`, fed `k<Subject>SkeletonDummy`). Failure with nothing on screen: `ErrorView(message:, onRetry:)`. Failure with data on screen: a toast. Submits (save, login, delete): `context.showPopupLoading()` on loading, `context.hidePopupLoading()` on success and failure, from a `BlocListener`.
- **Lists**: page with the pagination module (`PaginationHelper.query`, `PaginationScrollBuilder`, `PaginationLoadingFooter`). Never pick a page size per list. Searches that hit the API wait 500 ms: give a Bloc's search event `transformer: debounceRestartable(searchDebounceDuration)`. A list nested in another scroll view sets `padding: EdgeInsets.zero`.
- **Tabs**: `LazyIndexedStack`: a tab loads on its first visit and is kept alive; switching tabs never reloads.
- **Forms**: `AppTextField` / `AppPasswordField` (no autocorrect or suggestions; capitalisation follows the keyboard type: `TextInputType.name` capitalises words, emails and numbers stay raw). New passwords validate with `AuthValidators.password` (the backend's rules) and `confirmPassword`; `requiredPassword` only checks that one was typed.

## Copy, errors and toasts

- User-facing text lives in `utils/constants/<feature>_strings.dart`; failure text in `<feature>_error.dart`. Shared text: `CommonStrings`, `AppErrorStrings`.
- Show errors with `CustomSnackbar.show(type: ToastType.error, message: AppErrorHandler.getErrorMessage(e))`. Never interpolate `'$e'`: it leaks raw exception text.
- Names of people, shops and places are shown with each word capitalised.

## Theme

- Material widgets styled through `ThemeData` (component themes in `lib/core/theme/component_themes/`). Don't wrap a Material widget just to style it.
- Colors from `context.colorScheme`. `context.customTheme` has `success`, `warning`, `info` only; add a field only when no ColorScheme role fits.
- Page insets and gaps from `AppSpacing` (`gutter`, `page`, `horizontal`, `xs` to `xl`); never a literal `16.w` gutter. Other sizes with flutter_scale_kit: `16.w`, `8.h`, `12.r`, `16.verticalSpace`. Text sizes come from `context.textTheme`; `.sp` is applied only inside the theme (`AppTextStyle.applyTo`).
- One status-bar style for the whole app (set in `app_view.dart`); screens don't add their own.

## Comments

Few and short. Explain why (a backend quirk, an ordering constraint, a non-obvious default), never what the next line does. No history ("used to be…", "moved from…").

## Commits

Conventional commits: `type(scope): summary`, imperative, up to 72 characters. Types: feat, fix, refactor, chore, docs, test, perf. The scope is the module (`feat(auth): …`). Run `flutter analyze` first; never commit with analyzer errors.

## Do / don't

- Do read the neighbouring feature first and mirror it.
- Do keep each module removable: other code reaches it only through its top barrel and the composition points.
- Don't call `getIt` from widgets; cubits do.
- Don't edit generated files (`injection.config.dart`, `*.g.dart`); run `dart run build_runner build`.
- Don't add a package for something a few lines of code can do; when you add one, say in `pubspec.yaml` which module it belongs to.
- Don't call `users/me/` again to learn who is signed in: read `AuthBloc`'s state.
