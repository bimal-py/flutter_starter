import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

/// Background handler registered at startup. Runs in a separate isolate, so it
/// has NO access to app state. Keep the work minimal: initialize Firebase,
/// optionally pre-process the payload. Banner display for `notification`-typed
/// messages is handled by the OS automatically.
///
/// Do NOT call [NotificationService] from here — that would force a hard
/// import on the notifications module. If you want to show a local banner for
/// data-only messages, do the work inside the foreground bridge instead.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  // The default app must be initialized for any Firebase API to work in the
  // background isolate. Uses firebase_options.dart when generated; otherwise
  // platform defaults from google-services.json / GoogleService-Info.plist.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialized — fine.
  }
}
