import 'package:flutter_starter/core/errors/exceptions.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tiny wrapper over `url_launcher` so callers don't have to construct URIs
/// or handle launch-failure as a bool.
class UrlHelper {
  const UrlHelper();

  Future<void> launch(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw const AppException(message: 'Invalid URL');
    }
    final ok = await launchUrl(uri, mode: mode);
    if (!ok) {
      throw AppException(message: 'Could not open $url');
    }
  }

  Future<void> sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      query: _encodeMailtoQuery({'subject': subject, 'body': body}),
    );
    final ok = await launchUrl(uri);
    if (!ok) {
      throw const AppException(message: 'No email app available');
    }
  }

  String? _encodeMailtoQuery(Map<String, String?> params) {
    final entries = params.entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value!)}');
    if (entries.isEmpty) return null;
    return entries.join('&');
  }
}
