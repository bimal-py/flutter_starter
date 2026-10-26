# Device info

Reads the device model and OS once at start-up and keeps them in an app-wide cubit. The settings module puts them in its "Report a problem" email. Keep it while something reads it.

## What it provides

- `DeviceInfoCubit` (`presentation/bloc/device_info/`): `load()`; state `loadingState`, `deviceInfo`, `error`. Provided app-wide in `lib/app/global_bloc_config.dart`.
- `DeviceInfoEntity` (`domain/entity/`): `platform` (`android`, `ios`, `macos`, `windows`, `linux` or `web`) and `data`, the plugin's raw map for that platform.
- `GetDeviceInfoUseCase` (DI `@injectable`), `RemoteDeviceInfoRepository` and `RemoteDeviceInfoRepositoryImpl` (DI `@LazySingleton`).

## Depends on

- `device_info_plus`, also used by core's `GalleryPermission`.
- No other module, no native keys, no `.env` keys.

## Setup

Nothing to set up.

## Use

```dart
final info = context.read<DeviceInfoCubit>().state.deviceInfo; // null until loaded
if (info != null && info.platform == 'android') {
  final model = '${info.data['brand']} ${info.data['model']}';
  final sdk = (info.data['version'] as Map?)?['sdkInt'];
}
```

The keys are the plugin's: `AndroidDeviceInfo` (`brand`, `model`, `version.release`, `version.sdkInt`, ...), `IosDeviceInfo` (`name`, `model`, `systemVersion`, ...), and so on. `lib/modules/settings/utils/helper/feedback_email_helper.dart` formats each platform.

## Remove

1. Delete `lib/modules/device_info/`.
2. `lib/app/global_bloc_config.dart`: remove `import 'package:flutter_starter/modules/device_info/device_info.dart';` and the `BlocProvider<DeviceInfoCubit>(...)` block (`create: (_) => DeviceInfoCubit()..load()`).
3. `lib/modules/settings/utils/helper/feedback_email_helper.dart`: remove the `device_info` import, the `_formatDeviceInfo(...)` line in `sendEmail` and the `_formatDeviceInfo` method.
4. Keep `device_info_plus` in `pubspec.yaml`: `lib/core/utils/helpers/permission/gallery_permission.dart` uses it.
5. `dart run build_runner build` (drops `RemoteDeviceInfoRepositoryImpl` and `GetDeviceInfoUseCase` from `lib/core/di/injection.config.dart`), then `flutter analyze`.

## Hidden details

- Loaded once at start-up (`lazy: false`) and never again: the values don't change while the app runs. Until then `deviceInfo` is null, so readers must cope (the report email says `Device: Unknown Platform`).
- A failure stays in the state (`loadingState` failure, `error`) and shows nothing: this is diagnostics and must never get in the user's way.
- `platform` is the lowercased `defaultTargetPlatform` name (`ios`, not `iOS`), or `web`. Other platforms fall back to the plugin's generic `deviceInfo`, which may fail.
- `data` is the plugin's raw map with top-level nulls turned into `''`; nested maps (Android's `version`) keep theirs. Keys change between platforms and plugin versions, so read them defensively.
- On the web the data comes from `webBrowserInfo` (`browserName`, `userAgent`, ...).
- The map holds identifiers too (iOS `identifierForVendor`, for one). Check your privacy policy before you send it anywhere.
