import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/errors/error_handler.dart';
import 'package:flutter_starter/modules/image_picker/utils/helper/image_picker_helper.dart';

part 'image_picker_state.dart';

/// Holds a `List<File>` populated by camera capture or gallery picks. Defaults
/// to multi-pick (appends de-duplicated by path). [setSingleImagePicker] flips
/// to replace-mode for the next pick.
class ImagePickerCubit extends Cubit<ImagePickerState> {
  ImagePickerCubit({ImagePickerHelperLib? helper})
    : _helper = helper ?? ImagePickerHelperLib(),
      super(const ImagePickerState());

  final ImagePickerHelperLib _helper;

  void setSingleImagePicker({required bool single}) =>
      emit(state.copyWith(isSingleImagePicker: single));

  Future<void> captureImage() async {
    try {
      final file = await _helper.captureFromCamera();
      if (file == null) {
        return emit(state.copyWith(error: 'No image captured.'));
      }
      final next = _merge(state.files, [File(file.path)]);
      emit(state.copyWith(files: next, error: null));
    } catch (error) {
      emit(state.copyWith(error: AppErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> pickImage() async {
    try {
      final file = await _helper.pickFromGallery();
      if (file == null) {
        return emit(state.copyWith(error: 'No image picked.'));
      }
      final next = _merge(state.files, [File(file.path)]);
      emit(state.copyWith(files: next, error: null));
    } catch (error) {
      emit(state.copyWith(error: AppErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> pickMultipleImages() async {
    try {
      final files = await _helper.pickMultipleFromGallery();
      if (files.isEmpty) {
        return emit(state.copyWith(error: 'No images picked.'));
      }
      final incoming = files.map((f) => File(f.path)).toList();
      emit(state.copyWith(files: _merge(state.files, incoming), error: null));
    } catch (error) {
      emit(state.copyWith(error: AppErrorHandler.getErrorMessage(error)));
    }
  }

  void removeFile(String path) {
    final next = state.files.where((f) => f.path != path).toList();
    emit(state.copyWith(files: next));
  }

  void clearAll() => emit(state.copyWith(files: const []));

  List<File> _merge(List<File> existing, List<File> incoming) {
    if (state.isSingleImagePicker) return incoming;
    final paths = existing.map((f) => f.path).toSet();
    return [
      ...existing,
      for (final f in incoming)
        if (paths.add(f.path)) f,
    ];
  }
}
