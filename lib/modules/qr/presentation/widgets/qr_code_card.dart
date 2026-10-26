import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/qr/utils/constants/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The app name, the QR and "Scan to download", inside a [RepaintBoundary]
/// keyed by [qrKey] so the same pixels can be saved or shared.
class QrCodeCard extends StatelessWidget {
  const QrCodeCard({
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
    return RepaintBoundary(
      key: qrKey,
      // Opaque, in the dialog's own color: the gallery re-encodes the PNG
      // as JPEG, which would turn transparent pixels black.
      child: ColoredBox(
        color:
            Theme.of(context).dialogTheme.backgroundColor ??
            context.colorScheme.surfaceContainerHigh,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appName,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            12.verticalSpace,
            // The white tile is the scanner's quiet zone; the dialog around it
            // already gives the elevated surface.
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: QrColors.codeBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SizedBox.square(
                dimension: size.r,
                child: QrImageView(
                  data: qrData,
                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: QrColors.codeForeground,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: QrColors.codeForeground,
                  ),
                  backgroundColor: QrColors.codeBackground,
                ),
              ),
            ),
            12.verticalSpace,
            Text(
              QrStrings.scanToDownload,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
