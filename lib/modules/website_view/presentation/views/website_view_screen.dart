import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// In-app page for [url]:
/// - A progress bar runs under the app bar, which shows the page's title.
/// - Back goes back in the page first, then closes the screen.
/// - `mailto:`, `tel:` and `sms:` links open outside the webview;
///   `target="_blank"` links load here (no new windows).
/// - Pauses the page while the app is in the background (Android).
class WebsiteViewScreen extends StatelessWidget {
  const WebsiteViewScreen({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => WebsiteView(url: url);
}

class WebsiteView extends StatefulWidget {
  const WebsiteView({super.key, required this.url});

  final String url;

  @override
  State<WebsiteView> createState() => _WebsiteViewState();
}

class _WebsiteViewState extends State<WebsiteView> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  String _title = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _webViewController = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (state == AppLifecycleState.paused) {
      _webViewController?.pause();
      _webViewController?.pauseTimers();
    } else {
      _webViewController?.resume();
      _webViewController?.resumeTimers();
    }
  }

  Future<bool> _handleSystemBack() async {
    final canGoBack = await _webViewController?.canGoBack() ?? false;
    if (canGoBack) {
      await _webViewController?.goBack();
      return false;
    }
    return true;
  }

  bool _isExternalScheme(String scheme) =>
      const {'mailto', 'tel', 'sms'}.contains(scheme);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldClose = await _handleSystemBack();
        if (shouldClose && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title.isEmpty ? widget.url : _title),
          bottom: _progress < 1
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(value: _progress),
                )
              : null,
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            isInspectable: kDebugMode,
            useShouldOverrideUrlLoading: true,
            supportMultipleWindows: false,
          ),
          onWebViewCreated: (c) => _webViewController = c,
          onProgressChanged: (_, p) => setState(() => _progress = p / 100),
          onTitleChanged: (_, t) => setState(() => _title = t ?? ''),
          shouldOverrideUrlLoading: (_, action) async {
            final uri = action.request.url;
            if (uri == null) return NavigationActionPolicy.CANCEL;
            if (_isExternalScheme(uri.scheme)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
        ),
      ),
    );
  }
}
