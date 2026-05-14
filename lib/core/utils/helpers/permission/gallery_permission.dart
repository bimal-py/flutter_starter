import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/core/utils/constants/app_constants.dart';
import 'package:flutter_starter/core/utils/helpers/dialog/dialog_type.dart';
import 'package:flutter_starter/core/utils/helpers/permission/permission_flow.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission flow for saving images to the gallery.
///
/// Platform quirks:
/// - **iOS**: requests `Permission.photosAddOnly`. `limited` counts as granted
///   (sufficient for adding photos).
/// - **Android ≤ 9 (SDK 28)**: requests `Permission.storage`.
/// - **Android ≥ 10**: `image_gallery_saver_plus` can save without a runtime
///   permission — returns `true` immediately.
class GalleryPermission {
  const GalleryPermission._();

  static Future<Permission?> _required() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt <= 28 ? Permission.storage : null;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Permission.photosAddOnly;
    }
    return null;
  }

  static Future<bool> ensure(BuildContext context) async {
    final permission = await _required();
    if (permission == null) return true;
    if (!context.mounted) return false;
    return PermissionFlow.ensure(
      context,
      permission: permission,
      settingsDialogTitle: 'Photo access needed',
      settingsDialogMessage:
          '${AppConstants.appName} needs permission to save images to your '
          'gallery. Please grant access in Settings.',
      dialogType: DialogType.info,
    );
  }
}
