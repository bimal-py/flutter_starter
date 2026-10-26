import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/theme_playground/theme_playground.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';
import 'package:image_picker/image_picker.dart';

enum _SourceKind { seed, dynamicDevice, fromImage }

/// Seed color, device colors or an image. The selection lives here: it is
/// read from [initialSource] once and then follows the user's taps.
class ThemePlaygroundSourcePicker extends StatefulWidget {
  const ThemePlaygroundSourcePicker({super.key, required this.initialSource});

  final ThemeSource initialSource;

  @override
  State<ThemePlaygroundSourcePicker> createState() =>
      _ThemePlaygroundSourcePickerState();
}

class _ThemePlaygroundSourcePickerState
    extends State<ThemePlaygroundSourcePicker> {
  _SourceKind _kind = _SourceKind.seed;
  Color _seed = AppColors.seed;
  String? _imagePath;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initialSource;
    if (s is SeedOnlySource) {
      _kind = _SourceKind.seed;
      _seed = s.seed;
    } else if (s is DynamicDeviceSource) {
      _kind = _SourceKind.dynamicDevice;
      _seed = s.fallbackSeed;
    } else if (s is FromImageSource) {
      _kind = _SourceKind.fromImage;
      _seed = s.fallbackSeed;
      final ref = s.imageRef;
      if (ref is FileImageRef) _imagePath = ref.path;
    }
  }

  void _onKindSelected(_SourceKind selected) {
    setState(() => _kind = selected);
    final cubit = context.read<ThemeCubit>();
    switch (selected) {
      case _SourceKind.seed:
        cubit.setUserSeed(_seed);
      case _SourceKind.dynamicDevice:
        cubit.applyUserDynamicDevice(fallbackSeed: _seed);
      case _SourceKind.fromImage:
        final path = _imagePath;
        if (path != null) {
          cubit.applyUserImage(FileImageRef(path), fallbackSeed: _seed);
        }
    }
  }

  void _pickSeed(Color color) {
    setState(() => _seed = color);
    context.read<ThemeCubit>().setUserSeed(color);
  }

  Future<void> _pickImage() async {
    if (_picking) return;
    _picking = true;
    // The root navigator outlives this picker, so it can always hide the
    // loader.
    final root = Navigator.of(context, rootNavigator: true);
    context.showPopupLoading(message: SettingsStrings.picking);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 90,
      );
      if (file == null || !mounted) return;
      setState(() => _imagePath = file.path);
      await context.read<ThemeCubit>().applyUserImage(
        FileImageRef(file.path),
        fallbackSeed: _seed,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        type: ToastType.error,
        message: AppErrorHandler.getErrorMessage(e),
      );
    } finally {
      _picking = false;
      if (root.mounted) root.context.hidePopupLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemePlaygroundSourceTile(
          label: SettingsStrings.sourceSeed,
          subtitle: SettingsStrings.sourceSeedSubtitle,
          selected: _kind == _SourceKind.seed,
          onTap: () => _onKindSelected(_SourceKind.seed),
        ),
        ThemePlaygroundSourceTile(
          label: SettingsStrings.sourceDevice,
          subtitle: SettingsStrings.sourceDeviceSubtitle,
          selected: _kind == _SourceKind.dynamicDevice,
          onTap: () => _onKindSelected(_SourceKind.dynamicDevice),
        ),
        ThemePlaygroundSourceTile(
          label: SettingsStrings.sourceImage,
          subtitle: SettingsStrings.sourceImageSubtitle,
          selected: _kind == _SourceKind.fromImage,
          onTap: () => _onKindSelected(_SourceKind.fromImage),
        ),
        12.verticalSpace,
        if (_kind == _SourceKind.seed)
          ThemePlaygroundSeedSwatches(active: _seed, onPick: _pickSeed),
        if (_kind == _SourceKind.dynamicDevice)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              SettingsStrings.deviceColorsHint,
              style: context.textTheme.bodySmall,
            ),
          ),
        if (_kind == _SourceKind.fromImage)
          ThemePlaygroundImageControls(
            imagePath: _imagePath,
            onPick: _pickImage,
          ),
      ],
    );
  }
}
