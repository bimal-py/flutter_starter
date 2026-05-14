import 'package:flutter_starter/modules/image_picker/utils/helper/image_compressor.dart';
import 'package:image_picker/image_picker.dart';

/// Thin wrapper around `image_picker` that runs every returned [XFile]
/// through [ImageCompressor]. Used by [ImagePickerCubit]; safe to call
/// directly when a cubit is overkill.
class ImagePickerHelperLib {
  ImagePickerHelperLib({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> captureFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return null;
    return _compressOrPassThrough(file);
  }

  Future<XFile?> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    return _compressOrPassThrough(file);
  }

  Future<List<XFile>> pickMultipleFromGallery() async {
    final files = await _picker.pickMultiImage();
    final compressed = <XFile>[];
    for (final f in files) {
      final out = await _compressOrPassThrough(f);
      if (out != null) compressed.add(out);
    }
    return compressed;
  }

  /// Some formats (HEIC on Android) round-trip through dart:ui and can fail;
  /// in those cases we'd rather return the original than throw.
  Future<XFile?> _compressOrPassThrough(XFile file) async {
    try {
      final compressed = await ImageCompressor.compressXFile(file);
      return compressed ?? file;
    } on UnsupportedError {
      return file;
    } catch (_) {
      return file;
    }
  }
}
