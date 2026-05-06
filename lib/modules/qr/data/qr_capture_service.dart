import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

/// Captures a QR widget (wrapped in a [RepaintBoundary]) into PNG bytes and
/// can save those bytes to the device gallery. Sharing is handled separately
/// via `ShareService.shareImageBytes`.
class QrCaptureService {
  const QrCaptureService();

  Future<Uint8List?> captureQrImage({required GlobalKey qrKey}) async {
    try {
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Returns true on success.
  Future<bool> saveQrToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final result = await ImageGallerySaverPlus.saveImage(
      imageBytes,
      name: 'qr_$fileName.png',
      quality: 100,
    );
    if (result is Map) return result['isSuccess'] == true;
    return false;
  }
}
