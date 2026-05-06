import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/qr/data/qr_capture_service.dart';
import 'package:flutter_starter/modules/qr/presentation/widgets/qr_image_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom-sheet style dialog showing the app's download QR with
/// "Save to gallery" and "Share" actions.
class QrPopup extends StatefulWidget {
  const QrPopup({super.key, required this.qrData, required this.fileName});

  final String qrData;
  final String fileName;

  static Future<void> show(
    BuildContext context, {
    required String qrData,
    required String fileName,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: QrPopup(qrData: qrData, fileName: fileName),
      ),
    );
  }

  @override
  State<QrPopup> createState() => _QrPopupState();
}

class _QrPopupState extends State<QrPopup> {
  final GlobalKey _qrKey = GlobalKey();
  final QrCaptureService _capture = const QrCaptureService();

  bool _saving = false;
  bool _sharing = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final hasPermission =
          await PermissionHelper.requestGalleryPermission(context);
      if (!hasPermission) return;

      final bytes = await _capture.captureQrImage(qrKey: _qrKey);
      if (bytes == null) throw Exception('Failed to render QR image');

      final ok = await _capture.saveQrToGallery(
        imageBytes: bytes,
        fileName: widget.fileName,
      );

      if (!mounted) return;
      if (ok) {
        context.showSuccessToast('QR saved to gallery');
      } else {
        context.showErrorToast('Failed to save QR');
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorToast('Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    try {
      final bytes = await _capture.captureQrImage(qrKey: _qrKey);
      if (bytes == null) throw Exception('Failed to render QR image');
      if (!mounted) return;

      await ShareService.shareImageBytes(
        context: context,
        bytes: bytes,
        fileName: '${widget.fileName}.png',
        text: 'Download ${AppConstants.appName}: ${widget.qrData}',
        subject: '${AppConstants.appName} QR',
      );
    } catch (e) {
      if (!mounted) return;
      context.showErrorToast('Share failed: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Share app QR',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            QrImageWidget(qrKey: _qrKey, qrData: widget.qrData),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.download),
                    label: Text(_saving ? 'Saving…' : 'Save'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _sharing ? null : _share,
                    icon: _sharing
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.share2),
                    label: Text(_sharing ? 'Sharing…' : 'Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
