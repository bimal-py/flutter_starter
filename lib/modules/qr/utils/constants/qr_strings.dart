import 'package:flutter_starter/core/core.dart';

class QrStrings {
  QrStrings._();

  static const String title = 'Share app QR';
  static const String scanToDownload = 'Scan to download';
  static const String save = 'Save';
  static const String share = 'Share';
  static const String saving = 'Saving…';
  static const String saved = 'QR saved to gallery';

  static const String shareSubject = '${AppConstants.appName} QR';
  static String shareText(String link) =>
      'Download ${AppConstants.appName}: $link';
}
