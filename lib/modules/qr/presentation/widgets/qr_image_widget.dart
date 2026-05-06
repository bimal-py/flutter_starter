import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The QR itself, wrapped in a [RepaintBoundary] so it can be captured
/// into image bytes for save / share.
class QrImageWidget extends StatelessWidget {
  const QrImageWidget({
    super.key,
    required this.qrKey,
    required this.qrData,
    this.size = 200,
  });

  final GlobalKey qrKey;
  final String qrData;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      key: qrKey,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: size.r,
              height: size.r,
              child: QrImageView(
                data: qrData,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Scan to download',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
