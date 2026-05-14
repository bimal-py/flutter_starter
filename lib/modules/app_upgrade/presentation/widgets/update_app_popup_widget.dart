import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_starter/core/utils/helpers/url_helper.dart';
import 'package:flutter_starter/modules/app_upgrade/constants/app_upgrade_constants.dart';
import 'package:flutter_starter/modules/app_upgrade/cubit/app_upgrade_cubit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

/// The "Update available" dialog body. Renders [content] as HTML so Remote
/// Config can ship a rich changelog (`<ul>`, `<b>`, etc.). Wraps itself in a
/// [PopScope] when `is_force_update` is true to block back-press / barrier
/// dismissal.
class UpdateAppPopupWidget extends StatelessWidget {
  const UpdateAppPopupWidget({super.key, required this.content});
  final String content;

  Future<void> _openStore() async {
    try {
      await const UrlHelper().launch(AppUpgradeConstants.storeUrl);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isForceUpdate = context.select<AppUpgradeCubit, bool>(
      (c) => c.state.isForceUpdate,
    );
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: !isForceUpdate,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.86),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: scheme.primary, width: 2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  color: scheme.primary,
                  child: Text(
                    'Update available',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 280.h),
                        child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 0.8,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: HtmlWidget(
                              content,
                              textStyle: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurface),
                              renderMode: RenderMode.column,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _openStore,
                          child: const Text('Update now'),
                        ),
                      ),
                      if (!isForceUpdate) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Remind me later'),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await context
                                      .read<AppUpgradeCubit>()
                                      .ignoreCurrentReleasedVersion();
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Ignore'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
