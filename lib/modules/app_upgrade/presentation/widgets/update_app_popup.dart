import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/app_upgrade/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/app_upgrade/utils/constants/constants.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

/// The "Update available" dialog body. Renders [content] as HTML so Remote
/// Config can ship a rich changelog (`<ul>`, `<b>`, etc.). With
/// `force_update` it can't be closed: no back, no "Remind me later" or
/// "Ignore".
class UpdateAppPopup extends StatelessWidget {
  const UpdateAppPopup({super.key, required this.content});

  final String content;

  Future<void> _openStore() async {
    try {
      await const UrlHelper().launch(AppUpgradeConstants.storeUrl);
    } catch (error) {
      CustomSnackbar.show(
        type: ToastType.error,
        message: AppErrorHandler.getErrorMessage(error),
      );
    }
  }

  Future<void> _ignore(BuildContext context) async {
    await context.read<AppUpgradeCubit>().ignoreCurrentReleasedVersion();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isForceUpdate = context.select<AppUpgradeCubit, bool>(
      (c) => c.state.isForceUpdate,
    );
    final scheme = context.colorScheme;

    return PopScope(
      canPop: !isForceUpdate,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.screenWidth * 0.86),
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
                    AppUpgradeStrings.title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
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
                              textStyle: context.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface,
                              ),
                              renderMode: RenderMode.column,
                            ),
                          ),
                        ),
                      ),
                      16.verticalSpace,
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _openStore,
                          child: const Text(AppUpgradeStrings.updateNow),
                        ),
                      ),
                      if (!isForceUpdate) ...[
                        8.verticalSpace,
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  AppUpgradeStrings.remindMeLater,
                                ),
                              ),
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _ignore(context),
                                child: const Text(AppUpgradeStrings.ignore),
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
