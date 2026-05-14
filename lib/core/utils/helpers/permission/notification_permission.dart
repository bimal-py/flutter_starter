import 'package:flutter/material.dart';
import 'package:flutter_starter/core/utils/constants/app_constants.dart';
import 'package:flutter_starter/core/utils/helpers/dialog/dialog_type.dart';
import 'package:flutter_starter/core/utils/helpers/permission/permission_flow.dart';
import 'package:permission_handler/permission_handler.dart';

/// Single entry point for the OS notification permission used by both
/// FCM (firebase_messaging) and local notifications (flutter_local_notifications).
///
/// On Android < 13 this is granted automatically; on Android 13+ and iOS it
/// triggers the standard system prompt the first time, then the app-settings
/// dialog on subsequent denied calls.
class NotificationPermission {
  const NotificationPermission._();

  /// Whether the OS-level notification permission is currently granted.
  static Future<bool> get isGranted async =>
      (await Permission.notification.status).isGranted;

  /// Walks the user through enabling notifications, including an
  /// app-settings dialog when they've already been denied.
  static Future<bool> ensure(BuildContext context) {
    return PermissionFlow.ensure(
      context,
      permission: Permission.notification,
      settingsDialogTitle: 'Enable notifications',
      settingsDialogMessage:
          '${AppConstants.appName} needs notification permission to keep you '
          'up to date. You can enable it in Settings.',
      dialogType: DialogType.info,
    );
  }
}
