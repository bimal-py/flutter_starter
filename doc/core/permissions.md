# Permissions

`lib/core/utils/helpers/permission/` wraps permission_handler in one flow: ask the system once, and after a denial offer to open the app's settings.
The rule: ask when the user starts the action that needs it, or on an onboarding step that explains why. Never on app open.

## Where it lives

```
lib/core/utils/helpers/permission/
├── permission_flow.dart          PermissionFlow.ensure(context, permission:, settingsDialogTitle:, settingsDialogMessage:)
├── notification_permission.dart  NotificationPermission.ensure(context), NotificationPermission.isGranted
└── gallery_permission.dart       GalleryPermission.ensure(context): save images to the photo library
android/app/src/main/AndroidManifest.xml   <uses-permission> entries
ios/Runner/Info.plist                      NS…UsageDescription texts
ios/Podfile                                PERMISSION_* macros in post_install
```

`PermissionFlow.ensure` returns `true` when the feature may go ahead:

1. Granted, limited or provisional: `true` at once.
2. Never asked (`isDenied`): the system prompt. Granted: `true`.
3. Still denied, or permanently denied: a `ConfirmationDialog` with "Open settings" and "Not now". "Not now" returns `false`.
4. "Open settings": `openAppSettings()`, then `ensure` waits until the app is in front again and reads the status once more (see Hidden details).

## How to use

```dart
// Notifications: FCM and local notifications share the OS permission.
final granted = await NotificationPermission.ensure(context);

// Before saving an image (the qr module does this).
if (!await GalleryPermission.ensure(context)) return;

// Any other permission.
final canScan = await PermissionFlow.ensure(
  context,
  permission: Permission.camera,
  settingsDialogTitle: ScanStrings.cameraDeniedTitle,
  settingsDialogMessage: ScanStrings.cameraDeniedMessage,
);
```

With the fcm module, prefer `FcmService.instance.ensureNotificationPermission(context)`: it runs `NotificationPermission.ensure` and records that the user was asked. It returns `false` without asking while `FIREBASE_ENABLED` is off, so an app with only local notifications calls `NotificationPermission.ensure` itself. See the [fcm module](../modules/fcm.md).

What each permission needs natively. Entries marked "(set)" are already in the starter.

| Permission | AndroidManifest.xml | Info.plist | Podfile macro |
|---|---|---|---|
| `notification` | `POST_NOTIFICATIONS` (set) | none | `PERMISSION_NOTIFICATIONS=1` (set) |
| `photosAddOnly` | `WRITE_EXTERNAL_STORAGE`, max SDK 28 (set) | `NSPhotoLibraryAddUsageDescription` (set) | `PERMISSION_PHOTOS=1` (set) |
| `photos` | `READ_MEDIA_IMAGES` (Android 13+; older: `storage`) | `NSPhotoLibraryUsageDescription` (set) | `PERMISSION_PHOTOS=1` (set) |
| `camera` | `CAMERA` (set) | `NSCameraUsageDescription` (set) | `PERMISSION_CAMERA=1` (set) |
| `microphone` | `RECORD_AUDIO` | `NSMicrophoneUsageDescription` | `PERMISSION_MICROPHONE=1` |
| `locationWhenInUse` | `ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION` | `NSLocationWhenInUseUsageDescription` | `PERMISSION_LOCATION_WHENINUSE=1` |

Every other permission and its keys: the permission_handler setup page on pub.dev.

## How to change / extend

**Add a permission**

1. Find its `Permission` value and native keys (table above).
2. Android: add `<uses-permission android:name="android.permission.X"/>` to `android/app/src/main/AndroidManifest.xml`.
3. iOS: add the `NS…UsageDescription` key to `ios/Runner/Info.plist`, with one sentence that says what the app does with it.
4. iOS: add `'PERMISSION_X=1',` to the `GCC_PREPROCESSOR_DEFINITIONS` list in `ios/Podfile`, then `cd ios && pod install`.
5. Put the settings-dialog title and message in the feature's `<feature>_strings.dart`.
6. Call `PermissionFlow.ensure` right before the action, or wrap it like `NotificationPermission` does.

**Remove a permission**: delete its macro, its Info.plist key and its manifest entry together, and drop the wrapper if nothing calls it.

**When to ask**

- At the moment of use: the tap on "Save to gallery", "Scan", "Turn on reminders".
- Or on an onboarding page that explains the benefit first and has a "Not now".
- Not at launch: a prompt with no context gets denied, and iOS shows its prompt only once per permission. The starter asks for nothing at launch except App Tracking Transparency, which the mobile_ads module needs before personalised ads.

## Hidden details

- After "Open settings", `ensure` waits for the next resume (an `AppLifecycleListener`), because `openAppSettings()` returns as soon as Settings opens. If Settings can't open, it returns `false` at once. On iOS a changed permission restarts the app, so the waiting call never returns; the new process reads the new status.
- iOS ends the app when the user changes one of its permissions in Settings; it starts fresh when they come back.
- Without its Podfile macro, iOS never prompts: the status reads `denied` and a request returns `permanentlyDenied`, so the flow goes straight to the settings dialog, and Settings has no switch for it.
- Each macro compiles code that uses that API. App Store Connect rejects an upload that uses an API without its usage description (ITMS-90683): add the macro and the key together.
- In permission_handler_apple 9.6.4 `photosAddOnly` is turned on by `PERMISSION_PHOTOS`. The `PERMISSION_PHOTOS_ADD_ONLY` define exists but is never read.
- `GalleryPermission`: iOS asks for `photosAddOnly` (limited counts as granted), Android 9 and lower asks for `storage`, Android 10 and up needs nothing and returns `true`.
- Android 12 and lower grants notifications at install. On 13 and up, the first request shows the prompt.
- image_picker asks for the camera itself (because `CAMERA` is in the manifest) but has no settings fallback. Run `PermissionFlow.ensure(permission: Permission.camera, ...)` first if you want one. See the [image_picker module](../modules/image_picker.md).
- The camera `<uses-feature>` entries in the manifest say `android:required="false"`, so Google Play still offers the app to devices without a camera. On those, the camera source fails; offer the gallery too.
- The usage texts in Info.plist are short and neutral. Name your app's real reasons before release: App Review reads them.
- The two wrappers' dialog texts are English literals in the wrapper files.
- Local notifications start without prompting on iOS (`requestAlertPermission: false` and friends), so nothing asks before you call `ensure`.
