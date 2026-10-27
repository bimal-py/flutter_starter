# Utilities

The small shared pieces: constants, `.env` access, enums, extensions and helpers (`lib/core/utils/`), platform services (`lib/core/services/`), and the base classes and widgets every module reuses (`lib/common/`).
The rule: look here before writing a helper or a widget, and read `.env` through `EnvConfig` getters, not `EnvHelper.get('...')` at call sites (a removable module may read its own keys in its helper, as mobile_ads does).

## Where it lives

```
lib/core/utils/
├── constants/    AppConstants, AppUrls, CommonStrings, EnvConfig
├── enums/        AppLoadingState
├── extensions/   context_extension.dart, string_extension.dart
└── helpers/      EnvHelper, CustomLogger, UrlHelper, Hive app box, SecureStorageHelper,
                  CustomSnackbar, dialog/, permission/
lib/core/services/   FirebaseService, ShareService
lib/common/          bloc/, usecases/, observers/, widgets/
```

Toasts and dialogs: [errors and messages](errors_and_messages.md). Permissions: [permissions](permissions.md). Hive and secure storage: [storage](storage.md).

## Constants and `.env`

- `AppConstants`: `appName`, `defaultNullValue` (`'-'`), `splashDuration` (2 s), `supportedLocales` (`[Locale('en')]`), `appBoxName`, store ids (`appIosAppId`, `appAndroidPackageId`), About-screen copy. Replace the placeholders before shipping.
- `AppUrls`: download link, website, privacy policy, terms, support email, developer links, demo site. Replace them too: most point at the starter's author.
- `CommonStrings`: `loading`, `goBack`, `cancel`, `done`.
- `EnvConfig`: one getter per `.env` key the core reads (a DEV/PROD pair shares one).

| Key | Read by | Notes |
|---|---|---|
| `FIREBASE_ENABLED` | `EnvConfig.firebaseEnabled` | `true`, `1` or `yes` turns Firebase on |
| `API_BASE_URL` | `EnvConfig.apiBaseUrl` → `DioConfig` | a trailing `/` is trimmed |
| `DEV_AUTH_KEY`, `PROD_AUTH_KEY` | `EnvConfig.authKey` | PROD in release builds only |
| `GOOGLE_SERVER_CLIENT_ID`, `APPLE_CLIENT_ID`, `APPLE_REDIRECT_URL` | `EnvConfig.googleServerClientId`, `appleClientId`, `appleRedirectUrl` | for the Google / Apple provider you add |
| `{DEV,PROD}_{ANDROID,IOS}_<AD>_AD_UNIT_ID` | the mobile_ads helpers | `<AD>`: `APP_OPEN`, `BANNER`, `INTERSTITIAL`, `REWARDED`, `REWARDED_INTERSTITIAL`, `NATIVE`; PROD in release builds only |

`.env_example` lists every key; copy it to `.env`.

## Enums and extensions

`AppLoadingState`: `initial`, `loading`, `success`, `failure`, with `isInitial`, `isLoading`, `isSuccess`, `isFailure`. A state that loads something uses it; don't invent a per-bloc status enum for that. The status enums that do exist track something else: `AuthStatus` (signed in or out), `AppUpgradeStatus` (the version check) and the full-screen ads' `…AdStatus` (`loaded`, `showing`).

- `BuildContext`: `context.theme`, `colorScheme`, `textTheme`, `customTheme` (success, warning, info), `scaffold`, `screenSize`, `screenWidth`, `screenHeight`.
- `String`: `capitalize` (`'ada'` → `'Ada'`), `isValidEmail`.
- `String?`: `isNullOrEmpty`, `capitalizeWords` (`'ada lovelace'` → `'Ada Lovelace'`, null stays null), `orDefault([fallback = ''])`.

```dart
Text(user.fullName.capitalizeWords.orDefault(AppConstants.defaultNullValue));
if (user.phone.isNullOrEmpty) return const SizedBox.shrink();
```

## Helpers and services

```dart
final log = CustomLogger(title: 'Notes');
log.i('loaded ${notes.length}'); // d, i, w, e; prints in debug builds only

await const UrlHelper().launch(AppUrls.privacyPolicy); // throws AppException
await const UrlHelper().sendEmail(to: AppUrls.supportEmail, subject: 'Feedback');

FirebaseService.logScreenView('notes'); // no-op while Firebase is off

// Share from a button: pass that button's context.
IconButton(
  icon: const Icon(Icons.share),
  onPressed: () => ShareService.shareText(context: context, text: AppUrls.appDownload),
);
```

- `EnvHelper`: `init()` (called in `main`), `get(key)` (`''` when missing), `getBool(key)`.
- `FirebaseService`: `init()` (before `runApp`), `setupCrashlyticsAndAnalytics()` (end of `main`), `logScreenView`, `analyticsObserver`, `isInitialised`. Everything is a no-op unless `FIREBASE_ENABLED=true` and `Firebase.initializeApp()` succeeds. In release builds it turns on Crashlytics (Flutter and platform errors, as fatal) and logs `app_open`; in debug and profile builds it turns Crashlytics collection off.
- `ShareService`: `shareText`, `shareFiles` (absolute paths), `shareImageBytes` (written to the temp folder first).

