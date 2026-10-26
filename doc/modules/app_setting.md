# App setting

App-wide flags that must survive a restart, in one `HydratedCubit`. Today it holds one flag: whether onboarding still has to be shown. Keep it while the [onboarding](onboarding.md) module (or any other flag you add here) needs it.

## What it provides

- `AppSettingCubit` (`presentation/bloc/app_setting/`): `markOnboardingComplete()`, `requestOnboardingReplay()`. Provided app-wide in `lib/app/global_bloc_config.dart`.
- `AppSettingState`: `showOnboardingAtAppOpen` (default `true`), with `toJson` / `fromJson`.
- `AppSettingEntity` (`domain/entity/`): the same field as a plain entity. Nothing reads it yet.

## Depends on

- `hydrated_bloc`, with its storage built in `lib/main.dart` (`_setupHydratedStorage`, before `runApp`). Shared with core's `ThemeCubit`.
- No other module, no DI classes, no native keys, no `.env` keys.

## Setup

Nothing to set up.

## Use

```dart
// Read
final showOnboarding = context.read<AppSettingCubit>().state.showOnboardingAtAppOpen;

// Write
context.read<AppSettingCubit>().markOnboardingComplete();
context.read<AppSettingCubit>().requestOnboardingReplay();
```

Add a flag: a field in `AppSettingState` (constructor default, `copyWith`, `toJson`, `fromJson` with a fallback, `props`) and a method on the cubit that emits it.

## Remove

1. Delete `lib/modules/app_setting/`.
2. `lib/app/global_bloc_config.dart`: remove `import 'package:flutter_starter/modules/app_setting/app_setting.dart';` and `BlocProvider<AppSettingCubit>(create: (_) => AppSettingCubit()),`.
3. Its readers, found with `grep -rn "AppSettingCubit\|modules/app_setting/" lib`:
   - `lib/modules/onboarding/features/splash/presentation/views/splash_screen.dart`: the `app_setting` import, and `SplashScreen._onState` picks the route without the flag (always `Routes.dashboard`, or your own rule).
   - `lib/modules/onboarding/presentation/views/onboarding_screen.dart`: the `app_setting` import and the `markOnboardingComplete()` call in `_finish`.
   - `lib/modules/settings/presentation/widgets/settings_replay_onboarding_tile.dart`: delete the tile, its export in `widgets.dart` and its use in `settings_screen.dart` (see the [onboarding](onboarding.md) and [settings](settings.md) docs).
4. Keep `hydrated_bloc` in `pubspec.yaml`: `ThemeCubit` and `lib/main.dart` use it.
5. `dart run build_runner build`, then `flutter analyze`.

## Hidden details

- It is a `HydratedCubit`, not a `SafeCubit` like the other cubits, because its state is written to disk after every change and read back at launch.
- The saved JSON is `{"showOnboardingAtAppOpen": bool}`; a missing or unreadable value falls back to `true`, so a broken entry shows onboarding again rather than crashing.
- The saved state sits under the fixed key `AppSettingCubit` (`storagePrefix`). hydrated_bloc's default is the runtime type's name, which obfuscated and minified builds change; onboarding would then show once more. Keep the string if you rename the class.
- The storage lives in the app documents directory (`HydratedStorageDirectory.web` on the web): it survives restarts and updates, and clearing the app's data resets it.
