import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/qr/utils/utils.dart';

part 'qr_save_state.dart';

/// Saves a rendered QR image to the device gallery.
class QrSaveCubit extends SafeCubit<QrSaveState> {
  QrSaveCubit() : super(const QrSaveState());

  final QrCaptureService _capture = const QrCaptureService();

  Future<void> save({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (state.loadingState.isLoading) return;
    emit(
      state.copyWith(loadingState: AppLoadingState.loading, clearError: true),
    );
    try {
      final saved = await _capture.saveQrToGallery(
        imageBytes: bytes,
        fileName: fileName,
      );
      if (!saved) throw const AppException(message: QrError.saveFailed);
      emit(state.copyWith(loadingState: AppLoadingState.success));
    } catch (error) {
      emit(
        state.copyWith(
          loadingState: AppLoadingState.failure,
          error: AppErrorHandler.getErrorMessage(error),
        ),
      );
    }
  }
}
