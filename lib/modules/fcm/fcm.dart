/// Native setup notes:
/// - iOS: APNs key/cert in Firebase console, Push Notifications capability in
///   Xcode, Background Modes -> Remote notifications, register for remote
///   notifications in AppDelegate.swift.
/// - Android: google-services.json (pulled by FlutterFire). For data-only
///   messages on Android 13+, ensure POST_NOTIFICATIONS permission is granted
///   (the notifications module handles the prompt).
///
/// Wire FCM in main.dart with these two lines:
///   FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
///   await FcmService.instance.initialize(
///     onForegroundMessage: buildNotificationBridge(),   // optional bridge
///   );
library;

export 'fcm_background_handler.dart';
export 'fcm_remote_message.dart';
export 'fcm_secure_storage.dart';
export 'fcm_service.dart';
export 'fcm_storage_keys.dart';
export 'integrations/notifications_bridge.dart';
