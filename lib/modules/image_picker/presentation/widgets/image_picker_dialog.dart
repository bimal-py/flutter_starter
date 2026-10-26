import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/image_picker/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/image_picker/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/image_picker/utils/constants/constants.dart';

/// Bottom sheet with "Capture an image" / "Choose from device". Closes itself
/// once the pick finishes; read the picked files from [ImagePickerCubit].
class ImagePickerDialog extends StatelessWidget {
  const ImagePickerDialog({super.key, this.shouldPickMultipleImages = false});

  final bool shouldPickMultipleImages;

  /// Pass the screen's [cubit] to keep the picked files there. Without one the
  /// sheet makes its own, and the pick is gone when the sheet closes.
  static Future<void> show(
    BuildContext context, {
    ImagePickerCubit? cubit,
    bool shouldPickMultipleImages = false,
  }) {
    final sheet = ImagePickerDialog(
      shouldPickMultipleImages: shouldPickMultipleImages,
    );
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => cubit != null
          ? BlocProvider.value(value: cubit, child: sheet)
          : BlocProvider(
              create: (_) =>
                  ImagePickerCubit()
                    ..setSingleImagePicker(single: !shouldPickMultipleImages),
              child: sheet,
            ),
    );
  }

  Future<void> _pickAndClose(
    BuildContext context,
    Future<void> Function(ImagePickerCubit cubit) pick,
  ) async {
    final navigator = Navigator.of(context);
    await pick(context.read<ImagePickerCubit>());
    if (navigator.mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImagePickerSourceTile(
            icon: Icons.camera_alt_outlined,
            label: ImagePickerStrings.captureImage,
            onTap: () =>
                _pickAndClose(context, (cubit) => cubit.captureImage()),
          ),
          ImagePickerSourceTile(
            icon: Icons.create_new_folder_outlined,
            label: ImagePickerStrings.chooseFromDevice,
            onTap: () => _pickAndClose(
              context,
              (cubit) => shouldPickMultipleImages
                  ? cubit.pickMultipleImages()
                  : cubit.pickImage(),
            ),
          ),
          24.verticalSpace,
        ],
      ),
    );
  }
}
