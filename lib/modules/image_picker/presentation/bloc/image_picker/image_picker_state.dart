part of 'image_picker_cubit.dart';

class ImagePickerState extends Equatable {
  const ImagePickerState({
    this.files = const [],
    this.error,
    this.isSingleImagePicker = false,
  });

  final List<File> files;
  final String? error;
  final bool isSingleImagePicker;

  bool get isEmpty => files.isEmpty;
  bool get hasFiles => files.isNotEmpty;

  ImagePickerState copyWith({
    List<File>? files,
    String? error,
    bool? isSingleImagePicker,
  }) => ImagePickerState(
    files: files ?? this.files,
    error: error,
    isSingleImagePicker: isSingleImagePicker ?? this.isSingleImagePicker,
  );

  @override
  List<Object?> get props => [files, error, isSingleImagePicker];
}
