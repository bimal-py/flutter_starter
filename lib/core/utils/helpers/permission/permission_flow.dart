import 'dart:async';

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
///    then re-reads the status when the user comes back to the app. (iOS
///    restarts the app instead when the user changes the permission there.)
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

    if (!await openAppSettings()) return false;
    await _nextResume();
    return _isUsable(await permission.status);
  }

  /// Completes when the app is in front again. `openAppSettings` returns as
  /// soon as Settings opens, before the user has changed anything.
  static Future<void> _nextResume() {
    final resumed = Completer<void>();
    late final AppLifecycleListener listener;
    listener = AppLifecycleListener(
      onResume: () {
        listener.dispose();
        resumed.complete();
      },
    );
    return resumed.future;
  }

  static bool _isUsable(PermissionStatus s) =>
      s.isGranted || s.isLimited || s.isProvisional;
}
