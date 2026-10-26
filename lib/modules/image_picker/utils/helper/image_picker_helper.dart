import 'package:flutter_starter/modules/image_picker/utils/helper/helper.dart';
import 'package:image_picker/image_picker.dart';

/// Thin wrapper around `image_picker` that runs every returned [XFile]
/// through [ImageCompressor]. The cubit uses it; call it directly when a
/// cubit is overkill.
class ImagePickerHelper {
  ImagePickerHelper({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

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
      compressed.add(await _compressOrPassThrough(f));
    }
    return compressed;
  }

  /// Unsupported formats and failed conversions (HEIC on Android goes through
  /// dart:ui) keep the original file rather than failing the pick.
  Future<XFile> _compressOrPassThrough(XFile file) async {
    try {
      return await ImageCompressor.compressXFile(file) ?? file;
    } catch (_) {
      return file;
    }
  }
}
