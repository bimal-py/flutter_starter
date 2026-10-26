import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';

/// Stock Material widgets, so the card shows what the current theme does.
class ThemePlaygroundPreview extends StatelessWidget {
  const ThemePlaygroundPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SettingsStrings.preview, style: context.textTheme.titleSmall),
            12.verticalSpace,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                FilledButton(
                  onPressed: () {},
                  child: const Text(SettingsStrings.previewPrimary),
                ),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text(SettingsStrings.previewTonal),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text(SettingsStrings.previewOutline),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(SettingsStrings.previewText),
                ),
              ],
            ),
            12.verticalSpace,
            const TextField(
              decoration: InputDecoration(
                labelText: SettingsStrings.previewFieldLabel,
                hintText: SettingsStrings.previewFieldHint,
              ),
            ),
            12.verticalSpace,
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: scheme.primary,
                child: Icon(Icons.person, color: scheme.onPrimary),
              ),
              title: const Text(SettingsStrings.previewRowTitle),
              subtitle: const Text(SettingsStrings.previewRowSubtitle),
              trailing: Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
