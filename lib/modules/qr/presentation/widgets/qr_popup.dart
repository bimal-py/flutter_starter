import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/qr/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/qr/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/qr/utils/constants/constants.dart';

/// A QR of [qrData] with "Save to gallery" and "Share" actions; [fileName]
/// names the saved and shared image. Open it with [QrPopup.show], or embed it
/// in your own dialog or page.
class QrPopup extends StatelessWidget {
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
      builder: (_) => Dialog(
        // Surface, elevation and shape come from the Dialog theme.
        insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterWide),
        child: QrPopup(qrData: qrData, fileName: fileName),
      ),
    );
  }

  void _onSaveState(BuildContext context, QrSaveState state) {
    switch (state.loadingState) {
      case AppLoadingState.loading:
        context.showPopupLoading(message: QrStrings.saving);
      case AppLoadingState.success:
        context.hidePopupLoading();
        CustomSnackbar.show(type: ToastType.success, message: QrStrings.saved);
      case AppLoadingState.failure:
        context.hidePopupLoading();
        CustomSnackbar.show(
          type: ToastType.error,
          message: state.error ?? AppErrorStrings.somethingWentWrong,
        );
      case AppLoadingState.initial:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrSaveCubit(),
      child: BlocListener<QrSaveCubit, QrSaveState>(
        listenWhen: (previous, current) =>
            previous.loadingState != current.loadingState,
        listener: _onSaveState,
        child: QrPopupContent(qrData: qrData, fileName: fileName),
      ),
    );
  }
}
