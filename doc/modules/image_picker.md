# Image picker

Picks photos from the camera or the gallery, one or several, through a bottom sheet and a cubit. Every picked photo is re-encoded, normally as a smaller JPEG, before you get its path. Keep it when users attach or upload photos.

## What it provides

- `ImagePickerCubit` (`presentation/bloc/image_picker/`): `captureImage()`, `pickImage()`, `pickMultipleImages()`, `removeImage(path)`, `clearAll()`, `setSingleImagePicker(single:)`. State: `images` (a list of `PickedImageEntity`, each a file `path`), `error`, `isSingleImagePicker`, `isEmpty`, `hasImages`.
- `ImagePickerDialog` (`presentation/widgets/`): the "Capture an image" / "Choose from device" bottom sheet, opened with `ImagePickerDialog.show(context, cubit:, shouldPickMultipleImages:)`. `ImagePickerSourceTile` is one of its rows.
- `ImagePickerHelper` (`utils/helper/`): `captureFromCamera()`, `pickFromGallery()`, `pickMultipleFromGallery()`, already compressed. Use it when a cubit is too much.
- `ImageCompressor`: `compressXFile`, `compressXFileToBytes`, and `maybeCompressLargeFile` for files that didn't come through the picker (only those over 2 MB are touched).
- `ImagePickerStrings` (sheet copy) and `ImagePickerError` (failure copy).

## Depends on

- Packages only this module uses: `flutter_image_compress`, `image`, `path`. `image_picker` is also imported by the settings module's theme playground (`lib/modules/settings/presentation/views/theme_playground_screen.dart`). Shared: `path_provider`.
- iOS, `ios/Runner/Info.plist`: `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`. Both are there; reword them for your app.
- Android: nothing for the gallery (Android 13+ uses the system photo picker). `android/app/src/main/AndroidManifest.xml` declares `android.permission.CAMERA` and the `android.hardware.camera` feature, which changes how the camera is opened (see Hidden details).
- No other module, no DI classes, no `.env` keys.

## Setup

1. Reword `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist` to say what your app does with the photos.
2. Provide an `ImagePickerCubit` on the screen that needs photos (see Use).

## Use

```dart
// The screen owns the cubit, so the picks outlive the sheet.
BlocProvider(
  create: (_) => ImagePickerCubit()..setSingleImagePicker(single: false),
  child: const AttachmentsView(),
);

// In AttachmentsView
OutlinedButton(
  onPressed: () => ImagePickerDialog.show(
    context,
    cubit: context.read<ImagePickerCubit>(),
    shouldPickMultipleImages: true,
  ),
  child: const Text('Add photos'),
);

BlocBuilder<ImagePickerCubit, ImagePickerState>(
  builder: (context, state) => Wrap(
    children: [
      for (final image in state.images)
        Image.file(File(image.path), width: 96.r, height: 96.r),
    ],
  ),
);
```

Without the sheet:

```dart
final file = await ImagePickerHelper().pickFromGallery(); // null: cancelled
```

## Remove

1. Delete `lib/modules/image_picker/`. Nothing else in `lib/` imports it.
2. `pubspec.yaml`: remove `flutter_image_compress`, `image` and `path`. Remove `image_picker` too unless the settings theme playground still imports it (`grep -rn "package:image_picker" lib`).
3. Optional, if nothing else needs them: `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist`, and `android.permission.CAMERA` with the two camera `uses-feature` lines in `AndroidManifest.xml`.
4. `dart run build_runner build`, then `flutter analyze`.

## Hidden details

- Every pick goes through `ImageCompressor.compressXFile`: `flutter_image_compress` at quality 55 into the temporary directory as `<name>_compressed.jpg`. PNG and WebP become JPEG too, so transparency is lost. The plugin's default `minWidth` 1920 / `minHeight` 1080 also scale big photos down (a 4000×2000 photo comes out 2160×1080), EXIF (location included) is dropped, and the orientation is applied to the pixels.
- Formats: `.jpg`, `.jpeg`, `.png`, `.heic`, `.webp`. Any other format, or a failed conversion, keeps the original file rather than failing the pick.
- HEIC: iOS converts it natively. Android decodes it with `dart:ui` and writes PNG bytes, uncompressed, to a file named `<name>_converted.jpg`.
- `maybeCompressLargeFile` re-encodes non-JPEG files with the `image` package (quality 85) before compressing at 55. That package can't read HEIC, so a large HEIC throws `ImagePickerError.decodingFailed` there.
- The output files stay in the temporary directory; the module never deletes them, the OS may.
- Without `cubit:`, `ImagePickerDialog.show` makes a cubit of its own that is closed with the sheet, so nobody can read the pick. Always pass the screen's cubit.
- The sheet closes itself when the pick finishes, cancelled or not.
- Cancelling sets `state.error` (`ImagePickerError.noImagePicked` and friends); the module shows nothing, so decide in your screen whether that deserves a message. Any later emit clears `error`.
- Multi mode appends and skips paths already in the list; single mode (`setSingleImagePicker(single: true)`) replaces the list. `ImagePickerDialog.show` with its own cubit sets single mode from `shouldPickMultipleImages`.
- Because `CAMERA` is declared in the manifest, Android requires it to be granted before the camera opens: image_picker asks for it itself, with no settings fallback. A denial ends up as `state.error` ("Something went wrong"). For a friendlier flow, run `PermissionFlow.ensure(context, permission: Permission.camera, ...)` first (see [permissions](../core/permissions.md)).
- `<uses-feature android:name="android.hardware.camera"/>` has no `android:required="false"`, so Google Play hides the app from devices without a camera.
- Android may kill the app while the camera is open on low memory; the photo then comes back through `ImagePicker().retrieveLostData()`, which this module doesn't call.
