import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/qr/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/qr/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/qr/utils/utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Title, [QrCodeCard] and the Save / Share row of [QrPopup]. Owns the
/// capture key, so both actions render the card the user sees.
class QrPopupContent extends StatefulWidget {
  const QrPopupContent({
    super.key,
    required this.qrData,
    required this.fileName,
  });

  final String qrData;
  final String fileName;

  @override
  State<QrPopupContent> createState() => _QrPopupContentState();
}

class _QrPopupContentState extends State<QrPopupContent> {
  final GlobalKey _qrKey = GlobalKey();
  final QrCaptureService _capture = const QrCaptureService();

  // Blocks a second tap while a permission prompt, the capture or the share
  // sheet is still on its way.
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    _busy = true;
    try {
      await action();
    } catch (error) {
      CustomSnackbar.show(
        type: ToastType.error,
        message: AppErrorHandler.getErrorMessage(error),
      );
    } finally {
      _busy = false;
    }
  }

  // The permission prompt comes before the popup loader, which would
  // otherwise cover it.
  Future<void> _save() async {
    final cubit = context.read<QrSaveCubit>();
    if (!await GalleryPermission.ensure(context)) return;
    final bytes = await _capture.captureQrImage(qrKey: _qrKey);
    if (bytes == null) throw const AppException(message: QrError.renderFailed);
    await cubit.save(bytes: bytes, fileName: widget.fileName);
  }

  Future<void> _share() async {
    final bytes = await _capture.captureQrImage(qrKey: _qrKey);
    if (bytes == null) throw const AppException(message: QrError.renderFailed);
    if (!mounted) return;
    await ShareService.shareImageBytes(
      context: context,
      bytes: bytes,
      fileName: '${widget.fileName}.png',
      text: QrStrings.shareText(widget.qrData),
      subject: QrStrings.shareSubject,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  QrStrings.title,
                  style: context.textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x),
              ),
            ],
          ),
          8.verticalSpace,
          QrCodeCard(qrKey: _qrKey, qrData: widget.qrData),
          20.verticalSpace,
          QrPopupActions(
            onSave: () => _run(_save),
            onShare: () => _run(_share),
          ),
        ],
      ),
    );
  }
}
