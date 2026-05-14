import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/image_picker/presentation/bloc/image_picker/image_picker_cubit.dart';

/// Bottom-sheet picker with "Capture" / "Choose from device". Closes itself
/// once the cubit finishes — observe [ImagePickerCubit] for the picked files.
class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({
    super.key,
    this.shouldPickMultipleImages = false,
  });

  final bool shouldPickMultipleImages;

  /// Pass an existing [cubit] (recommended, keeps caller state in sync) or
  /// omit it to let the sheet create a transient one for a single shot.
  static Future<void> show(
    BuildContext context, {
    ImagePickerCubit? cubit,
    bool shouldPickMultipleImages = false,
  }) {
    if (cubit != null) {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ImagePickerSheet(
            shouldPickMultipleImages: shouldPickMultipleImages,
          ),
        ),
      );
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<ImagePickerCubit>(
        create: (_) => ImagePickerCubit()
          ..setSingleImagePicker(single: !shouldPickMultipleImages),
        child: ImagePickerSheet(
          shouldPickMultipleImages: shouldPickMultipleImages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () => _runAndClose(
                sheetContext,
                () => sheetContext.read<ImagePickerCubit>().captureImage(),
              ),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              title: const Text('Capture an image'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () => _runAndClose(
                sheetContext,
                () => shouldPickMultipleImages
                    ? sheetContext
                          .read<ImagePickerCubit>()
                          .pickMultipleImages()
                    : sheetContext.read<ImagePickerCubit>().pickImage(),
              ),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.create_new_folder_outlined,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              title: const Text('Choose from device'),
              trailing: const Icon(Icons.chevron_right),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _runAndClose(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final nav = Navigator.of(context);
    await action();
    if (nav.mounted) nav.pop();
  }
}
