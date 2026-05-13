import 'package:flutter_starter/modules/fcm/fcm_remote_message.dart';
import 'package:flutter_starter/modules/notifications/notifications.dart';

typedef ForegroundMessageHandler = void Function(FcmRemoteMessage msg);

/// Optional glue between FCM and Notifications. Import ONLY when both modules
/// are present. Delete this file if either module is removed — nothing else
/// references it.
ForegroundMessageHandler buildNotificationBridge({
  int Function(FcmRemoteMessage msg)? idResolver,
  String defaultChannel = NotificationChannels.defaultChannelId,
  NotificationPriority priority = NotificationPriority.high,
}) {
  return (msg) async {
    if (msg.title == null && msg.body == null) return;
    final id = idResolver?.call(msg) ??
        ((msg.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch) &
            0x7fffffff);
    await NotificationService.instance.show(
      NotificationPayload(
        id: id,
        title: msg.title ?? '',
        body: msg.body ?? '',
        data: msg.data,
        channel: defaultChannel,
        priority: priority,
      ),
    );
  };
}
