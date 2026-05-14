import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_starter/modules/fcm/integrations/notifications_bridge.dart';
import 'package:flutter_starter/modules/notifications/notifications.dart';

/// Minimal background handler — initializes Firebase in the background isolate
/// and exits. `notification`-payload messages are displayed by the OS without
/// any work here.
///
/// For data-only messages (the only way to ship action buttons), use
/// [fcmBackgroundDisplayHandler] instead. Don't call `NotificationService` —
/// the singleton is uninitialised in the background isolate.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {/* already initialized */}
}

/// Displays data-only FCM messages as local notifications, parsing action
/// buttons from `data.actions` (see [buildNotificationBridge] for the payload
/// contract). Wire instead of [fcmBackgroundHandler] when the backend ships
/// data-only payloads:
///
/// ```dart
/// FirebaseMessaging.onBackgroundMessage(fcmBackgroundDisplayHandler);
/// ```
///
/// Skips messages carrying a `notification` payload (the OS already showed
/// those). On cold start, tap routing uses `getInitialMessage` /
/// `getNotificationAppLaunchDetails` — not the foreground `onTap` stream.
@pragma('vm:entry-point')
Future<void> fcmBackgroundDisplayHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {/* already initialized */}

  // Skip if OS already displayed the notification-payload banner.
  if (message.notification?.title != null ||
      message.notification?.body != null) {
    return;
  }

  final data = message.data;
  final title = data['title']?.toString() ?? '';
  final body = data['body']?.toString() ?? '';
  if (title.isEmpty && body.isEmpty) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  final channel = data['channel']?.toString() ??
      NotificationChannels.defaultChannelId;
  final actions = parseFcmActions(data['actions']);
  final id =
      (message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch) &
          0x7fffffff;

  await plugin.show(
    id,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channel,
        importance: Importance.high,
        priority: Priority.high,
        actions: actions
            .map((a) => AndroidNotificationAction(
                  a.id,
                  a.label,
                  cancelNotification: !a.foreground,
                ))
            .toList(),
      ),
      iOS: DarwinNotificationDetails(
        // iOS action buttons require pre-registered DarwinNotificationCategory.
        // Channel doubles as categoryIdentifier — see notifications_bridge.dart.
        categoryIdentifier: actions.isEmpty ? null : channel,
      ),
    ),
    payload: jsonEncode({
      'data': data,
      'channel': channel,
      'title': title,
      'body': body,
      'id': id,
    }),
  );
}