## `lib/common/`

- `SafeCubit<S>`: a `Cubit` whose `emit` does nothing after `close()`, so a late reply can't crash a closed screen. New cubits extend it (persisted ones extend `HydratedCubit`).
- `PaginatedListState` (mixin: `loadingState`, `isLoadingMore`) and `bloc.awaitSettled()` for pull-to-refresh on a paginated `Bloc`.
- `PasswordVisibilityCubit`: `toggle()`, `show()`, `hide()`.
- `UseCase<Return, Params>` (`FutureOr<Return> execute(Params)`), `StreamUseCase<Return, Params>` (`Stream<Return>`), `NoParams`.
- `AppBlocObserver`: logs every event, change, transition and error (debug only). Set in `main`.

| Widget | What it is |
|---|---|
| `AppTextField`, `AppPasswordField` | labelled field with the app's typing defaults; the password one adds an eye toggle |
| `TextFieldDefaults` | no suggestions or autocorrect, capitalisation by keyboard type, unfocus on tap outside |
| `FieldWithError`, `InputAffix`, `RequiredLabel` | error under a non-text control; always-visible unit (`Rs.`, `%`); label with a red `*` |
| `ErrorView`, `ErrorScreen` | inline failure with retry; full-page failure |
| `context.showPopupLoading()`, `ListRowSkeleton` | blocking loader for submits; shimmer row for a next page |
| `LazyIndexedStack` | tabs built on first visit, then kept alive |
| `RefreshableScrollView` | pull-to-refresh for a short or empty state |
| `CachedNetworkImageWrapper`, `SvgViewer` | network image with shimmer and error box; asset SVG with optional tint |
| `InfoRowTile` | label above value, as a dense `ListTile` |

```dart
// NoteStrings, AccountStrings: the feature's own copy classes.
AppTextField(
  label: NoteStrings.title,
  controller: _title,
  isRequired: true,
  textInputAction: TextInputAction.next,
);
AppPasswordField(
  label: AccountStrings.password,
  validator: AuthValidators.password,
);
CachedNetworkImageWrapper(
  url: user.avatar ?? '',
  width: 48.r,
  height: 48.r,
  borderRadius: BorderRadius.circular(24.r),
);
```

## How to change / extend

**Add a `.env` key**

1. Add it, empty and commented, to `.env_example`, and give it a value in your `.env`.
2. Add a getter to `EnvConfig` (a getter, not a `static final`, so a change to it applies on hot reload).
3. Read `EnvConfig.<key>` everywhere.

**Add an extension or helper**: app-wide ones go in `lib/core/utils/extensions/` or `helpers/` and in that folder's barrel. Module-only ones go in the module's `utils/`.

**Add a shared widget**: only when two modules need it. One widget per file in `lib/common/widgets/`, exported from `widgets.dart`, styled from the theme.

**Turn on Firebase**: `flutterfire configure`, set `FIREBASE_ENABLED=true`, then uncomment the `firebase_options.dart` import and the `options:` line in `firebase_service.dart`.

## Hidden details

- `.env` is bundled as an asset: anyone can read it from the APK or IPA. Only public values go there.
- `.env` loads once, in `main` (`EnvHelper.init()`). After editing it, restart the app: hot reload keeps the old values.
- Every `DEV_*` / `PROD_*` pair follows `kReleaseMode`: release builds read `PROD_*`, debug and profile builds read `DEV_*` (so a profile build never serves real ads).
- `FirebaseService.init()` returns `false` on web, when the flag is off, or when init throws. Crashlytics is wired after `runApp`, so errors before that aren't reported.
- `ShareService` needs the tapped widget's `context`: iPad uses its position for the share popover. `shareFiles` gives each file the MIME type at the same index of `mimeTypes`.
- `isValidEmail` (string extension) is the app's one email rule; `AuthValidators` uses it. It accepts `+` tags, subdomains and any TLD length.
- There's no endpoint class in core. Endpoint paths live in each module's `<feature>_api_route.dart`, without a leading `/`.
- `awaitSettled()` is an extension on `Bloc`, so a `Cubit` can't use it. It waits for the next settled state: emit `loading` when the refresh starts, or a refresh whose result equals the current state (a Bloc doesn't re-emit it) leaves the indicator spinning.
- `context.customTheme` force-unwraps the extension: it throws in a context without the app theme.
- `AppPasswordField` creates its own `PasswordVisibilityCubit`, so two password fields toggle independently. Provide the cubit yourself only for a custom field.
- `LazyIndexedStack` keeps every visited tab alive: a tab loads on first visit and switching back never reloads it (pull-to-refresh does).
