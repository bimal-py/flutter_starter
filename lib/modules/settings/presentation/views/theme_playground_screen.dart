import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';

class ThemePlaygroundScreen extends StatelessWidget {
  const ThemePlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize theme'), centerTitle: false),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) => ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            _OverrideStatusBanner(hasOverride: state.hasUserOverride),
            SizedBox(height: 16.h),
            const SettingsSectionHeader(label: 'Brightness mode'),
            const SettingsThemePicker(),
            SizedBox(height: 20.h),
            const SettingsSectionHeader(label: 'Source'),
            _SourcePicker(active: state.effectiveSource),
            SizedBox(height: 20.h),
            const SettingsSectionHeader(label: 'Preview'),
            const _PreviewChips(),
          ],
        ),
      ),
    );
  }
}

class _OverrideStatusBanner extends StatelessWidget {
  const _OverrideStatusBanner({required this.hasOverride});
  final bool hasOverride;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final ext = Theme.of(context).extension<CustomThemeExtension>();
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: hasOverride
            ? ext?.brandAccentMuted ?? scheme.primaryContainer
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            hasOverride ? Icons.tune : Icons.check_circle_outline,
            size: 18.r,
            color: scheme.onSurface,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              hasOverride
                  ? 'Using your custom theme'
                  : "Using the app's default theme",
              style: context.textTheme.bodyMedium,
            ),
          ),
          if (hasOverride)
            TextButton(
              onPressed: () {
                context.read<ThemeCubit>().clearUserOverride();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset to default theme')),
                );
              },
              child: const Text('Reset'),
            ),
        ],
      ),
    );
  }
}

enum _SourceKind { seed, dynamicDevice, fromImage }

class _SourcePicker extends StatefulWidget {
  const _SourcePicker({required this.active});
  final ThemeSource active;

  @override
  State<_SourcePicker> createState() => _SourcePickerState();
}

class _SourcePickerState extends State<_SourcePicker> {
  _SourceKind _kind = _SourceKind.seed;
  Color _seed = AppColors.seed;

  @override
  void initState() {
    super.initState();
    final s = widget.active;
    if (s is SeedOnlySource) {
      _kind = _SourceKind.seed;
      _seed = s.seed;
    } else if (s is DynamicDeviceSource) {
      _kind = _SourceKind.dynamicDevice;
      _seed = s.fallbackSeed;
    } else if (s is FromImageSource) {
      _kind = _SourceKind.fromImage;
      _seed = s.fallbackSeed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kindTile(
          kind: _SourceKind.seed,
          label: 'Seed color',
          subtitle: 'Pick a color; the app derives everything from it.',
        ),
        _kindTile(
          kind: _SourceKind.dynamicDevice,
          label: 'Dynamic device colors',
          subtitle: 'Use wallpaper colors (Android 12+).',
        ),
        _kindTile(
          kind: _SourceKind.fromImage,
          label: 'From image',
          subtitle: 'Pick an image and seed from its dominant color (coming soon).',
        ),
        SizedBox(height: 12.h),
        if (_kind == _SourceKind.seed) _SeedSwatches(active: _seed, onPick: _pickSeed),
        if (_kind == _SourceKind.dynamicDevice)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              'Active when wallpaper colors are available. Falls back to your last seed otherwise.',
              style: context.textTheme.bodySmall,
            ),
          ),
        if (_kind == _SourceKind.fromImage)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: FilledButton.tonalIcon(
              onPressed: null,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Pick an image (coming soon)'),
            ),
          ),
      ],
    );
  }

  Widget _kindTile({
    required _SourceKind kind,
    required String label,
    required String subtitle,
  }) {
    final selected = _kind == kind;
    final scheme = context.colorScheme;
    return ListTile(
      onTap: () => _onKindSelected(kind),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? scheme.primary : scheme.onSurfaceVariant,
      ),
      title: Text(label),
      subtitle: Text(subtitle, style: context.textTheme.bodySmall),
    );
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
        // Image picker not wired yet; the cubit applyUserImage hook is ready
        // for when a picker lands. Until then we leave the active source.
        break;
    }
  }

  void _pickSeed(Color color) {
    setState(() => _seed = color);
    context.read<ThemeCubit>().setUserSeed(color);
  }
}

class _SeedSwatches extends StatelessWidget {
  const _SeedSwatches({required this.active, required this.onPick});

  final Color active;
  final ValueChanged<Color> onPick;

  static const List<Color> _swatches = [
    Color(0xFF1B3A6B),
    Color(0xFF4A6FA5),
    Color(0xFF1E88E5),
    Color(0xFF00ACC1),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Color(0xFFD81B60),
    Color(0xFF8E24AA),
    Color(0xFF5E35B1),
    Color(0xFFEF6C00),
    Color(0xFF6D4C41),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: [
          for (final c in _swatches) _swatch(context, c),
          _customButton(context),
        ],
      ),
    );
  }

  Widget _swatch(BuildContext context, Color color) {
    final isActive = color.toARGB32() == active.toARGB32();
    return GestureDetector(
      onTap: () => onPick(color),
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? context.colorScheme.onSurface
                : Colors.transparent,
            width: isActive ? 3 : 0,
          ),
        ),
        child: isActive
            ? Icon(Icons.check, color: Colors.white, size: 20.r)
            : null,
      ),
    );
  }

  Widget _customButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Color picked = active;
        final result = await showDialog<Color>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Pick a custom color'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: active,
                  onColorChanged: (c) => picked = c,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(picked),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
        if (result != null) onPick(result);
      },
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: context.colorScheme.outline),
        ),
        child: Icon(Icons.add, color: context.colorScheme.onSurface, size: 20.r),
      ),
    );
  }
}

class _PreviewChips extends StatelessWidget {
  const _PreviewChips();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: context.textTheme.titleSmall),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                FilledButton(onPressed: () {}, child: const Text('Primary')),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Tonal'),
                ),
                OutlinedButton(onPressed: () {}, child: const Text('Outline')),
                TextButton(onPressed: () {}, child: const Text('Text')),
              ],
            ),
            SizedBox(height: 12.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
            ),
            SizedBox(height: 12.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: scheme.primary,
                child: Icon(Icons.person, color: scheme.onPrimary),
              ),
              title: const Text('A preview row'),
              subtitle: const Text('Body text rendered with current theme'),
              trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
