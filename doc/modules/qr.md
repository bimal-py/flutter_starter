# QR

A dialog that shows a QR code (the app name above it, "Scan to download" below) with "Save" to the photo gallery and "Share" through the system share sheet. The starter uses it to share the app's download link from Home and Settings. Keep it if you want that, or as a base for any QR you show.

## What it provides

- `QrPopup` (`presentation/widgets/`): `QrPopup.show(context, qrData:, fileName:)` opens it in a `Dialog`; you can also put `QrPopup(qrData:, fileName:)` in your own dialog or page. It provides the save cubit and the listener that shows the popup loader and the toasts.
- `QrPopupContent` (title, close button, card, actions), `QrCodeCard` (the part that is saved and shared), `QrPopupActions` (the Save and Share buttons).
- `QrSaveCubit` (`presentation/bloc/qr_save/`): `save(bytes:, fileName:)` with `loadingState` and `error`.
- `QrCaptureService` (`utils/helper/`): `captureQrImage(qrKey:)` renders a `RepaintBoundary` to PNG bytes; `saveQrToGallery(imageBytes:, fileName:)`.
- `QrStrings`, `QrError`, and `QrColors` (the fixed black-on-white of the code).

## Depends on

- Packages only this module uses: `qr_flutter`, `image_gallery_saver_plus`. Shared: `share_plus` (through core's `ShareService`), `permission_handler` and `device_info_plus` (through `GalleryPermission`), `lucide_icons_flutter` (icons).
- Core: `GalleryPermission`, `ShareService`, `CustomSnackbar`, `AppConstants.appName`; common: the popup loader.
- Native keys (all present): `NSPhotoLibraryAddUsageDescription` in `ios/Runner/Info.plist`, `PERMISSION_PHOTOS=1` in the `post_install` block of `ios/Podfile`, and `android.permission.WRITE_EXTERNAL_STORAGE` with `android:maxSdkVersion="28"` in `android/app/src/main/AndroidManifest.xml`.
- No other module, no DI classes, no `.env` keys.

## Setup

1. Set what the starter's QR encodes and names: `AppUrls.appDownload` (`lib/core/utils/constants/app_urls.dart`) and `AppConstants.appAndroidPackageId` (`lib/core/utils/constants/app_constants.dart`), which the callers pass as `fileName`.
2. Reword `NSPhotoLibraryAddUsageDescription` in `ios/Runner/Info.plist` for your app.

## Use

```dart
QrPopup.show(
  context,
  qrData: AppUrls.appDownload,
  fileName: AppConstants.appAndroidPackageId,
);
```

The copy is in `utils/constants/qr_strings.dart`: the title, "Scan to download", the share text (`Download <app name>: <qrData>`) and subject (`<app name> QR`). Change them there for another kind of QR.

## Remove

1. Delete `lib/modules/qr/`.
2. `lib/modules/home/presentation/views/home_screen.dart`: remove `import 'package:flutter_starter/modules/qr/qr.dart';` and the `HomeFeatureCard` whose `onTap` calls `QrPopup.show` (and `HomeStrings.shareViaQr`).
3. `lib/modules/settings/presentation/widgets/settings_share_feedback_group.dart`: remove `import 'package:flutter_starter/modules/qr/qr.dart';` and the `SettingsTile` whose `onTap` calls `QrPopup.show`, with the `Divider` after it (and `SettingsStrings.shareQr` / `shareQrSubtitle`).
4. Check nothing else calls it: `grep -rn "QrPopup\|modules/qr/" lib`.
5. `pubspec.yaml`: remove `qr_flutter` and `image_gallery_saver_plus` (and the `# QR` comment).
6. Optional, if nothing else saves images to the gallery: `WRITE_EXTERNAL_STORAGE` and its comment in `AndroidManifest.xml`. Remove `NSPhotoLibraryAddUsageDescription` from `Info.plist` only together with `PERMISSION_PHOTOS=1` in `ios/Podfile`, and only if nothing else asks for photo permissions (see [permissions](../core/permissions.md)).
7. `dart run build_runner build`, then `flutter analyze`.

## Hidden details

- Save asks for permission first (`GalleryPermission.ensure`: iOS `photosAddOnly`, Android 9 and lower `storage`, Android 10+ nothing), then captures the card, then shows the popup loader ("Saving…") while `QrSaveCubit` writes it. The prompt comes before the loader because the loader would cover it. A user who refuses even after the settings dialog gets no further message.
- Share has no loader: the share sheet is the feedback. A guard in `QrPopupContent` drops a second tap while a permission prompt, a capture or the share sheet is on its way.
- The capture is `QrCodeCard`'s `RepaintBoundary` at pixel ratio 3, as PNG, on an opaque box in the dialog's color (`dialogTheme.backgroundColor`, else `surfaceContainerHigh`). The app name and caption keep their theme colors, so a capture made in dark mode is dark.
- `image_gallery_saver_plus` re-encodes the PNG as JPEG (quality 100) on both platforms; the opaque box is what keeps the area around the code from turning black. Android saves it under the name `qr_<fileName>.png`; iOS ignores the name. The shared file is the PNG as captured, `<fileName>.png` in the temporary directory.
- The code is black on white in both themes (`QrColors`): cameras read dark-on-light codes most reliably. The white padding around it is the quiet zone scanners need.
- Error correction is level L (about 7% of the code can be damaged). Keep the encoded text short, and don't lay a logo over the code without raising the level in `QrCodeCard`.
- Sizes go through flutter_scale_kit (`200.r` for the code by default, `size` on `QrCodeCard`), so the code and the saved image scale with the screen.
- On iPad the share sheet anchors to the popup content (`ShareService` needs a context for its position).
