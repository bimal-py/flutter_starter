import 'dart:convert';

import 'package:flutter_starter/modules/fcm/domain/entity/fcm_remote_message.dart';
import 'package:flutter_starter/modules/notifications/notifications.dart';

typedef ForegroundMessageHandler = void Function(FcmRemoteMessage msg);

/// Optional glue between FCM and Notifications. Import ONLY when both modules
/// are present. Delete this file if either module is removed — nothing else
/// references it.
///
/// ## Backend payload contract
///
/// To get a notification with action buttons, your backend should send a
/// **data-only** FCM message (no `notification` key). The bridge reads:
///
/// - `title` (string, required)
/// - `body` (string, required)
/// - `channel` (string, optional) — picks the local channel, defaults to
///   [defaultChannel]
/// - `actions` (JSON string, optional) — array of `{id, label, destructive?}`.
///   Example: `[{"id":"view","label":"View"},{"id":"snooze","label":"Snooze"}]`
/// - any other keys → forwarded through `payload.data` so the tap handler
///   can route / deep-link.
///
/// Example backend send (HTTP v1 API):
/// ```json
/// {
///   "message": {
///     "token": "<fcm token>",
///     "data": {
///       "title": "New chat message",
///       "body": "Alex: are you online?",
///       "channel": "high_priority",
///       "actions": "[{\"id\":\"reply\",\"label\":\"Reply\"},{\"id\":\"mute\",\"label\":\"Mute\",\"destructive\":true}]",
///       "chat_id": "1234"
///     },
///     "android": {"priority": "high"}
///   }
/// }
/// ```
///
/// ## iOS action-button caveat
///
/// Android action buttons are dynamic — every notification can ship its own
/// set. iOS requires categories registered up-front at app launch; you can't
/// add new action sets per-notification. If you need action buttons on iOS,
/// register `DarwinNotificationCategory` instances at notifications init time
/// and send a matching `channel` (used as the categoryIdentifier) from the
/// backend. Android-only action buttons work out of the box with this bridge.
ForegroundMessageHandler buildNotificationBridge({
  int Function(FcmRemoteMessage msg)? idResolver,
  String defaultChannel = NotificationChannels.defaultChannelId,
  NotificationPriority priority = NotificationPriority.high,
}) {
  return (msg) async {
    final title = msg.title ?? msg.data['title']?.toString();
    final body = msg.body ?? msg.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    final id = idResolver?.call(msg) ??
        ((msg.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch) &
            0x7fffffff);
    final channel = msg.data['channel']?.toString() ?? defaultChannel;
    await NotificationService.instance.show(
      NotificationPayload(
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

/// Parses an `actions` value from the FCM data payload. Accepts:
/// - a JSON-encoded string (the only form FCM data accepts cross-platform —
///   `data` values must be strings)
/// - an already-decoded List (in case the data was built locally for a test)
///
/// Returns an empty list on anything malformed instead of throwing — a bad
/// payload shouldn't drop the whole notification.
List<NotificationAction> parseFcmActions(dynamic raw) {
  if (raw == null) return const [];
  try {
    final List<dynamic> list = raw is String
        ? jsonDecode(raw) as List<dynamic>
        : raw as List<dynamic>;
    return list
        .whereType<Map>()
        .map((m) => m.cast<String, dynamic>())
        .map((m) => NotificationAction(
              id: m['id']?.toString() ?? '',
              label: m['label']?.toString() ?? '',
              destructive: m['destructive'] == true,
              foreground: m['foreground'] != false,
            ))
        .where((a) => a.id.isNotEmpty && a.label.isNotEmpty)
        .toList();
  } catch (_) {
    return const [];
  }
}
