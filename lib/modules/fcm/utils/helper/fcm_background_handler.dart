import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

/// Runs in a background isolate for pushes that arrive while the app is in
/// the background or killed. The OS shows `notification` payloads by itself,
/// so this only brings Firebase up. For data-only pushes (the way to ship
/// action buttons) register `fcmBackgroundDisplayHandler` from the
/// notifications bridge instead. `NotificationService` isn't initialised in
/// this isolate, so don't call it here.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialised in this isolate.
  }
}
