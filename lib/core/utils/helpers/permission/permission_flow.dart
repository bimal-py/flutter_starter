import 'package:flutter/material.dart';
import 'package:flutter_starter/core/utils/helpers/dialog/dialog.dart';
import 'package:permission_handler/permission_handler.dart';

/// Generic runtime-permission flow.
///
/// 1. Returns `true` immediately if the permission is already granted /
///    limited / provisional.
/// 2. First time (`isDenied`): calls the native request.
/// 3. If still denied (or `isPermanentlyDenied`): shows a
///    [ConfirmationDialog] offering to open the app's system settings,
///    then re-reads the status when the user returns.
class PermissionFlow {
  const PermissionFlow._();

  static Future<bool> ensure(
    BuildContext context, {
    required Permission permission,
    required String settingsDialogTitle,
    required String settingsDialogMessage,
    String confirmText = 'Open settings',
    String cancelText = 'Not now',
    DialogType dialogType = DialogType.info,
  }) async {
    var status = await permission.status;
    if (_isUsable(status)) return true;

    if (status.isDenied) {
      status = await permission.request();
      if (_isUsable(status)) return true;
    }

    if (!context.mounted) return false;

    final shouldOpen = await DialogUtils.showConfirmationDialog(
      context,
      title: settingsDialogTitle,
      message: settingsDialogMessage,
      confirmText: confirmText,
      cancelText: cancelText,
      dialogType: dialogType,
    );
    if (!shouldOpen) return false;

    await openAppSettings();
    return _isUsable(await permission.status);
  }

  static bool _isUsable(PermissionStatus s) =>
      s.isGranted || s.isLimited || s.isProvisional;
}
