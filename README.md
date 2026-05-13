# Flutter Starter

Opinionated Flutter starter with feature-first architecture, Material 3 theming, a removable network/notifications/FCM stack, and a built-in theme playground end users can use to customize the app.

```
flutter pub get
dart run build_runner build
flutter run
```

`.env` lives at the project root and is loaded by `flutter_dotenv` (see [.env.example](.env.example)).

---

## Table of contents

- [Architecture at a glance](#architecture-at-a-glance)
- [Theme](#theme)
- [Localization & per-locale fonts](#localization--per-locale-fonts)
- [State management (BLoC)](#state-management-bloc)
- [Dependency injection](#dependency-injection)
- [Routing](#routing)
- [Responsive sizing](#responsive-sizing)
- [Storage](#storage)
- [Toasts](#toasts)
- [Network / API layer](#network--api-layer) *(removable)*
- [Notifications](#notifications) *(removable, package-swappable)*
- [FCM (push)](#fcm-push) *(removable)*
- [Firebase](#firebase) *(opt-in)*
- [Onboarding replay](#onboarding-replay)
- [Removability cheat sheet](#removability-cheat-sheet)
- [Build & ship](#build--ship)

---

## Architecture at a glance

```
lib/
├── main.dart                  app bootstrap; one line per optional module
├── app/                       composition root (StarterApp, BlocProviders)
├── core/                      framework — imports no module
│   ├── di/                    get_it + injectable
│   ├── errors/                AppException, AppErrorStrings (domain failures)
│   ├── network/               Dio + interceptors + ApiErrorStrings (deletable)
│   ├── router/                go_router config
│   ├── services/              Firebase service (opt-in)
│   ├── theme/                 everything theme: sources, cubit, extension, typography
│   └── utils/                 EnvConfig, constants, helpers
├── common/                    shared widgets / bloc observer
└── modules/                   features (one folder per)
    ├── app_setting/           HydratedCubit for onboarding flag
    ├── notifications/         local notifications (deletable)
    ├── fcm/                   push (deletable)
    └── …feature modules
```

Rule of thumb: `modules/` may import `core/` and `common/`. `core/` may not import `modules/`.

---

## Theme

The theme system has three layers:

1. **Developer source** — what your app code wires at startup. Defaults to `SeedOnlySource(seed: AppColors.seed, accent: AppColors.accent)`.
2. **User override** — what the in-app playground writes. When set, wins over the developer's source. Cleared via "Reset".
3. **Variants** — light / dark / system (extensible via `ThemeVariant.custom(name)`).

All theming flows through `lib/core/theme/`:

```
core/theme/
├── app_theme_builder.dart     compose(source, deviceSchemes, locale, fonts) → {light, dark}
├── colors/                    AppColors (seed + accent), BrandPalette
├── component_themes/          AppBar/Button/Card/Input/etc. theme builders
├── cubit/                     ThemeCubit + ThemeState
├── extension/                 CustomThemeExtension (38 semantic colors)
├── source/                    sealed ThemeSource family
├── typography/                AppTextStyle + LocalizedFonts + AppText
└── variant/                   sealed ThemeVariant
```

### Setup

Edit [lib/core/theme/colors/app_colors.dart](lib/core/theme/colors/app_colors.dart):

```dart
class AppColors {
  AppColors._();
  static const Color seed = Color(0xFF1B3A6B);   // your brand
  static const Color accent = Color(0xFFC8A96B); // optional, harmonized to seed
}
```

That's it for the seed-based default. To opt into device wallpaper colors (Android 12+), set the developer source explicitly when instantiating `ThemeCubit` in [lib/app/global_bloc_config.dart](lib/app/global_bloc_config.dart):

```dart
BlocProvider<ThemeCubit>(
  create: (_) => ThemeCubit(
    developerSource: DynamicDeviceSource(fallbackSeed: AppColors.seed),
  ),
),
```

`DynamicColorBuilder` is already wired in [lib/app/app.dart](lib/app/app.dart) — the source picks it up automatically.

### Use

In any widget:

```dart
final scheme = Theme.of(context).colorScheme;             // Material roles
final ext = Theme.of(context).extension<CustomThemeExtension>()!;  // semantic
Container(color: scheme.primaryContainer);
Container(color: ext.success);                            // status colors
Container(color: ext.brandAccent);
Text('Hi', style: context.textTheme.titleMedium);
```

`context.colorScheme` and `context.textTheme` are extension getters defined in [lib/core/utils/extensions/](lib/core/utils/extensions/).

### Five ThemeSource variants

| Variant | When to use | Example |
|---|---|---|
| `SeedOnlySource` | Default. Pick one brand color; Material 3 derives the rest. | `SeedOnlySource(seed: ..., accent: ...)` |
| `SeedWithOverridesSource` | Seed + override specific Material roles. | `SeedWithOverridesSource(seed: ..., lightSchemeOverrides: {'primary': Colors.purple})` |
| `FullCustomSource` | Hand every color and TextTheme entry. | `FullCustomSource.builder().withLight(scheme: ..., extension: ...).withDark(...).build()` |
| `DynamicDeviceSource` | Use device wallpaper colors (Android 12+). | `DynamicDeviceSource(fallbackSeed: ...)` |
| `FromImageSource` | Extract dominant color from an image. | `FromImageSource(imageRef: FileImageRef(path), fallbackSeed: ...)` |

`SupportedBrightness` on the source declares which modes a source can render (`light` only, `dark` only, or `both`). The cubit respects it.

### Theme playground (end-user customization)

Settings → "Customize theme" opens a screen where the user picks brightness + source + seed color. Writes to `ThemeCubit.userOverride`; clicking Reset restores the developer's source. No code needed — it's already wired.

### CustomThemeExtension

For colors not in Material's `ColorScheme` (status colors beyond `error`, shimmer base/highlight, input backgrounds, gradient stops, ratings, etc.). 38 semantic fields. See [lib/core/theme/extension/custom_theme_extension.dart](lib/core/theme/extension/custom_theme_extension.dart).

Add new fields by editing that file: add the property, update `copyWith` and `lerp`, then add the default value in `lightDefault` and `darkDefault`.

### Remove

Theme is non-removable — it's how the app draws. To remove just the playground:
- Delete [lib/modules/settings/presentation/views/theme_playground_screen.dart](lib/modules/settings/presentation/views/theme_playground_screen.dart).
- Delete [lib/modules/settings/presentation/widgets/settings_theme_playground_tile.dart](lib/modules/settings/presentation/widgets/settings_theme_playground_tile.dart).
- Remove the `themePlayground` route from [lib/core/router/routes.dart](lib/core/router/routes.dart) and [app_router.dart](lib/core/router/app_router.dart).
- Remove `flutter_colorpicker` from [pubspec.yaml](pubspec.yaml).

To remove Material You device-color support:
- Stop using `DynamicDeviceSource` anywhere.
- Remove `DynamicColorBuilder` wrap in [lib/app/app.dart](lib/app/app.dart) (call `AppThemeBuilder.compose` directly without device schemes).
- Remove `dynamic_color` from [pubspec.yaml](pubspec.yaml).

---

## Localization & per-locale fonts

Some scripts (Devanagari, Bengali, Arabic) render visually smaller than Latin at the same `fontSize`. [`LocalizedFonts`](lib/core/theme/typography/localized_fonts.dart) maps locale → `AppFont(family, scale)` and the active TextTheme bakes them in.

### Setup

Add font files to `assets/fonts/` (e.g. download Mukta from Google Fonts), then declare them in [pubspec.yaml](pubspec.yaml):

```yaml
fonts:
  - family: Mukta
    fonts:
      - asset: assets/fonts/Mukta/Mukta-Regular.ttf
        weight: 400
      ...
```

Edit `LocalizedFonts.defaults()` to wire the new family:

```dart
factory LocalizedFonts.defaults() => const LocalizedFonts(
  defaultFont: AppFont(family: 'Inter', scale: 1.0),
  byLocale: {
    'ne': AppFont(family: 'Mukta', scale: 1.10),
    'hi': AppFont(family: 'Mukta', scale: 1.10),
    // add yours here
  },
);
```

### Use

The `TextTheme` from `Theme.of(context)` already carries the right family + scale. Use `context.textTheme.bodyMedium` etc. — don't hard-code `TextStyle(fontSize: 16)`.

If you need raw access to the AppFont:

```dart
final font = LocalizedFonts.defaults().resolve(Localizations.maybeLocaleOf(context));
```

### Remove

Drop the entry from `LocalizedFonts.defaults()` and the asset from `pubspec.yaml`. Nothing else changes.

---

## State management (BLoC)

Default to `Cubit`. Use `Bloc` when state transitions naturally come from typed events.

App-wide cubits live in [lib/app/global_bloc_config.dart](lib/app/global_bloc_config.dart):

```dart
BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
BlocProvider<AppSettingCubit>(create: (_) => AppSettingCubit()),
```

These are instantiated inline (not via DI) because they're tied to the app lifecycle. HydratedCubit persists their state automatically.

### Setup

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}
```

Provide it at the right scope (feature-local prefers `BlocProvider` near the screen; truly global goes in `global_bloc_config.dart`).

### Use

```dart
context.read<CounterCubit>().increment();      // fire
BlocBuilder<CounterCubit, int>(builder: ...);   // observe
```

For persisted state extend `HydratedCubit<T>` and implement `toJson`/`fromJson`. Storage is initialized in `main.dart`.

---

## Dependency injection

`get_it` + `injectable` (codegen).

### Setup

Annotate a class:

```dart
@Injectable(as: MyRepository)  // bind interface → impl
class MyRepositoryImpl implements MyRepository { … }

@singleton    // single instance, created at init
class MyService { … }

@injectable   // new instance per resolve
class MyHandler { … }
```

Then run `dart run build_runner build` to regenerate [lib/core/di/injection.config.dart](lib/core/di/injection.config.dart). `configureDependencyInjection()` is already called from `main.dart`.

### Use

```dart
final repo = getIt<MyRepository>();
```

For cross-cutting platform singletons (FlutterSecureStorage, Connectivity, etc.), see [lib/core/di/service_module.dart](lib/core/di/service_module.dart).

`ThemeCubit` and `AppSettingCubit` are NOT in DI — they're created inline in `BlocProvider.create:`. If you need a cubit that's also a service, you can still register it with `@injectable` like any other class.

---

## Routing

`go_router` with a typed `Routes` enum.

### Setup

Add to [lib/core/router/routes.dart](lib/core/router/routes.dart):

```dart
enum Routes {
  …
  profile(name: 'profile', path: 'profile'),
}
```

Register in [lib/core/router/app_router.dart](lib/core/router/app_router.dart):

```dart
GoRoute(
  name: Routes.profile.name,
  path: Routes.profile.path,
  builder: (context, state) => const ProfileScreen(),
),
```

### Use

```dart
context.goNamed(Routes.profile.name);
context.pushNamed(Routes.profile.name, extra: someObject);
```

---

## Responsive sizing

`flutter_scale_kit` extension methods on `num`:

```dart
EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
BorderRadius.circular(12.r)
Text(style: TextStyle(fontSize: 14.sp))
fontSize: 16.spClamp(12, 20)   // clamps when device font scale is extreme
```

`ScaleKitBuilder` is wired at the root in `main.dart` with a 425×691 design size — edit there if your designs target a different reference.

---

## Storage

Three tools, each for one thing:

- **HydratedBloc** for cubit/bloc state. Automatic. Initialized in `main.dart`.
- **Hive** for structured app data (objects with adapters). Open boxes in [lib/app/hive_bootstrap.dart](lib/app/hive_bootstrap.dart).
- **flutter_secure_storage** for tokens / secrets. Reach via `SecureStorageHelper.instance` ([lib/core/utils/helpers/secure_storage_helper.dart](lib/core/utils/helpers/secure_storage_helper.dart)).

`shared_preferences` is included for libraries that need it (e.g. `dynamic_color`), but app code should reach for one of the above.

---

## Toasts

`CustomSnackbar` (fluttertoast-backed):

```dart
CustomSnackbar.success(context, 'Saved');
CustomSnackbar.error(context, 'Could not save');
CustomSnackbar.info(context, 'Heads up');
```

Prefer this over `ScaffoldMessenger.of(context).showSnackBar(...)` — consistent style across screens.

---

## Network / API layer

Path: [lib/core/network/](lib/core/network/). Dio-backed. Removable.

### Setup

Set `API_BASE_URL` in `.env`:

```env
API_BASE_URL=https://api.example.com
```

The `RemoteService` is registered via `@Injectable` — `dart run build_runner build` puts it in DI.

### Use

In a repository:

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

The `RemoteService` exposes `get/post/put/patch/delete`. Files in `post`/`put`/`patch` go as multipart automatically.

Wire token refresh by setting `refreshTokenCallback` on `RemoteServiceImpl`:

```dart
(getIt<RemoteService>() as RemoteServiceImpl).refreshTokenCallback = () async {
  // call refresh endpoint, persist new tokens, return new access token
};
```

### Error model

```
DioException → DioExceptionUtil.handleError → ApiErrorStrings.x
                                            ↓
                              throw ServerException(message: ...)
```

In repositories:
- **Wire failures** (network down, 401, 500) come from `RemoteService` as `ServerException(message: ApiErrorStrings.x)`.
- **Shape failures** (2xx but body is malformed) — throw `ServerException(message: AppErrorStrings.invalidResponseShape)` yourself.
- **Feature-specific failures** — declare `lib/modules/<feature>/utils/<feature>_error_strings.dart` and throw with its constants.

### Remove

If your app has no API:
- Delete `lib/core/network/`.
- Remove `dio` from `pubspec.yaml`.
- Remove `API_BASE_URL` from `.env`.
- `dart run build_runner build` to drop the generated registrations.

`AppErrorStrings` stays in `core/errors/` — domain failures happen regardless of HTTP.

---

## Notifications

Path: [lib/modules/notifications/](lib/modules/notifications/). Local notifications, FCM-independent.

### Pluggable provider

`NotificationService` (public singleton) delegates to a `NotificationProvider`. The default is `FlutterLocalNotificationsProvider`. To swap packages (e.g. to `awesome_notifications`), implement the interface and pass it at init — no other call sites change.

### Setup

Already wired — `await NotificationService.instance.initialize()` in `main.dart`.

Native config needed for the feature to work end-to-end (not auto-applied):
- **Android**: `POST_NOTIFICATIONS` permission, `RECEIVE_BOOT_COMPLETED` for scheduled notifications, `flutter_local_notifications` receiver entries. Provide a monochrome `@drawable/ic_notification`.
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
  ),
);

await NotificationService.instance.schedule(
  NotificationPayload(id: 43, title: 'Wake up', body: ''),
  DateTime.now().add(const Duration(hours: 8)),
);

NotificationService.instance.onTap.listen((event) {
  // navigate based on event.payload.data
});
```

Define your own channels:

```dart
await NotificationService.instance.initialize(
  additionalChannels: [
    NotificationChannel(
      id: 'reminders',
      name: 'Reminders',
      description: 'Daily reminders',
      importance: NotificationPriority.high,
    ),
  ],
);
```

### Swap the provider

```dart
class AwesomeNotificationsProvider implements NotificationProvider { … }

await NotificationService.instance.initialize(
  provider: AwesomeNotificationsProvider(),
);
```

### Remove

- Delete `lib/modules/notifications/`.
- Remove `await NotificationService.instance.initialize();` from `main.dart`.
- Remove `flutter_local_notifications` and `timezone` from `pubspec.yaml`.
- If FCM is also installed, delete `lib/modules/fcm/integrations/notifications_bridge.dart`.

---

## FCM (push)

Path: [lib/modules/fcm/](lib/modules/fcm/). Depends on Firebase. Independent of Notifications (an optional bridge lives in `integrations/`).

### Setup

1. Configure Firebase (see [Firebase](#firebase) below).
2. `FIREBASE_ENABLED=true` in `.env`.
3. Already wired in `main.dart`:
   ```dart
   FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);   // line 1
   await FcmService.instance.initialize(                          // line 2
     onForegroundMessage: buildNotificationBridge(),
   );
   ```
4. Native config:
   - **iOS**: APNs key/cert in Firebase console, Push Notifications capability in Xcode, Background Modes → Remote notifications.
   - **Android**: `google-services.json` (pulled by `flutterfire configure`).

When `FIREBASE_ENABLED=false`, both lines no-op.

### Use

```dart
final token = await FcmService.instance.getToken();

await FcmService.instance.subscribeToTopic('news');

if (await FcmService.instance.shouldSyncToken(token: token!, userId: '42')) {
  // POST it to your backend
  await FcmService.instance.markTokenSynced(token: token, userId: '42');
}

FcmService.instance.onMessageOpenedApp.listen((msg) {
  // navigate based on msg.data
});
```

### Bridge to notifications (when both modules are present)

`buildNotificationBridge()` turns foreground FCM payloads into local notifications. Customize per app:

```dart
await FcmService.instance.initialize(
  onForegroundMessage: buildNotificationBridge(
    defaultChannel: NotificationChannels.highPriorityChannelId,
    idResolver: (msg) => msg.data['orderId'].hashCode,
  ),
);
```

### Remove

- Delete `lib/modules/fcm/`.
- Remove both FCM lines from `main.dart`.
- Remove `firebase_messaging` from `pubspec.yaml`.
- `dart run build_runner build`.

To remove the bridge but keep FCM:
- Delete `lib/modules/fcm/integrations/notifications_bridge.dart`.
- Pass `onForegroundMessage: null` in `main.dart`.

---

## Firebase

Opt-in. Without enabling, the app builds and runs without any Firebase code executing.

### Setup

1. `dart pub global activate flutterfire_cli`.
2. `flutterfire configure` — generates `lib/firebase_options.dart` (gitignored).
3. Uncomment the import + `options:` line in [lib/core/services/firebase_service.dart](lib/core/services/firebase_service.dart).
4. `FIREBASE_ENABLED=true` in `.env`.

### Use

Already wired in `main.dart` — Crashlytics + Analytics come up in release builds only.

```dart
FirebaseAnalytics.instance.logEvent(name: 'add_to_cart', parameters: {...});
FirebaseCrashlytics.instance.recordError(e, st, fatal: false);
```

### Remove

- Delete [lib/core/services/firebase_service.dart](lib/core/services/firebase_service.dart) (and `lib/modules/fcm/` if used).
- Remove the two `FirebaseService.…` calls from `main.dart`.
- Remove `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_messaging` from `pubspec.yaml`.
- Remove `FIREBASE_ENABLED` from `.env`.
- Delete `lib/firebase_options.dart` if generated.

---

## Onboarding replay

`AppSettingCubit` holds `showOnboardingAtAppOpen` (default `true`). When true on next app launch, the splash routes to onboarding.

### Use

End users replay onboarding from Settings → "Show app tour again". The tile calls:

```dart
context.read<AppSettingCubit>().requestOnboardingReplay();
context.goNamed(Routes.onboarding.name);
```

Completing onboarding (last page or Skip) calls `markOnboardingComplete()` which flips the flag back to `false`.

### Customize

Edit the carousel pages in [lib/modules/onboarding/presentation/views/onboarding_screen.dart](lib/modules/onboarding/presentation/views/onboarding_screen.dart). The replay flow needs no changes.

---

## Removability cheat sheet

| Feature | Delete | Remove from main.dart | Remove from pubspec | Remove from .env |
|---|---|---|---|---|
| Notifications | `lib/modules/notifications/` | `NotificationService.instance.initialize()` | `flutter_local_notifications`, `timezone` | — |
| FCM | `lib/modules/fcm/` | both FCM lines | `firebase_messaging` | — |
| Network/API | `lib/core/network/` | — | `dio` | `API_BASE_URL` |
| Firebase (all) | `lib/core/services/firebase_service.dart` + `lib/modules/fcm/` | all Firebase + FCM lines | `firebase_*` | `FIREBASE_ENABLED` |
| Theme playground | playground screen + tile | — | `flutter_colorpicker` | — |
| Device dynamic color | unwrap `DynamicColorBuilder` in app.dart | — | `dynamic_color` | — |

Run `dart run build_runner build` after any module deletion to drop generated registrations.

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
- `flutter analyze && flutter test` clean.
- Smoke-test the playground reset, theme picker, and onboarding replay.
