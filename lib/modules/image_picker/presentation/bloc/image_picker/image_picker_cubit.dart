import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/image_picker/domain/domain.dart';
import 'package:flutter_starter/modules/image_picker/utils/utils.dart';

part 'image_picker_state.dart';

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
      final next = _merge(state.images, [PickedImageEntity(path: file.path)]);
      emit(state.copyWith(images: next, error: null));
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
      final next = _merge(state.images, [PickedImageEntity(path: file.path)]);
      emit(state.copyWith(images: next, error: null));
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
      final incoming = files
          .map((f) => PickedImageEntity(path: f.path))
          .toList();
      emit(state.copyWith(images: _merge(state.images, incoming), error: null));
    } catch (error) {
      emit(state.copyWith(error: AppErrorHandler.getErrorMessage(error)));
    }
  }

  void removeImage(String path) {
    final next = state.images.where((e) => e.path != path).toList();
    emit(state.copyWith(images: next));
  }

  void clearAll() => emit(state.copyWith(images: const []));

  List<PickedImageEntity> _merge(
    List<PickedImageEntity> existing,
    List<PickedImageEntity> incoming,
  ) {
    if (state.isSingleImagePicker) return incoming;
    final paths = existing.map((e) => e.path).toSet();
    return [
      ...existing,
      for (final e in incoming)
        if (paths.add(e.path)) e,
    ];
  }
}
