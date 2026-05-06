import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/qr/qr.dart';
import 'package:flutter_starter/modules/settings/presentation/widgets/settings_tile.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsShareFeedbackGroup extends StatelessWidget {
  const SettingsShareFeedbackGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          SettingsTile(
            icon: LucideIcons.qrCode,
            label: 'Share app QR',
            subtitle: 'Show a QR code others can scan to download',
            onTap: () => QrPopup.show(
              context,
              qrData: AppUrls.appDownload,
              fileName: AppConstants.appAndroidPackageId,
            ),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: LucideIcons.star,
            label: 'Rate the app',
            onTap: () => _rateApp(context),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: LucideIcons.flag,
            label: 'Report a problem',
            subtitle: AppUrls.supportEmail,
            onTap: () => _report(context),
          ),
        ],
      ),
    );
  }

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
        context.showErrorToast('Could not open store listing');
      }
    }
  }

  Future<void> _report(BuildContext context) async {
    try {
      await const UrlHelper().sendEmail(
        to: AppUrls.supportEmail,
        subject: 'Report from user (${AppConstants.appName})',
      );
    } on AppException catch (e) {
      if (context.mounted) context.showErrorToast(e.message);
    } catch (e) {
      if (context.mounted) context.showErrorToast('$e');
    }
  }
}
