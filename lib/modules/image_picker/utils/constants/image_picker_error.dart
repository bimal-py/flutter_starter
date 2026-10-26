class ImagePickerError {
  ImagePickerError._();

  // Set on ImagePickerState.error when the user backs out of the picker.
  static const String noImageCaptured = 'No image captured.';
  static const String noImagePicked = 'No image picked.';
  static const String noImagesPicked = 'No images picked.';

  // Thrown by ImageCompressor.
  static String unsupportedFormat(String extension) =>
      'Unsupported image format: $extension';
  static const String heicConversionFailed = 'HEIC conversion failed';
  static const String compressionFailed = 'Image compression failed';
  static const String decodingFailed = 'Image decoding failed';
}
