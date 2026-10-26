import 'dart:math';

import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/domain/domain.dart';
import 'package:flutter_starter/modules/mobile_ads/features/self_promotion/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SelfPromotionHelper {
  SelfPromotionHelper._();

  static SelfPromotionAppEntity randomApp() {
    const all = SelfPromotionApps.all;
    return all[Random().nextInt(all.length)];
  }

  /// Opens the app's download page in the browser. A malformed URL is
  /// ignored.
  static Future<void> open(SelfPromotionAppEntity app) async {
    final uri = Uri.tryParse(app.shareUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
