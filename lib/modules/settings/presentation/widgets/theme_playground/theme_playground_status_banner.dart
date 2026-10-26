import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';

class ThemePlaygroundStatusBanner extends StatelessWidget {
  const ThemePlaygroundStatusBanner({super.key, required this.hasOverride});

  final bool hasOverride;

  void _reset(BuildContext context) {
    context.read<ThemeCubit>().clearUserOverride();
    CustomSnackbar.show(
      type: ToastType.success,
      message: SettingsStrings.themeReset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: hasOverride
            ? scheme.primaryContainer
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
          10.horizontalSpace,
          Expanded(
            child: Text(
              hasOverride
                  ? SettingsStrings.usingCustomTheme
                  : SettingsStrings.usingDefaultTheme,
              style: context.textTheme.bodyMedium,
            ),
          ),
          if (hasOverride)
            TextButton(
              onPressed: () => _reset(context),
              child: const Text(SettingsStrings.reset),
            ),
        ],
      ),
    );
  }
}
