import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/utils/helpers/helpers.dart';
import 'package:flutter_starter/modules/device_info/device_info.dart';
import 'package:flutter_starter/modules/package_info/package_info.dart';

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

  static String _formatDeviceInfo(DeviceInfoEntity? entity) {
    if (entity == null) return 'Device: Unknown Platform';
    final d = entity.data;
    return switch (entity.platform) {
      'android' => () {
        final ver = d['version'] as Map? ?? {};
        return 'Device: ${d['brand']} ${d['model']}\n'
            'OS: Android ${ver['release']} (API ${ver['sdkInt']})';
      }(),
      'ios' =>
        'Device: ${d['name']} ${d['model']}\nOS: iOS ${d['systemVersion']}',
      'macos' => 'Device: ${d['computerName']}\nOS: macOS ${d['osRelease']}',
      'windows' =>
        'Device: ${d['computerName']}\n'
            'OS: Windows ${d['majorVersion']}.${d['minorVersion']} (Build ${d['buildNumber']})',
      'linux' => 'Device: ${d['name']}\nOS: Linux ${d['versionId']}',
      'web' =>
        'Browser: ${d['browserName']}\nUser Agent: ${d['userAgent'] ?? 'N/A'}',
      _ => 'Device: ${entity.platform}',
    };
  }

  static String _formatPackageInfo(PackageInfoEntity? info) {
    if (info == null) return 'App Version: N/A';
    return 'App Version: ${info.version} (${info.buildNumber})';
  }
}
