import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/utils/helpers/url_helper.dart';
import 'package:flutter_starter/modules/device_info/device_info.dart';
import 'package:flutter_starter/modules/package_info/package_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Opens the user's mail app pre-filled with a support/report message and
/// diagnostic details (device + app version) pulled from the global
/// [DeviceInfoCubit] and [PackageInfoCubit].
class EmailHelper {
  const EmailHelper._();

  static Future<void> sendEmail({
    required BuildContext context,
    required String to,
    required String subject,
    String? additionalBody,
  }) async {
    final lines = <String>[
      _formatDeviceInfo(context.read<DeviceInfoCubit>().state.deviceInfo),
      _formatPackageInfo(context.read<PackageInfoCubit>().state.packageInfo),
      if (additionalBody != null && additionalBody.isNotEmpty) ...[
        '',
        additionalBody,
      ],
    ];

    await const UrlHelper().sendEmail(
      to: to,
      subject: subject,
      body: lines.join('\n'),
    );
  }

  static String _formatDeviceInfo(BaseDeviceInfo? info) {
    if (info is AndroidDeviceInfo) {
      return 'Device: ${info.brand} ${info.model}\n'
          'OS: Android ${info.version.release} (API ${info.version.sdkInt})';
    }
    if (info is IosDeviceInfo) {
      return 'Device: ${info.name} ${info.model}\n'
          'OS: iOS ${info.systemVersion}';
    }
    if (info is MacOsDeviceInfo) {
      return 'Device: ${info.computerName}\nOS: macOS ${info.osRelease}';
    }
    if (info is WindowsDeviceInfo) {
      return 'Device: ${info.computerName}\n'
          'OS: Windows ${info.majorVersion}.${info.minorVersion} '
          '(Build ${info.buildNumber})';
    }
    if (info is LinuxDeviceInfo) {
      return 'Device: ${info.name}\nOS: Linux ${info.versionId}';
    }
    if (info is WebBrowserInfo) {
      return 'Browser: ${info.browserName}\n'
          'User Agent: ${info.userAgent ?? 'N/A'}';
    }
    return 'Device: Unknown Platform';
  }

  static String _formatPackageInfo(PackageInfo? info) {
    if (info == null) return 'App Version: N/A';
    return 'App Version: ${info.version} (${info.buildNumber})';
  }
}
