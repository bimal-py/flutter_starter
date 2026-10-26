import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_starter/modules/fcm/domain/domain.dart';
import 'package:flutter_starter/modules/notifications/notifications.dart';

typedef ForegroundMessageHandler = void Function(FcmRemoteMessageEntity msg);

// The only fcm file that imports the notifications module: without that
// module, delete this file and its export in helper.dart. The payload
// contract for data-only pushes is in doc/modules/fcm.md.

/// Shows foreground pushes as local notifications. Pass it to
/// `FcmService.instance.initialize(onForegroundMessage: ...)`.
ForegroundMessageHandler buildNotificationBridge({
  int Function(FcmRemoteMessageEntity msg)? idResolver,
  String defaultChannel = NotificationChannelsEntity.defaultChannelId,
  NotificationPriority priority = NotificationPriority.high,
}) {
  return (msg) async {
    // iOS already shows a push that has a title or body (FcmService asks it
    // to, with setForegroundNotificationPresentationOptions); a second
    // banner here would show it twice. Its tap comes through
    // onMessageOpenedApp.
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        (msg.title != null || msg.body != null)) {
      return;
    }
    final title = msg.title ?? msg.data['title']?.toString();
    final body = msg.body ?? msg.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    final id = idResolver?.call(msg) ?? _notificationId(msg.messageId);
    final channel = msg.data['channel']?.toString() ?? defaultChannel;
    await NotificationService.instance.show(
      NotificationPayloadEntity(
        id: id,
        title: title ?? '',
        body: body ?? '',
        data: msg.data,
        channel: channel,
        priority: priority,
        actions: parseFcmActions(msg.data['actions']),
      ),
    );
  };
}

/// Background handler that also shows data-only pushes as local
/// notifications, with the action buttons from `data.actions`. Register it
/// instead of `fcmBackgroundHandler`:
///
/// ```dart
/// FirebaseMessaging.onBackgroundMessage(fcmBackgroundDisplayHandler);
/// ```
///
/// Pushes with a `notification` payload are skipped: the OS already showed
/// them. A tap that starts the app arrives through
/// `NotificationService.initialize(onLaunch:)`, not the `onTap` stream.
@pragma('vm:entry-point')
Future<void> fcmBackgroundDisplayHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialised in this isolate.
  }

  if (message.notification?.title != null ||
      message.notification?.body != null) {
    return;
  }

  final data = message.data;
  final title = data['title']?.toString() ?? '';
  final body = data['body']?.toString() ?? '';
  if (title.isEmpty && body.isEmpty) return;

  // NotificationService isn't initialised in this isolate: use the plugin.
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  final channel =
      data['channel']?.toString() ??
      NotificationChannelsEntity.defaultChannelId;
  final actions = parseFcmActions(data['actions']);
  final id = _notificationId(message.messageId);

  await plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channel,
        importance: Importance.high,
        priority: Priority.high,
        actions: actions
            .map(
              (a) => AndroidNotificationAction(
                a.id,
                a.label,
                cancelNotification: !a.foreground,
              ),
            )
            .toList(),
      ),
      iOS: DarwinNotificationDetails(
        // iOS shows buttons only for a category registered at launch; the
        // channel names it.
        categoryIdentifier: actions.isEmpty ? null : channel,
      ),
    ),
    // Same envelope LocalNotificationsRepositoryImpl writes, so its tap
    // handler can read it.
    payload: jsonEncode(
      NotificationPayloadModel(
        id: id,
        title: title,
        body: body,
        data: data,
        channel: channel,
      ).toJson(),
    ),
  );
}

/// Parses `data.actions`: a JSON string (FCM data values are strings) or an
/// already-decoded list. Anything malformed gives no actions rather than
/// dropping the notification.
List<NotificationActionEntity> parseFcmActions(dynamic raw) {
  if (raw == null) return const [];
  try {
    final List<dynamic> list = raw is String
        ? jsonDecode(raw) as List<dynamic>
        : raw as List<dynamic>;
    return list
        .whereType<Map>()
        .map((m) => m.cast<String, dynamic>())
        .map(
          (m) => NotificationActionEntity(
            id: m['id']?.toString() ?? '',
            label: m['label']?.toString() ?? '',
            destructive: m['destructive'] == true,
            foreground: m['foreground'] != false,
          ),
        )
        .where((a) => a.id.isNotEmpty && a.label.isNotEmpty)
        .toList();
  } catch (_) {
    return const [];
  }
}

/// Local notification id from the FCM message id (a positive 31-bit int).
int _notificationId(String? messageId) =>
    (messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch) & 0x7fffffff;
