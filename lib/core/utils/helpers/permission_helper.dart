import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/core/utils/constants/app_constants.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission flow for saving images to the gallery.
///
/// Handles the platform-specific quirks:
/// - **iOS**: requests `Permission.photosAddOnly`. Treats `limited` as granted
///   (acceptable for adding photos).
/// - **Android ≤ 9 (SDK 28)**: requests `Permission.storage`.
/// - **Android ≥ 10**: gallery saving with `image_gallery_saver_plus` doesn't
///   need a runtime permission — returns true immediately.
class PermissionHelper {
  PermissionHelper._();

  static Future<Permission?> _getRequiredPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt <= 28 ? Permission.storage : null;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Permission.photosAddOnly;
    }
    return null;
  }

  /// Walks the user through requesting gallery permission, including a
  /// "Open settings" dialog if the user has permanently denied it.
  /// Returns `true` when the operation may proceed.
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    final permission = await _getRequiredPermission();
    if (permission == null) return true;

    var status = await permission.status;
    if (status.isGranted || status == PermissionStatus.limited) return true;

    if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted || status == PermissionStatus.limited) return true;
    }

    if (status.isPermanentlyDenied && context.mounted) {
      return _showOpenSettingsDialog(context);
    }
    return false;
  }

  static Future<bool> _showOpenSettingsDialog(BuildContext context) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Photo access needed'),
        content: Text(
          '${AppConstants.appName} needs permission to save images to your gallery. '
          'Please grant access in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (shouldOpen != true) return false;
    await openAppSettings();
    final permission = await _getRequiredPermission();
    if (permission == null) return true;
    final status = await permission.status;
    return status.isGranted || status == PermissionStatus.limited;
  }
}
