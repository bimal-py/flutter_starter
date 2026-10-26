import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/qr/qr.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';
import 'package:flutter_starter/modules/settings/utils/helper/helper.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsShareFeedbackGroup extends StatelessWidget {
  const SettingsShareFeedbackGroup({super.key});

  Future<void> _rateApp(BuildContext context) async {
    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
      } else {
        await review.openStoreListing(appStoreId: AppConstants.appIosAppId);
      }
    } catch (_) {
      if (context.mounted) {
        CustomSnackbar.show(
          type: ToastType.error,
          message: SettingsError.storeListingUnavailable,
        );
      }
    }
  }

  Future<void> _report(BuildContext context) async {
    try {
      await FeedbackEmailHelper.sendEmail(
        context: context,
        to: AppUrls.supportEmail,
        subject: SettingsStrings.reportEmailSubject,
      );
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          type: ToastType.error,
          message: AppErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SettingsTile(
            icon: LucideIcons.qrCode,
            label: SettingsStrings.shareQr,
            subtitle: SettingsStrings.shareQrSubtitle,
            onTap: () => QrPopup.show(
              context,
              qrData: AppUrls.appDownload,
              fileName: AppConstants.appAndroidPackageId,
            ),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: LucideIcons.star,
            label: SettingsStrings.rateApp,
            onTap: () => _rateApp(context),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: LucideIcons.flag,
            label: SettingsStrings.reportProblem,
            subtitle: AppUrls.supportEmail,
            onTap: () => _report(context),
          ),
        ],
      ),
    );
  }
}
