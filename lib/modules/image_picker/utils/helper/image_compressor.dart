import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum CompressorOutput { file, bytes }

/// JPG re-encode + HEIC handling for picked images.
class ImageCompressor {
  ImageCompressor._();

  static const List<String> supportedFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.heic',
    '.webp',
  ];

  static const int defaultCompressionQuality = 55;
  static const int jpgEncodeQuality = 85;
  static const int largeFileThresholdBytes = 2 * 1024 * 1024;

  /// Returns null for unsupported formats — caller should keep the original.
  static Future<XFile?> compressXFile(XFile file) async {
    final out = await _processXFile(file, output: CompressorOutput.file);
    return out is XFile ? out : null;
  }

  static Future<Uint8List?> compressXFileToBytes(XFile file) async {
    final out = await _processXFile(file, output: CompressorOutput.bytes);
    return out is Uint8List ? out : null;
  }

  /// Compresses images ≥ [largeFileThresholdBytes]; smaller files + non-images
  /// pass through unchanged.
  static Future<File> maybeCompressLargeFile(File file) async {
    final ext = p.extension(file.path).toLowerCase();
    if (!supportedFormats.contains(ext)) return file;

    final size = await file.length();
    if (size <= largeFileThresholdBytes) return file;

    return _compressLargeFile(file);
  }

  static Future<dynamic> _processXFile(
    XFile file, {
    required CompressorOutput output,
    int quality = defaultCompressionQuality,
  }) async {
    final ext = p.extension(file.path).toLowerCase();
    if (!supportedFormats.contains(ext)) {
      throw UnsupportedError('Unsupported image format: $ext');
    }

    if (ext == '.heic') {
      return _handleHeic(file, quality: quality, output: output);
    }

    if (output == CompressorOutput.bytes) {
      return FlutterImageCompress.compressWithFile(file.path, quality: quality);
    }

    return _compressToJpgFile(file.path, quality);
  }

  static Future<dynamic> _handleHeic(
    XFile file, {
    required int quality,
    required CompressorOutput output,
  }) async {
    // iOS handles HEIC natively. Android has no native decoder so we route
    // through dart:ui (PNG re-encode) instead.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (output == CompressorOutput.bytes) {
        return FlutterImageCompress.compressWithFile(
          file.path,
          quality: quality,
        );
      }
      return _compressToJpgFile(file.path, quality);
    }

    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) throw Exception('HEIC conversion failed');

    if (output == CompressorOutput.bytes) {
      return byteData.buffer.asUint8List();
    }

    final dir = await getTemporaryDirectory();
    final outPath = p.join(
      dir.path,
      '${p.basenameWithoutExtension(file.path)}_converted.jpg',
    );
    final outFile = File(outPath);
    await outFile.writeAsBytes(byteData.buffer.asUint8List());
    return XFile(outFile.path);
  }

  static Future<XFile> _compressToJpgFile(String inputPath, int quality) async {
    final dir = await getTemporaryDirectory();
    final outPath = p.join(
      dir.path,
      '${p.basenameWithoutExtension(inputPath)}_compressed.jpg',
    );
    final result = await FlutterImageCompress.compressAndGetFile(
      inputPath,
      outPath,
      quality: quality,
    );
    if (result == null) throw Exception('Image compression failed');
    return result;
  }

  static Future<File> _compressLargeFile(File file) async {
    final ext = p.extension(file.path).toLowerCase();
    File source = file;
    if (ext != '.jpg' && ext != '.jpeg') {
      source = await _convertToJpg(file);
    }

    final dir = await getTemporaryDirectory();
    final outPath = p.join(
      dir.path,
      '${p.basenameWithoutExtension(file.path)}_compressed.jpg',
    );
    final result = await FlutterImageCompress.compressAndGetFile(
      source.path,
      outPath,
      quality: defaultCompressionQuality,
    );
    if (result == null) throw Exception('Image compression failed');
    return File(result.path);
  }

  static Future<File> _convertToJpg(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Image decoding failed');

    final jpgBytes = img.encodeJpg(decoded, quality: jpgEncodeQuality);
    final dir = await getTemporaryDirectory();
    final outPath = p.join(
      dir.path,
      '${DateTime.now().millisecondsSinceEpoch}_'
      '${p.basenameWithoutExtension(file.path)}_converted.jpg',
    );
    final outFile = File(outPath);
    await outFile.writeAsBytes(jpgBytes, flush: true);
    return outFile;
  }
}
