part of 'image_picker_cubit.dart';

class ImagePickerState extends Equatable {
  const ImagePickerState({
    this.images = const [],
    this.error,
    this.isSingleImagePicker = false,
  });

  final List<PickedImageEntity> images;
  final String? error;
  final bool isSingleImagePicker;

  bool get isEmpty => images.isEmpty;
  bool get hasImages => images.isNotEmpty;

  ImagePickerState copyWith({
    List<PickedImageEntity>? images,
    String? error,
    bool? isSingleImagePicker,
  }) => ImagePickerState(
    images: images ?? this.images,
    error: error,
    isSingleImagePicker: isSingleImagePicker ?? this.isSingleImagePicker,
  );

  @override
  List<Object?> get props => [images, error, isSingleImagePicker];
}
